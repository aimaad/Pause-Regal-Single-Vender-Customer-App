import 'package:erestroSingleVender/data/repositories/cart/cartRepository.dart';
import 'package:erestroSingleVender/utils/apiMessageAndCodeException.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@immutable
abstract class ClearCartState {}

class ClearCartInitial extends ClearCartState {}

class ClearCart extends ClearCartState {
  //to clearCart
  final String? userId, productVariantId;

  ClearCart({this.userId, this.productVariantId});
}

class ClearCartProgress extends ClearCartState {
  ClearCartProgress();
}

class ClearCartSuccess extends ClearCartState {
  ClearCartSuccess();
}

class ClearCartFailure extends ClearCartState {
  final String errorMessage, errorStatusCode;
  ClearCartFailure(this.errorMessage, this.errorStatusCode);
}

class ClearCartCubit extends Cubit<ClearCartState> {
  final CartRepository _cartRepository;
  ClearCartCubit(this._cartRepository) : super(ClearCartInitial());

  //to clearCart user
  void clearCart({
    String? branchId,
  }) {
    //emitting clearCartProgress state
    emit(ClearCartProgress());
    //clearCart user in api
    _cartRepository
        .clearCart(
      branchId: branchId,
    )
        .then((result) {
      emit(ClearCartSuccess());
    }).catchError((e) {
      ApiMessageAndCodeException cartException = e;
      emit(ClearCartFailure(cartException.errorMessage.toString(),
          cartException.errorStatusCode.toString()));
    });
  }
}
