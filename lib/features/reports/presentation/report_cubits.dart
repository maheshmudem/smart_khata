import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_khata/core/date_time/business_date.dart';
import 'package:smart_khata/core/date_time/date_range.dart';
import 'package:smart_khata/core/domain/ledger_enums.dart';
import 'package:smart_khata/core/domain/submission_status.dart';
import 'package:smart_khata/core/errors/failure.dart';
import 'package:smart_khata/core/errors/result.dart';
import 'package:smart_khata/core/export/share_service.dart';
import 'package:smart_khata/core/logging/app_logger.dart';
import 'package:smart_khata/features/reports/domain/reports.dart';
import 'package:smart_khata/features/shop/domain/shop_repository.dart';

// ---- Period choice (WF-053) -----------------------------------------------

/// The period a report covers: a shortcut, or the owner's own two dates.
class PeriodSelection extends Equatable {
  /// A shortcut counted from [today].
  PeriodSelection.preset(DateRangePreset this.preset, BusinessDate today)
    : range = DateRange.preset(preset, today);

  /// The owner's own dates, both included.
  const PeriodSelection.custom(this.range) : preset = null;

  /// `null` for a custom range.
  final DateRangePreset? preset;
  final DateRange range;

  bool get isCustom => preset == null;

  @override
  List<Object?> get props => [preset, range];
}

// ---- Dashboard (WF-010) ---------------------------------------------------

class DashboardState extends Equatable {
  const DashboardState({
    required this.today,
    this.status = LoadStatus.loading,
    this.shopName = '',
    this.summary,
    this.activity = const [],
    this.failure,
  });

  final LoadStatus status;
  final BusinessDate today;
  final String shopName;
  final DashboardSummary? summary;
  final List<ActivityItem> activity;
  final Failure? failure;

  /// Nothing recorded yet: show first-run guidance (WF-010).
  bool get isFirstRun =>
      summary != null && summary!.partyCount == 0 && activity.isEmpty;

  DashboardState copyWith({
    LoadStatus? status,
    BusinessDate? today,
    String? shopName,
    DashboardSummary? summary,
    List<ActivityItem>? activity,
    Failure? failure,
  }) => DashboardState(
    status: status ?? this.status,
    today: today ?? this.today,
    shopName: shopName ?? this.shopName,
    summary: summary ?? this.summary,
    activity: activity ?? this.activity,
    failure: failure,
  );

  @override
  List<Object?> get props => [
    status,
    today,
    shopName,
    summary,
    activity,
    failure,
  ];
}

/// The Home screen's figures, kept live. The Home tab stays open for as
/// long as the app runs, so the business date is re-read when the app
/// comes back to the foreground ([refreshDay]).
class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit({
    required this._reports,
    required this._shops,
    required this._today,
  }) : super(DashboardState(today: _today())) {
    unawaited(_loadShop());
    _watch();
  }

  static const int activityLimit = 5;

  final ReportsRepository _reports;
  final ShopRepository _shops;
  final BusinessDate Function() _today;

  StreamSubscription<DashboardSummary>? _summarySubscription;
  StreamSubscription<List<ActivityItem>>? _activitySubscription;

  Future<void> _loadShop() async {
    final shop = (await _shops.getShop()).valueOrNull;
    if (shop != null && !isClosed) emit(state.copyWith(shopName: shop.name));
  }

  void _watch() {
    unawaited(_summarySubscription?.cancel());
    unawaited(_activitySubscription?.cancel());
    _summarySubscription = _reports
        .watchDashboard(state.today)
        .listen(
          (summary) => emit(
            state.copyWith(status: LoadStatus.loaded, summary: summary),
          ),
          onError: _onError,
        );
    _activitySubscription = _reports
        .watchRecentActivity(limit: activityLimit)
        .listen(
          (activity) => emit(state.copyWith(activity: activity)),
          onError: _onError,
        );
  }

  void _onError(Object error) => emit(
    state.copyWith(
      status: LoadStatus.failure,
      failure: FailureException.failureOf(error),
    ),
  );

  /// Moves "today" on if the business date has changed.
  void refreshDay() {
    final today = _today();
    if (today == state.today) return;
    emit(state.copyWith(today: today));
    _watch();
  }

  void retry() {
    emit(state.copyWith(status: LoadStatus.loading));
    unawaited(_loadShop());
    _watch();
  }

  @override
  Future<void> close() async {
    await _summarySubscription?.cancel();
    await _activitySubscription?.cancel();
    return super.close();
  }
}

