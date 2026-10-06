import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/api/api_exception.dart';
import '../../models/master_data_item.dart';
import '../../models/registration_draft.dart';
import '../../providers/providers.dart';
import '../../routing/routes.dart';
import '../../utils/l10n.dart';
import '../../widgets/common.dart';
import 'registration_complete_screen.dart';
import 'steps/address_step.dart';
import 'steps/community_step.dart';
import 'steps/current_status_step.dart';
import 'steps/disability_step.dart';
import 'steps/personal_details_step.dart';

/// Registration wizard: Personal Details → Current Status → Temple & Organisation → Address →
/// Disability Information. Each step validates before moving on; the backend validates everything again.
class RegistrationScreen extends ConsumerStatefulWidget {
  const RegistrationScreen({super.key});

  @override
  ConsumerState<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends ConsumerState<RegistrationScreen> {
  static const _stepCount = 5;
  final _formKeys = List.generate(_stepCount, (_) => GlobalKey<FormState>());
  final _scroll = ScrollController();
  late final RegistrationDraft _draft;
  int _step = 0;
  bool _submitting = false;
  String? _submitError;
  Map<String, String> _serverErrors = const {};

  @override
  void initState() {
    super.initState();
    _draft = RegistrationDraft();
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  List<String> _titles(BuildContext context) {
    final l10n = context.l10n;
    return [l10n.stepPersonal, l10n.stepStatus, l10n.stepCommunity, l10n.stepAddress, l10n.stepDisability];
  }

  /// Which step owns a server error field.
  static int _stepForField(String field) {
    if (field.startsWith('permanentAddress') || field.startsWith('currentAddress')) return 3;
    return switch (field) {
      'fullName' || 'fatherName' || 'motherName' || 'dateOfBirth' || 'genderId' => 0,
      'memberStatusId' || 'classId' || 'highestEducationLevelId' => 1,
      'templeId' || 'organisationId' => 2,
      _ => 4,
    };
  }

  void _fieldChanged(String field) {
    if (_serverErrors.containsKey(field)) {
      setState(() => _serverErrors = Map.of(_serverErrors)..remove(field));
    }
  }

  void _goTo(int step) {
    setState(() => _step = step);
    if (_scroll.hasClients) _scroll.jumpTo(0);
  }

  Future<void> _next() async {
    FocusScope.of(context).unfocus();
    if (!_formKeys[_step].currentState!.validate()) {
      showSnack(context, context.l10n.fixHighlightedFields);
      return;
    }
    if (_step < _stepCount - 1) {
      _goTo(_step + 1);
    } else {
      await _submit();
    }
  }

  Future<void> _back() async {
    if (_step > 0) {
      _goTo(_step - 1);
      return;
    }
    if (await _confirmLeave() && mounted) _leave();
  }

  void _leave() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(Routes.home);
    }
  }

  Future<bool> _confirmLeave() async {
    final l10n = context.l10n;
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(l10n.leaveRegistrationTitle),
            content: Text(l10n.leaveRegistrationBody),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.cancel)),
              TextButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.leave)),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _submit() async {
    final l10n = context.l10n;
    setState(() {
      _submitting = true;
      _submitError = null;
    });
    try {
      final disabilityTypes = await ref.read(masterDataProvider(MasterDataTypes.disabilityTypes).future);
      final otherId = disabilityTypes.where((t) => t.code == MasterCodes.disabilityOther).firstOrNull?.id;

      final result = await ref.read(memberRepositoryProvider).register(_draft.toJson(otherDisabilityTypeId: otherId));

      // A newly added disability type / taluk should show up in lists from now on.
      ref.invalidate(masterDataProvider(MasterDataTypes.disabilityTypes));
      final session = ref.read(sessionProvider.notifier);
      await session.refreshAccount();
      session.selectMember(result.registrationId);

      if (mounted) {
        context.go(
          Routes.registrationComplete,
          extra: RegistrationCompleteArgs(result: result, isStudent: _draft.showsClassStudying),
        );
      }
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _serverErrors = e.fieldErrors;
        _submitError = describeError(l10n, e);
      });
      if (e.fieldErrors.isNotEmpty) {
        final firstStep = e.fieldErrors.keys.map(_stepForField).reduce((a, b) => a < b ? a : b);
        _goTo(firstStep);
        showSnack(context, l10n.fixHighlightedFields);
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final titles = _titles(context);
    final isLast = _step == _stepCount - 1;
    final hasMembers = ref.watch(sessionProvider.select((s) => s.hasMembers));

    final steps = <Widget>[
      PersonalDetailsStep(draft: _draft, serverErrors: _serverErrors, onFieldChanged: _fieldChanged),
      CurrentStatusStep(draft: _draft, serverErrors: _serverErrors, onFieldChanged: _fieldChanged),
      CommunityStep(draft: _draft, serverErrors: _serverErrors, onFieldChanged: _fieldChanged),
      AddressStep(draft: _draft, serverErrors: _serverErrors, onFieldChanged: _fieldChanged),
      DisabilityStep(draft: _draft, serverErrors: _serverErrors, onFieldChanged: _fieldChanged),
    ];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(hasMembers ? l10n.addFamilyMember : l10n.registrationTitle),
          leading: _step > 0 || hasMembers ? BackButton(onPressed: _back) : null,
          automaticallyImplyLeading: false,
          actions: [
            if (!hasMembers)
              IconButton(
                tooltip: l10n.signOut,
                icon: const Icon(Icons.logout),
                onPressed: () => ref.read(sessionProvider.notifier).signOut(),
              ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(56),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${l10n.stepOf(_step + 1, _stepCount)} · ${titles[_step]}',
                    key: const Key('stepTitle'),
                    style: theme.textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(value: (_step + 1) / _stepCount, minHeight: 6),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            controller: _scroll,
            child: ResponsiveBody(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_submitError != null && _serverErrors.isEmpty) ...[
                    ErrorBanner(message: _submitError!),
                    const SizedBox(height: 16),
                  ],
                  for (var i = 0; i < _stepCount; i++)
                    // Every step stays alive (keeping typed values) but only the current one is shown.
                    Offstage(
                      offstage: i != _step,
                      child: TickerMode(
                        enabled: i == _step,
                        child: Form(key: _formKeys[i], child: steps[i]),
                      ),
                    ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: ResponsiveBody(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Row(
              children: [
                if (_step > 0) ...[
                  Expanded(
                    child: OutlinedButton(onPressed: _submitting ? null : _back, child: Text(l10n.back)),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  flex: 2,
                  child: PrimaryButton(
                    key: const Key('nextButton'),
                    label: isLast ? l10n.completeRegistration : l10n.next,
                    loading: _submitting,
                    onPressed: _next,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
