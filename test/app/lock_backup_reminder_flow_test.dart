import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:smart_khata/app/app.dart';
import 'package:smart_khata/app/di/injection.dart';
import 'package:smart_khata/app/localization/locale_cubit.dart';
import 'package:smart_khata/core/app_info.dart';
import 'package:smart_khata/core/date_time/business_date.dart';
import 'package:smart_khata/core/domain/ledger_enums.dart';
import 'package:smart_khata/core/money/money.dart';
import 'package:smart_khata/features/ledger/domain/ledger_models.dart';
import 'package:smart_khata/features/parties/domain/party_commands.dart';
import 'package:smart_khata/features/security/presentation/lock_screen.dart';

import '../helpers/app_driver.dart';
import '../helpers/fakes.dart';
import '../helpers/pump_app.dart';
import '../helpers/test_env.dart';

/// Phase 6 journeys through the whole app: app lock, backup and restore
/// screens, reminders and help (WF-060, WF-070 to WF-072, WF-082, WF-083).
void main() {
  final en = l10nFor(AppLocales.english);

  late TestEnv env;

  /// A day of November 2026 as the app writes it in English.
  String day(int d) => DateFormat.yMMMd('en').format(DateTime(2026, 11, d));

  setUp(() => env = AppDriver.configure());
  tearDown(getIt.reset);

  Future<void> openFromMore(WidgetTester tester, String tile) async {
    await tester.tapAndSettle(inNavBar(en.navMore));
    await tester.tapAndSettle(find.text(tile));
  }

  void leaveAndReturn(WidgetTester tester) {
    tester.binding
      ..handleAppLifecycleStateChanged(AppLifecycleState.paused)
      ..handleAppLifecycleStateChanged(AppLifecycleState.resumed);
  }

  group('app lock', () {
    testWidgets('set a PIN, leave the app, and unlock with the PIN', (
      tester,
    ) async {
      await tester.pumpSmartKhata(env, tallScreen: true);
      await openFromMore(tester, en.securityTitle);
      expect(find.text(en.securityOff), findsOneWidget);
      expect(find.text(en.securityExplain), findsOneWidget);

      await tester.tapAndSettle(find.text(en.actionSetPin));
      // The two PINs must agree; nothing is saved while they differ.
      await tester.type(en.newPinLabel, '1234');
      await tester.type(en.confirmPinLabel, '1235');
      await tester.tapAndSettle(find.text(en.actionSave));
      expect(find.text(en.validationDoesNotMatch), findsOneWidget);
      expect(env.secrets.values, isEmpty);

      await tester.type(en.confirmPinLabel, '1234');
      await tester.tapAndSettle(find.text(en.actionSave));
      expect(find.text(en.pinSaved), findsOneWidget);
      expect(find.text(en.securityOn), findsOneWidget);
      // Setting the PIN does not lock the owner out at once.
      expect(find.byType(LockScreen), findsNothing);

      leaveAndReturn(tester);
      await tester.settle();
      expect(find.byType(LockScreen), findsOneWidget);
      expect(find.text(en.lockTitle), findsOneWidget);
      // The app underneath is not on screen.
      expect(find.text(en.securityOn), findsNothing);

      await tester.type(en.pinLabel, '9999');
      await tester.tapAndSettle(find.text(en.actionUnlock));
      expect(find.text(en.lockWrongPin(4)), findsOneWidget);
      expect(find.byType(LockScreen), findsOneWidget);

      await tester.type(en.pinLabel, '1234');
      await tester.tapAndSettle(find.text(en.actionUnlock));
      expect(find.byType(LockScreen), findsNothing);
      // Back where the owner was.
      expect(find.text(en.securityOn), findsOneWidget);
    });

    testWidgets('a shop with a PIN opens locked, then turns the lock off', (
      tester,
    ) async {
      await tester.pumpSmartKhata(
        env,
        tallScreen: true,
        seed: () => env.appLock.setPin('2468'),
      );
      expect(find.byType(LockScreen), findsOneWidget);
      expect(find.text(en.dashQuickActions), findsNothing);

      await tester.type(en.pinLabel, '2468');
      await tester.tapAndSettle(find.text(en.actionUnlock));
      expect(find.text(en.dashQuickActions), findsOneWidget);

      await openFromMore(tester, en.securityTitle);
      await tester.tapAndSettle(find.text(en.actionTurnOffLock));
      await tester.type(en.currentPinLabel, '0000');
      await tester.tapAndSettle(
        find.widgetWithText(FilledButton, en.actionTurnOffLock),
      );
      expect(find.text(en.errorWrongPin), findsOneWidget);

      await tester.type(en.currentPinLabel, '2468');
      await tester.tapAndSettle(
        find.widgetWithText(FilledButton, en.actionTurnOffLock),
      );
      expect(find.text(en.lockTurnedOff), findsOneWidget);
      expect(find.text(en.securityOff), findsOneWidget);

      leaveAndReturn(tester);
      await tester.settle();
      expect(find.byType(LockScreen), findsNothing);
    });
  });

  group('backup and restore screens', () {
    testWidgets('create a backup; Home then shows its date', (tester) async {
      await tester.pumpSmartKhata(env, tallScreen: true);
      expect(find.text(en.dashNoBackup), findsOneWidget);

      await tester.tapAndSettle(find.text(en.dashNoBackup));
      expect(find.text(en.backupTitle), findsOneWidget);
      expect(find.text(en.backupNoCloudNote), findsOneWidget);

      await tester.tapAndSettle(find.text(en.actionCreateBackup));
      expect(find.text(en.passphraseForgetWarning), findsOneWidget);
      await tester.type(en.passphraseLabel, 'short');
      await tester.type(en.passphraseAgainLabel, 'short');
      await tester.tapAndSettle(find.text(en.actionCreateAndSave));
      expect(find.text(en.validationPassphraseTooShort), findsOneWidget);
      expect(env.fakeBackup.saved, isEmpty);

      // Closing the file picker is not a backup.
      env.backupFiles.cancelSave = true;
      await tester.type(en.passphraseLabel, 'paddy field 42');
      await tester.type(en.passphraseAgainLabel, 'paddy field 42');
      await tester.tapAndSettle(find.text(en.actionCreateAndSave));
      expect(find.text(en.backupNotSaved), findsOneWidget);
      expect(env.fakeBackup.saved, isEmpty);
      await tester.waitForSnackBarToGo();

      env.backupFiles.cancelSave = false;
      await tester.tapAndSettle(find.text(en.actionCreateAndSave));
      expect(find.text(en.backupSaved), findsOneWidget);
      expect(env.backupFiles.saved.keys.single, endsWith('.skbak'));
      expect(env.fakeBackup.saved, hasLength(1));

      // Back on the backup page, and on Home, the date replaces the
      // warning.
      expect(find.text(en.dashNoBackup), findsNothing);
      await tester.pageBack();
      await tester.settle();
      expect(find.text(en.backupLastOn(day(14))), findsOneWidget);
      expect(find.text(en.dashNoBackup), findsNothing);
    });

    testWidgets('restore: wrong passphrase, preview, confirm', (tester) async {
      await tester.pumpSmartKhata(env, tallScreen: true);
      await openFromMore(tester, en.backupTitle);
      await tester.tapAndSettle(find.text(en.actionRestoreBackup));
      expect(find.text(en.restoreExplain), findsOneWidget);
      expect(find.text(en.restoreSafetyNote), findsOneWidget);

      env.backupFiles.toPick = Uint8List.fromList([1, 2, 3]);
      await tester.tapAndSettle(find.text(en.actionChooseBackupFile));
      await tester.type(en.passphraseLabel, 'not the words');
      await tester.tapAndSettle(find.text(en.actionCheckBackup));
      expect(find.text(en.backupErrorWrongPassphrase), findsOneWidget);

      await tester.type(en.passphraseLabel, 'paddy field 42');
      await tester.tapAndSettle(find.text(en.actionCheckBackup));
      expect(find.text(en.restoreCheckedTitle), findsOneWidget);
      expect(find.text(FakeBackupRepository.manifest.shopName), findsOneWidget);
      expect(find.text('152'), findsOneWidget);
      expect(find.text(en.restoreReplaceWarning), findsOneWidget);
      expect(env.fakeBackup.installed, isEmpty);

      // The owner must confirm in a dialog that names the action.
      await tester.tapAndSettle(find.text(en.actionReplaceRecords));
      expect(find.text(en.restoreConfirmTitle), findsOneWidget);
      await tester.tapAndSettle(find.text(en.actionCancel));
      expect(env.fakeBackup.installed, isEmpty);

      await tester.tapAndSettle(find.text(en.actionReplaceRecords));
      // After this the real app restarts; here the page just keeps its
      // spinner, so the test pumps instead of waiting for it to settle.
      await tester.tap(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text(en.actionReplaceRecords),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(env.fakeBackup.installed, hasLength(1));
    });

    testWidgets('after a restart the app says what the restore came to', (
      tester,
    ) async {
      await tester.pumpSmartKhata(
        env,
        tallScreen: true,
        startupNotice: StartupNotice.restored,
      );
      expect(find.text(en.restoreDone), findsOneWidget);
    });

    testWidgets('a restore that could not be put in place is not shown as '
        'done', (tester) async {
      await tester.pumpSmartKhata(
        env,
        tallScreen: true,
        startupNotice: StartupNotice.restoreFailed,
      );
      expect(find.text(en.backupErrorNotInstalled), findsOneWidget);
      expect(find.text(en.restoreDone), findsNothing);
    });

    testWidgets('a new phone can restore before setting up a shop', (
      tester,
    ) async {
      await tester.pumpSmartKhata(env, onboarded: false, tallScreen: true);
      await tester.tapAndSettle(find.text(en.actionRestoreBackup));
      expect(find.text(en.restoreExplain), findsOneWidget);
      expect(find.text(en.actionChooseBackupFile), findsOneWidget);
    });
  });

  group('reminders', () {
    Future<void> seed() async {
      final ravi = await env.addParty(
        const SavePartyCommand(
          displayName: 'Ravi',
          roles: {PartyRole.customer},
        ),
      );
      await env.recordCharge(
        RecordChargeCommand(
          operationId: 'seed-credit',
          role: PartyRole.customer,
          partyId: ravi,
          accountId: await env.accountId(ravi, 'customer'),
          amount: Money.fromPaise(50000),
          date: BusinessDate(2026, 11, 1),
          dueDate: BusinessDate(2026, 11, 10),
        ),
      );
    }

    testWidgets('share a reminder the owner has read; set and cancel one', (
      tester,
    ) async {
      await tester.pumpSmartKhata(env, tallScreen: true, seed: seed);
      await openFromMore(tester, en.remindersTitle);
      expect(find.text(en.remindersExplainCustomers), findsOneWidget);
      expect(find.text('Ravi'), findsOneWidget);
      expect(find.textContaining(en.reminderOverdue('₹500')), findsOneWidget);

      // The message is shown first; nothing goes out without a tap.
      await tester.tapAndSettle(find.text(en.actionShareReminder));
      final message = en.reminderMessage('Ravi', '₹500', 'Test Kirana');
      expect(find.text(message), findsOneWidget);
      expect(env.share.shared, isEmpty);
      await tester.tapAndSettle(
        find.widgetWithText(FilledButton, en.actionShareReminder),
      );
      expect(env.share.shared.single.content, message);
      // Only that the sheet was opened is noted; no "sent".
      expect(find.text(en.reminderLastShared(day(15))), findsOneWidget);
      expect(find.byType(SnackBar), findsNothing);

      // A second reminder so soon is questioned in the preview.
      await tester.tapAndSettle(find.text(en.actionShareReminder));
      expect(
        find.text(en.reminderSharedRecently(day(15))),
        findsOneWidget,
      );
      await tester.tapAndSettle(find.text(en.actionCancel));

      // The owner's own reminder: pick tomorrow in the date picker.
      await tester.tapAndSettle(find.text(en.actionRemindMe));
      await tester.tapAndSettle(find.text('OK'));
      expect(find.text(en.reminderSet), findsOneWidget);
      expect(env.notifier.scheduled, hasLength(1));
      // The notification names nobody.
      expect(env.notifier.texts.single.body, isNot(contains('Ravi')));
      expect(find.text(en.reminderSetFor(day(16))), findsOneWidget);
      await tester.waitForSnackBarToGo();

      await tester.tapAndSettle(find.text(en.actionCancelReminder));
      expect(find.text(en.reminderCancelled), findsOneWidget);
      expect(env.notifier.scheduled, isEmpty);
    });

    testWidgets('with notifications off the owner is told how to fix it', (
      tester,
    ) async {
      env.notifier.permission = false;
      await tester.pumpSmartKhata(env, tallScreen: true, seed: seed);
      await openFromMore(tester, en.remindersTitle);
      await tester.tapAndSettle(find.text(en.actionRemindMe));
      await tester.tapAndSettle(find.text('OK'));
      expect(find.text(en.reminderNotificationsOff), findsOneWidget);
      expect(find.text(en.actionCancelReminder), findsNothing);
    });
  });

  testWidgets('help says where the records are and shows the version', (
    tester,
  ) async {
    await tester.pumpSmartKhata(env, tallScreen: true);
    await openFromMore(tester, en.helpTitle);
    expect(find.text(en.helpDataNoNetwork), findsOneWidget);
    expect(find.text(en.helpDataUninstall), findsOneWidget);
    expect(find.text(en.helpVersion(AppInfo.version)), findsOneWidget);
    // No contact is shown until a real one is configured.
    expect(find.text(en.helpSupportTitle), findsNothing);
  });
}
