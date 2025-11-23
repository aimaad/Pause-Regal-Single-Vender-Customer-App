import 'package:erestroSingleVender/data/model/cartModel.dart';
import 'package:erestroSingleVender/data/repositories/order/orderRepository.dart';
import 'package:erestroSingleVender/utils/apiBodyParameterLabels.dart';
import 'package:erestroSingleVender/utils/apiMessageAndCodeException.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@immutable
abstract class ReOrderState {}

class ReOrderInitial extends ReOrderState {}

class ReOrder extends ReOrderState {
  //to ReOrder
  final String? userId, productVariantId;

  ReOrder({this.userId, this.productVariantId});
}

class ReOrderProgress extends ReOrderState {
  ReOrderProgress();
}

class ReOrderSuccess extends ReOrderState {
  final List<Data> data;
  final String? totalQuantity, subTotal, taxPercentage, taxAmount;
  final double? overallAmount;
  final List<String>? variantId;
  ReOrderSuccess(this.data, this.totalQuantity, this.subTotal,
      this.taxPercentage, this.taxAmount, this.overallAmount, this.variantId);
}

class ReOrderFailure extends ReOrderState {
  final String errorMessage, errorStatusCode;
  ReOrderFailure(this.errorMessage, this.errorStatusCode);
}

class ReOrderCubit extends Cubit<ReOrderState> {
  final OrderRepository _orderRepository;
  ReOrderCubit(this._orderRepository) : super(ReOrderInitial());

  //to ReOrder
  void reOrder({String? orderId}) {
    //emitting ReOrderProgress state
    emit(ReOrderProgress());
    //ReOrder
    _orderRepository.reOrderData(orderId: orderId).then((result) {
      emit(ReOrderSuccess(
          (result['cart'] as List).map((e) => Data.fromJson(e)).toList(),
          result[dataKey]['total_quantity'],
          result[dataKey]['sub_total'],
          result[dataKey]['tax_percentage'],
          result[dataKey]['tax_amount'],
          double.parse(result[dataKey]['overall_amount']),
          result[dataKey]['variant_id']));
    }).catchError((e) {
      ApiMessageAndCodeException apiMessageAndCodeException = e;
      emit(ReOrderFailure(apiMessageAndCodeException.errorMessage.toString(),
          apiMessageAndCodeException.errorStatusCode.toString()));
    });
  }
}
