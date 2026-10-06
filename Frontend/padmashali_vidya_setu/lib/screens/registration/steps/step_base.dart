import 'package:flutter/widgets.dart';

import '../../../models/registration_draft.dart';

/// What every registration step receives from the wizard.
abstract class RegistrationStep extends StatefulWidget {
  const RegistrationStep({super.key, required this.draft, required this.serverErrors, required this.onFieldChanged});

  final RegistrationDraft draft;

  /// Field errors returned by the API, keyed by JSON path (e.g. `permanentAddress.pinCode`).
  final Map<String, String> serverErrors;

  /// Notifies the wizard that a field changed, so its server error can be cleared.
  final ValueChanged<String> onFieldChanged;
}
