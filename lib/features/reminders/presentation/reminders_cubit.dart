import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_khata/core/date_time/business_date.dart';
import 'package:smart_khata/core/date_time/clock.dart';
import 'package:smart_khata/core/domain/ledger_enums.dart';
import 'package:smart_khata/core/domain/submission_status.dart';
import 'package:smart_khata/core/errors/failure.dart';
import 'package:smart_khata/core/errors/result.dart';
import 'package:smart_khata/core/export/share_service.dart';
import 'package:smart_khata/features/reminders/domain/reminders.dart';
import 'package:smart_khata/features/shop/domain/shop_repository.dart';

/// Something to tell the owner once, in a snackbar.
enum ReminderNotice {
  shareFailed,
  reminderSet,
  reminderCancelled,
  notificationsOff,
  failed,
}

class RemindersState extends Equatable {
  const RemindersState({
    required this.role,
    this.status = LoadStatus.loading,
    this.items = const [],
    this.shopName = '',
    this.failure,
    this.notice,
    this.noticeCount = 0,
  });

  final PartyRole role;
  final LoadStatus status;
  final List<DueItem> items;
  final String shopName;
  final Failure? failure;

  /// The latest notice; [noticeCount] goes up with each one so that the
  /// same notice twice is still shown twice.
  final ReminderNotice? notice;
  final int noticeCount;

  RemindersState copyWith({
    PartyRole? role,
    LoadStatus? status,
    List<DueItem>? items,
    String? shopName,
    Failure? failure,
  }) => RemindersState(
    role: role ?? this.role,
    status: status ?? this.status,
    items: items ?? this.items,
    shopName: shopName ?? this.shopName,
    failure: failure,
    notice: notice,
    noticeCount: noticeCount,
  );

  RemindersState withNotice(ReminderNotice notice) => RemindersState(
    role: role,
    status: status,
    items: items,
    shopName: shopName,
    failure: failure,
    notice: notice,
    noticeCount: noticeCount + 1,
  );

  @override
  List<Object?> get props => [
    role,
    status,
    items,
    shopName,
    failure,
    notice,
    noticeCount,
  ];
}

/// WF-060: who has dues with a due date, and the two things the owner
/// can do about each: share a reminder message, or be reminded.
class RemindersCubit extends Cubit<RemindersState> {
  RemindersCubit({
    required this._reminders,
    required this._shops,
    required this._share,
    required this._clock,
    required this.today,
    PartyRole role = PartyRole.customer,
  }) : super(RemindersState(role: role)) {
    unawaited(_loadShop());
    _watch();
  }

  final ReminderRepository _reminders;
  final ShopRepository _shops;
  final ShareService _share;
  final Clock _clock;
  final BusinessDate today;

  StreamSubscription<List<DueItem>>? _subscription;

  Future<void> _loadShop() async {
    final shop = (await _shops.getShop()).valueOrNull;
    if (shop != null && !isClosed) emit(state.copyWith(shopName: shop.name));
  }

  void _watch() {
    unawaited(_subscription?.cancel());
    _subscription = _reminders
        .watchDue(role: state.role, today: today)
        .listen(
          (items) =>
              emit(state.copyWith(status: LoadStatus.loaded, items: items)),
          onError: (Object error) => emit(
            state.copyWith(
              status: LoadStatus.failure,
              failure: FailureException.failureOf(error),
            ),
          ),
        );
  }

  void roleSelected(PartyRole role) {
    if (role == state.role) return;
    emit(
      state.copyWith(role: role, status: LoadStatus.loading, items: const []),
    );
    _watch();
  }

  void retry() {
    emit(state.copyWith(status: LoadStatus.loading));
    _watch();
  }

  /// Whether a reminder was shared with this party in the last few days.
  bool sharedRecently(DueItem item) =>
      ReminderPolicy.sharedRecently(item.lastSharedAt, _clock.nowUtc());

  /// Opens the share sheet with [message] and notes that it was opened.
  /// The app cannot know, and does not say, whether it was sent.
  Future<void> share(DueItem item, String message) async {
    try {
      await _share.shareText(message);
    } on Object {
      if (!isClosed) emit(state.withNotice(ReminderNotice.shareFailed));
      return;
    }
    await _reminders.recordShareOpened(partyId: item.partyId, role: item.role);
  }

  /// Sets the owner's own reminder for [on].
  Future<void> remindMe(
    DueItem item,
    BusinessDate on,
    ReminderTexts texts,
  ) async {
    final result = await _reminders.schedule(
      partyId: item.partyId,
      role: item.role,
      on: on,
      texts: texts,
    );
    if (isClosed) return;
    emit(
      state.withNotice(switch (result) {
        Ok(value: ScheduleOutcome.scheduled) => ReminderNotice.reminderSet,
        Ok(value: ScheduleOutcome.notificationsOff) =>
          ReminderNotice.notificationsOff,
        Err() => ReminderNotice.failed,
      }),
    );
  }

  Future<void> cancelReminder(DueItem item) async {
    final result = await _reminders.cancel(
      partyId: item.partyId,
      role: item.role,
    );
    if (isClosed) return;
    emit(
      state.withNotice(
        result.isOk ? ReminderNotice.reminderCancelled : ReminderNotice.failed,
      ),
    );
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
