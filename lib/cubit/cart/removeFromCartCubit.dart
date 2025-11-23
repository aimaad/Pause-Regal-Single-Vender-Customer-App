import 'package:erestroSingleVender/data/repositories/cart/cartRepository.dart';
import 'package:erestroSingleVender/utils/apiMessageAndCodeException.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@immutable
abstract class RemoveFromCartState {}

class RemoveFromCartInitial extends RemoveFromCartState {}

class RemoveFromCart extends RemoveFromCartState {
  //to removeFromCart
  final String? userId, productVariantId;

  RemoveFromCart({this.userId, this.productVariantId});
}

class RemoveFromCartProgress extends RemoveFromCartState {
  RemoveFromCartProgress();
}

class RemoveFromCartSuccess extends RemoveFromCartState {
  RemoveFromCartSuccess();
}

class RemoveFromCartFailure extends RemoveFromCartState {
  final String errorMessage, errorStatusCode;
  RemoveFromCartFailure(this.errorMessage, this.errorStatusCode);
}

class RemoveFromCartCubit extends Cubit<RemoveFromCartState> {
  final CartRepository _cartRepository;
  RemoveFromCartCubit(this._cartRepository) : super(RemoveFromCartInitial());

  //to RemoveFromCart user
  void removeFromCart({String? cartId, String? branchId}) {
    //emitting removeFromCartProgress state
    emit(RemoveFromCartProgress());
    //removeFromCart user in api
    _cartRepository
        .removeFromCart(cartId: cartId, branchId: branchId)
        .then((result) {
      emit(RemoveFromCartSuccess());
    }).catchError((e) {
      ApiMessageAndCodeException apiMessageAndCodeException = e;
      emit(RemoveFromCartFailure(
          apiMessageAndCodeException.errorMessage.toString(),
          apiMessageAndCodeException.errorStatusCode.toString()));
    });
  }
}
