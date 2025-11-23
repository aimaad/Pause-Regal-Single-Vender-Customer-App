import 'package:erestroSingleVender/data/repositories/cart/cartRepository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/model/sectionsModel.dart';

@immutable
abstract class GetQuantityState {}

class GetQuantityInitial extends GetQuantityState {}

class GetQuantity extends GetQuantityState {
  //to GetQuantity
  final String? userId, productVariantId;

  GetQuantity({this.userId, this.productVariantId});
}

class GetQuantityProgress extends GetQuantityState {
  GetQuantityProgress();
}

// ignore: must_be_immutable
class GetQuantitySuccess extends GetQuantityState {
  String qty;
  GetQuantitySuccess(this.qty);
}

class GetQuantityFailure extends GetQuantityState {
  final String errorMessage;
  GetQuantityFailure(this.errorMessage);
}

class GetQuantityCubit extends Cubit<GetQuantityState> {
  final CartRepository _cartRepository = CartRepository();
  GetQuantityCubit() : super(GetQuantityInitial());

  //to GetQuantity user
  getQuantity(String id, ProductDetails productDetails, BuildContext context) {
    //emitting GetQuantityProgress state
    emit(GetQuantityProgress());
    //GetQuantity user in api
    _cartRepository.AllVarianntQty(id, productDetails, context).then((result) {
      emit(GetQuantitySuccess(result));
    }).catchError((e) {
      emit(GetQuantityFailure(e.toString()));
    });
  }

  fetchQty() {
    if (state is GetQuantitySuccess) {
      return (state as GetQuantitySuccess).qty.toString();
    }
    return '';
  }
}
