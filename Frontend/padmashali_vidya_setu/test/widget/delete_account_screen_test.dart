import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:padmashali_vidya_setu/core/api/api_client.dart';
import 'package:padmashali_vidya_setu/core/storage/token_storage.dart';
import 'package:padmashali_vidya_setu/providers/providers.dart';
import 'package:padmashali_vidya_setu/repositories/repositories.dart';
import 'package:padmashali_vidya_setu/screens/account/delete_account_screen.dart';

import '../helpers.dart';

class _FakeMemberRepository extends MemberRepository {
  _FakeMemberRepository()
    : super(ApiClient(baseUrl: 'http://test.invalid', tokenStorage: MemoryTokenStorage(), onSessionExpired: () {}));

  int deletions = 0;

  @override
  Future<void> deleteMyAccount() async => deletions++;
}

void main() {
  testWidgets('needs "I understand" and a confirmation, then deletes and signs out', (tester) async {
    final repo = _FakeMemberRepository();
    await pumpLocalized(
      tester,
      const SizedBox(height: 900, child: DeleteAccountScreen()),
      overrides: [...testOverrides(), memberRepositoryProvider.overrideWithValue(repo)],
    );

    expect(find.text('This mobile number cannot sign in or register again.'), findsOneWidget);
    final button = find.byKey(const Key('deleteAccountButton'));
    expect(tester.widget<ButtonStyleButton>(button).onPressed, isNull); // not before "I understand"

    await tester.tap(find.byKey(const Key('deleteAccountUnderstood')));
    await tester.pumpAndSettle();
    await tester.tap(button);
    await tester.pumpAndSettle();

    // Cancelling the confirmation deletes nothing.
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(repo.deletions, 0);

    await tester.tap(button);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('deleteAccountConfirmButton')));
    await tester.pumpAndSettle();

    expect(repo.deletions, 1);
    final session = ProviderScope.containerOf(tester.element(find.byType(DeleteAccountScreen))).read(sessionProvider);
    expect(session.status, SessionStatus.signedOut);
    expect(session.accountDeleted, isTrue);
  });
}