// ---- Sharing --------------------------------------------------------------

/// Hands text or a file to the share sheet and reports only a failure to
/// open it. Opening the sheet is not proof that anything was sent, so
/// there is no "sent" state (ADR-012).
mixin ShareActions<S> on Cubit<S> {
  ShareService get shareService;
  AppLogger get shareLogger;

  /// Called when the share sheet could not be opened.
  void onShareFailed();

  Future<void> shareText(String text, {String? subject}) =>
      _share(() => shareService.shareText(text, subject: subject));

  Future<void> shareCsv({
    required String fileName,
    required String content,
    String? subject,
  }) => _share(
    () => shareService.shareFile(
      fileName: fileName,
      content: content,
      mimeType: 'text/csv',
      subject: subject,
    ),
  );

  Future<void> _share(Future<void> Function() action) async {
    try {
      await action();
    } on Object catch (error, stackTrace) {
      // Fixed text only: the shared content never reaches the log.
      shareLogger.error(
        'share failed',
        error: error.runtimeType,
        stackTrace: stackTrace,
      );
      if (!isClosed) onShareFailed();
    }
  }
}

// ---- Outstanding and aging (WF-051) ---------------------------------------

class OutstandingState extends Equatable {
  const OutstandingState({
    required this.role,
    this.status = LoadStatus.loading,
    this.report,
    this.failure,
    this.shareFailures = 0,
  });

  final PartyRole role;
  final LoadStatus status;
  final OutstandingReport? report;
  final Failure? failure;

  /// Goes up each time the share sheet could not be opened.
  final int shareFailures;

  OutstandingState copyWith({
    PartyRole? role,
    LoadStatus? status,
    OutstandingReport? Function()? report,
    Failure? failure,
    int? shareFailures,
  }) => OutstandingState(
    role: role ?? this.role,
    status: status ?? this.status,
    report: report == null ? this.report : report(),
    failure: failure,
    shareFailures: shareFailures ?? this.shareFailures,
  );

  @override
  List<Object?> get props => [role, status, report, failure, shareFailures];
}

class OutstandingCubit extends Cubit<OutstandingState>
    with ShareActions<OutstandingState> {
  OutstandingCubit({
    required this._reports,
    required this.shareService,
    required this.shareLogger,
    required this.today,
    required PartyRole role,
  }) : super(OutstandingState(role: role)) {
    unawaited(load());
  }

  final ReportsRepository _reports;
  @override
  final ShareService shareService;
  @override
  final AppLogger shareLogger;
  final BusinessDate today;

  /// Loads the report again; also called when the owner comes back from
  /// a ledger, where a payment may have changed it.
  Future<void> load() async {
    final role = state.role;
    final result = await _reports.outstanding(role: role, today: today);
    // A slower answer for a role the owner has left is dropped.
    if (isClosed || role != state.role) return;
    switch (result) {
      case Ok(:final value):
        emit(state.copyWith(status: LoadStatus.loaded, report: () => value));
      case Err(:final failure):
        emit(state.copyWith(status: LoadStatus.failure, failure: failure));
    }
  }

  void roleSelected(PartyRole role) {
    if (role == state.role) return;
    emit(
      state.copyWith(
        role: role,
        status: LoadStatus.loading,
        report: () => null,
      ),
    );
    unawaited(load());
  }

  void retry() {
    emit(state.copyWith(status: LoadStatus.loading));
    unawaited(load());
  }

  @override
  void onShareFailed() =>
      emit(state.copyWith(shareFailures: state.shareFailures + 1));
}

// ---- Period report --------------------------------------------------------

class PeriodReportState extends Equatable {
  const PeriodReportState({
    required this.period,
    this.status = LoadStatus.loading,
    this.report,
    this.failure,
  });

  final PeriodSelection period;
  final LoadStatus status;
  final PeriodReport? report;
  final Failure? failure;

  PeriodReportState copyWith({
    PeriodSelection? period,
    LoadStatus? status,
    PeriodReport? report,
    Failure? failure,
  }) => PeriodReportState(
    period: period ?? this.period,
    status: status ?? this.status,
    report: report ?? this.report,
    failure: failure,
  );

