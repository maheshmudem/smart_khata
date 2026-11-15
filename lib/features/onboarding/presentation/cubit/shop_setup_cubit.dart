import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_khata/core/domain/submission_status.dart';
import 'package:smart_khata/core/errors/failure.dart';
import 'package:smart_khata/core/errors/result.dart';
import 'package:smart_khata/features/shop/domain/create_shop.dart';
import 'package:smart_khata/features/shop/domain/shop.dart';
import 'package:smart_khata/features/shop/domain/shop_repository.dart';

class ShopSetupState extends Equatable {
  const ShopSetupState({
    this.name = '',
    this.ownerName = '',
    this.phone = '',
    this.address = '',
    this.locality = '',
    this.errors = const {},
    this.status = SubmissionStatus.idle,
    this.failure,
  });

  final String name;
  final String ownerName;
  final String phone;
  final String address;
  final String locality;
  final Map<String, ValidationError> errors;
  final SubmissionStatus status;
  final Failure? failure;

  ShopSetupState copyWith({
    String? name,
    String? ownerName,
    String? phone,
    String? address,
    String? locality,
    Map<String, ValidationError>? errors,
    SubmissionStatus? status,
    Failure? failure,
  }) => ShopSetupState(
    name: name ?? this.name,
    ownerName: ownerName ?? this.ownerName,
    phone: phone ?? this.phone,
    address: address ?? this.address,
    locality: locality ?? this.locality,
    errors: errors ?? this.errors,
    status: status ?? this.status,
    // A failure belongs to one attempt; it is cleared unless set again.
    failure: failure,
  );

  @override
  List<Object?> get props => [
    name,
    ownerName,
    phone,
    address,
    locality,
    errors,
    status,
    failure,
  ];
}

/// WF-002. Creates the shop; if one already exists (setup was interrupted
/// after saving) it reports success straight away so setup resumes.
class ShopSetupCubit extends Cubit<ShopSetupState> {
  ShopSetupCubit({required this._createShop, required this._shops})
    : super(const ShopSetupState());

  final CreateShop _createShop;
  final ShopRepository _shops;

  Future<void> resumeIfShopExists() async {
    final result = await _shops.getShop();
    if (isClosed) return;
    if (result case Ok(value: final shop?)) {
      emit(state.copyWith(name: shop.name, status: SubmissionStatus.success));
    }
  }

  void nameChanged(String value) => emit(
    state.copyWith(
      name: value,
      errors: _without(CreateShopCommand.nameField),
      status: SubmissionStatus.idle,
    ),
  );

  void phoneChanged(String value) => emit(
    state.copyWith(
      phone: value,
      errors: _without(CreateShopCommand.phoneField),
      status: SubmissionStatus.idle,
    ),
  );

  void ownerNameChanged(String value) => emit(state.copyWith(ownerName: value));

  void addressChanged(String value) => emit(state.copyWith(address: value));

  void localityChanged(String value) => emit(state.copyWith(locality: value));

  Future<void> submit({
    required String localeCode,
    required String cashAccountName,
    List<String> defaultExpenseCategories = const [],
  }) async {
    if (state.status.isSubmitting) return;
    emit(state.copyWith(status: SubmissionStatus.submitting));

    final result = await _createShop(
      CreateShopCommand(
        name: state.name,
        ownerName: state.ownerName,
        phone: state.phone,
        address: state.address,
        locality: state.locality,
        localeCode: localeCode,
        cashAccountName: cashAccountName,
        defaultExpenseCategories: defaultExpenseCategories,
      ),
    );
    if (isClosed) return;

    emit(switch (result) {
      Ok() => state.copyWith(status: SubmissionStatus.success),
      Err(failure: ValidationFailure(:final errors)) => state.copyWith(
        errors: errors,
        status: SubmissionStatus.idle,
      ),
      Err(:final failure) => state.copyWith(
        status: SubmissionStatus.failure,
        failure: failure,
      ),
    });
  }

  Map<String, ValidationError> _without(String field) =>
      {...state.errors}..remove(field);
}
