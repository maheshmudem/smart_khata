import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_khata/core/errors/failure.dart';
import 'package:smart_khata/core/errors/load_state.dart';
import 'package:smart_khata/core/errors/result.dart';
import 'package:smart_khata/core/money/money.dart';
import 'package:smart_khata/features/shop/domain/shop.dart';
import 'package:smart_khata/features/shop/domain/shop_repository.dart';
import 'package:smart_khata/features/shop/domain/shop_use_cases.dart';

sealed class ShopFormEvent extends Equatable {
  const ShopFormEvent();

  @override
  List<Object?> get props => const [];
}

/// Loads the saved shop, to resume an interrupted setup or to edit.
final class ShopFormStarted extends ShopFormEvent {
  const ShopFormStarted();
}

final class ShopFormChanged extends ShopFormEvent {
  const ShopFormChanged(this.input);

  final ShopProfileInput input;

  @override
  List<Object?> get props => [input];
}

final class ShopOpeningCashChanged extends ShopFormEvent {
  const ShopOpeningCashChanged(this.amount);

  final Money? amount;

  @override
  List<Object?> get props => [amount];
}

final class ShopFormSubmitted extends ShopFormEvent {
  const ShopFormSubmitted();
}

final class ShopFormState extends Equatable {
  const ShopFormState({
    this.isLoading = true,
    this.input = const ShopProfileInput(),
    this.openingCash,
    this.errors = const {},
    this.status = SubmitStatus.idle,
    this.failure,
    this.isDirty = false,
    this.hasExistingShop = false,
  });

  /// True until the saved shop (if any) has been read.
  final bool isLoading;
  final ShopProfileInput input;
  final Money? openingCash;
  final Map<String, ValidationError> errors;
  final SubmitStatus status;

  /// Why the last save failed, when it was not a field validation.
  final Failure? failure;
  final bool isDirty;

  /// A shop already exists: setup is being resumed, or this is an edit.
  final bool hasExistingShop;

  ShopFormState copyWith({
    bool? isLoading,
    ShopProfileInput? input,
    Money? openingCash,
    bool clearOpeningCash = false,
    Map<String, ValidationError>? errors,
    SubmitStatus? status,
    Failure? failure,
    bool clearFailure = false,
    bool? isDirty,
    bool? hasExistingShop,
  }) => ShopFormState(
    isLoading: isLoading ?? this.isLoading,
    input: input ?? this.input,
    openingCash: clearOpeningCash ? null : openingCash ?? this.openingCash,
    errors: errors ?? this.errors,
    status: status ?? this.status,
    failure: clearFailure ? null : failure ?? this.failure,
    isDirty: isDirty ?? this.isDirty,
    hasExistingShop: hasExistingShop ?? this.hasExistingShop,
  );

  @override
  List<Object?> get props => [
    isLoading,
    input,
    openingCash,
    errors,
    status,
    failure,
    isDirty,
    hasExistingShop,
  ];
}

/// Shop setup (WF-002) and shop profile editing share this form.
class ShopFormBloc extends Bloc<ShopFormEvent, ShopFormState> {
  /// First-run setup in [localeCode].
  ShopFormBloc.setup({
    required ShopRepository shops,
    required SetUpShop setUpShop,
    required String localeCode,
  }) : this._(
         shops,
         (input, cash) => setUpShop(
           SetUpShopCommand(
             profile: input,
             localeCode: localeCode,
             openingCash: cash,
           ),
         ),
       );

  /// Editing the saved shop.
  ShopFormBloc.edit({
    required ShopRepository shops,
    required UpdateShopProfile updateShopProfile,
  }) : this._(shops, null, updateShopProfile);

  ShopFormBloc._(
    this._shops,
    this._create, [
    this._update,
  ]) : super(const ShopFormState()) {
    on<ShopFormStarted>(_onStarted);
    on<ShopFormChanged>(_onChanged);
    on<ShopOpeningCashChanged>(_onCashChanged);
    // A second tap while saving is ignored.
    on<ShopFormSubmitted>(_onSubmitted, transformer: droppable());
  }

  final ShopRepository _shops;
  final Future<Result<Shop>> Function(ShopProfileInput, Money?)? _create;
  final UpdateShopProfile? _update;
  String? _shopId;

  Future<void> _onStarted(
    ShopFormStarted event,
    Emitter<ShopFormState> emit,
  ) async {
    final result = await _shops.getShop();
    final shop = result.valueOrNull;
    _shopId = shop?.id;
    final profile = shop?.profile;
    emit(
      state.copyWith(
        isLoading: false,
        hasExistingShop: shop != null,
        input: profile == null
            ? null
            : ShopProfileInput(
                name: profile.name,
                ownerName: profile.ownerName ?? '',
                phone: profile.phone ?? '',
                address: profile.address ?? '',
                locality: profile.locality ?? '',
              ),
      ),
    );
  }

  void _onChanged(ShopFormChanged event, Emitter<ShopFormState> emit) {
    emit(
      state.copyWith(
        input: event.input,
        isDirty: true,
        // A field the owner is fixing should not keep shouting.
        errors: const {},
        status: SubmitStatus.idle,
        clearFailure: true,
      ),
    );
  }

  void _onCashChanged(
    ShopOpeningCashChanged event,
    Emitter<ShopFormState> emit,
  ) {
    emit(
      state.copyWith(
        openingCash: event.amount,
        clearOpeningCash: event.amount == null,
        isDirty: true,
      ),
    );
  }

  Future<void> _onSubmitted(
    ShopFormSubmitted event,
    Emitter<ShopFormState> emit,
  ) async {
    emit(state.copyWith(status: SubmitStatus.submitting, clearFailure: true));
    final shopId = _shopId;
    final update = _update;
    final create = _create;
    final Result<Shop> result;
    if (update != null && shopId != null) {
      result = await update(shopId, state.input);
    } else if (create != null) {
      result = await create(state.input, state.openingCash);
    } else {
      result = const Err(NotFoundFailure('shop'));
    }

    switch (result) {
      case Ok():
        emit(state.copyWith(status: SubmitStatus.success, isDirty: false));
      case Err(failure: ValidationFailure(:final errors)):
        emit(state.copyWith(status: SubmitStatus.failure, errors: errors));
      case Err(:final failure):
        emit(state.copyWith(status: SubmitStatus.failure, failure: failure));
    }
  }
}