  @override
  List<Object?> get props => [period, status, report, failure];
}

class PeriodReportCubit extends Cubit<PeriodReportState> {
  PeriodReportCubit({required this._reports, required this.today})
    : super(
        PeriodReportState(
          period: PeriodSelection.preset(DateRangePreset.today, today),
        ),
      ) {
    unawaited(_load());
  }

  final ReportsRepository _reports;
  final BusinessDate today;

  Future<void> _load() async {
    final period = state.period;
    final result = await _reports.period(period.range);
    if (isClosed || period != state.period) return;
    switch (result) {
      case Ok(:final value):
        emit(state.copyWith(status: LoadStatus.loaded, report: value));
      case Err(:final failure):
        emit(state.copyWith(status: LoadStatus.failure, failure: failure));
    }
  }

  /// An end date before the start date is ignored (WF-053).
  void periodSelected(PeriodSelection period) {
    if (period == state.period || !period.range.isValid) return;
    emit(state.copyWith(period: period, status: LoadStatus.loading));
    unawaited(_load());
  }

  void retry() {
    emit(state.copyWith(status: LoadStatus.loading));
    unawaited(_load());
  }
}

// ---- Party statement (WF-052) ---------------------------------------------

class StatementState extends Equatable {
  const StatementState({
    required this.period,
    this.status = LoadStatus.loading,
    this.shopName = '',
    this.statement,
    this.failure,
    this.shareFailures = 0,
  });

  final PeriodSelection period;
  final LoadStatus status;
  final String shopName;
  final PartyStatement? statement;
  final Failure? failure;
  final int shareFailures;

  StatementState copyWith({
    PeriodSelection? period,
    LoadStatus? status,
    String? shopName,
    PartyStatement? statement,
    Failure? failure,
    int? shareFailures,
  }) => StatementState(
    period: period ?? this.period,
    status: status ?? this.status,
    shopName: shopName ?? this.shopName,
    statement: statement ?? this.statement,
    failure: failure,
    shareFailures: shareFailures ?? this.shareFailures,
  );

  @override
  List<Object?> get props => [
    period,
    status,
    shopName,
    statement,
    failure,
    shareFailures,
  ];
}

/// One party account's statement for a period. It is what the owner sees
/// in the preview that gets shared, nothing more.
class StatementCubit extends Cubit<StatementState>
    with ShareActions<StatementState> {
  StatementCubit({
    required this._reports,
    required this._shops,
    required this.shareService,
    required this.shareLogger,
    required this.accountId,
    required this.today,
  }) : super(
         StatementState(
           period: PeriodSelection.preset(DateRangePreset.allTime, today),
         ),
       ) {
    unawaited(_loadShop());
    unawaited(_load());
  }

  final ReportsRepository _reports;
  final ShopRepository _shops;
  @override
  final ShareService shareService;
  @override
  final AppLogger shareLogger;
  final String accountId;
  final BusinessDate today;

  Future<void> _loadShop() async {
    final shop = (await _shops.getShop()).valueOrNull;
    if (shop != null && !isClosed) emit(state.copyWith(shopName: shop.name));
  }

  Future<void> _load() async {
    final period = state.period;
    final result = await _reports.statement(
      accountId: accountId,
      range: period.range,
    );
    if (isClosed || period != state.period) return;
    switch (result) {
      case Ok(value: final PartyStatement statement):
        emit(state.copyWith(status: LoadStatus.loaded, statement: statement));
      case Ok():
        emit(
          state.copyWith(
            status: LoadStatus.failure,
            failure: const NotFoundFailure('party_account'),
          ),
        );
      case Err(:final failure):
        emit(state.copyWith(status: LoadStatus.failure, failure: failure));
    }
  }

  void periodSelected(PeriodSelection period) {
    if (period == state.period || !period.range.isValid) return;
    emit(state.copyWith(period: period, status: LoadStatus.loading));
    unawaited(_load());
  }

  void retry() {
    emit(state.copyWith(status: LoadStatus.loading));
    unawaited(_load());
  }

  @override
  void onShareFailed() =>
      emit(state.copyWith(shareFailures: state.shareFailures + 1));
}
