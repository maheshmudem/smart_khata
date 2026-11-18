import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_khata/core/errors/failure.dart';
import 'package:smart_khata/core/errors/load_state.dart';
import 'package:smart_khata/core/errors/result.dart';
import 'package:smart_khata/features/settings/domain/data_reset_repository.dart';
import 'package:smart_khata/features/shop/domain/shop.dart';
import 'package:smart_khata/features/shop/domain/shop_repository.dart';

final class MoreState extends Equatable {
  const MoreState({
    this.shop = const Loading(),
    this.resetStatus = SubmitStatus.idle,
    this.resetFailure,
  });

  final LoadState<Shop?> shop;
  final SubmitStatus resetStatus;
  final Failure? resetFailure;

  MoreState copyWith({
    LoadState<Shop?>? shop,
    SubmitStatus? resetStatus,
    Failure? resetFailure,
    bool clearResetFailure = false,
  }) => MoreState(
    shop: shop ?? this.shop,
    resetStatus: resetStatus ?? this.resetStatus,
    resetFailure: clearResetFailure ? null : resetFailure ?? this.resetFailure,
  );

  @override
  List<Object?> get props => [shop, resetStatus, resetFailure];
}

/// WF-080: the shop summary and "Reset app data" (ADR-022).
class MoreCubit extends Cubit<MoreState> {
  MoreCubit({required this._shops, required this._reset})
    : super(const MoreState()) {
    _subscription = _shops.watchShop().listen(
      (result) => emit(state.copyWith(shop: LoadState.from(result))),
    );
  }

  final ShopRepository _shops;
  final DataResetRepository _reset;
  StreamSubscription<Result<Shop?>>? _subscription;

  /// Erases every record. On success the app must restart; the page calls
  /// its restart callback when [MoreState.resetStatus] is `success`.
  Future<void> eraseAllData() async {
    if (state.resetStatus == SubmitStatus.submitting) return;
    emit(
      state.copyWith(
        resetStatus: SubmitStatus.submitting,
        clearResetFailure: true,
      ),
    );
    // Stop listening first: the database is about to be closed.
    await _subscription?.cancel();
    _subscription = null;
    final result = await _reset.eraseAllData();
    switch (result) {
      case Ok():
        emit(state.copyWith(resetStatus: SubmitStatus.success));
      case Err(:final failure):
        emit(
          state.copyWith(
            resetStatus: SubmitStatus.failure,
            resetFailure: failure,
          ),
        );
    }
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
