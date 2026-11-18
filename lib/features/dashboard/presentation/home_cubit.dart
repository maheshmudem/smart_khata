import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_khata/core/errors/load_state.dart';
import 'package:smart_khata/core/errors/result.dart';
import 'package:smart_khata/features/dashboard/domain/dashboard.dart';

/// WF-010: the live dashboard summary.
class HomeCubit extends Cubit<LoadState<DashboardSummary>> {
  HomeCubit(this._dashboard) : super(const Loading()) {
    _subscribe();
  }

  final DashboardRepository _dashboard;
  StreamSubscription<Result<DashboardSummary>>? _subscription;

  void _subscribe() {
    unawaited(_subscription?.cancel());
    _subscription = _dashboard.watchSummary().listen(
      (result) => emit(LoadState.from(result)),
    );
  }

  void retry() {
    emit(const Loading());
    _subscribe();
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
