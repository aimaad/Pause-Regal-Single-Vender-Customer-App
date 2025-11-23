import 'package:erestroSingleVender/data/model/orderModel.dart';
import 'package:erestroSingleVender/utils/api.dart';
import 'package:erestroSingleVender/utils/apiMessageAndCodeException.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:erestroSingleVender/utils/apiBodyParameterLabels.dart';

@immutable
abstract class OrderDetailState {}

class OrderDetailInitial extends OrderDetailState {}

class OrderDetailProgress extends OrderDetailState {}

class OrderDetailSuccess extends OrderDetailState {
  final List<OrderModel> orderList;
  final int totalData;
  final bool hasMore;
  OrderDetailSuccess(this.orderList, this.totalData, this.hasMore);
}

class OrderDetailFailure extends OrderDetailState {
  final String errorMessage, errorStatusCode;
  OrderDetailFailure(this.errorMessage, this.errorStatusCode);
}

String? totalHasMore;

class OrderDetailCubit extends Cubit<OrderDetailState> {
  OrderDetailCubit() : super(OrderDetailInitial());
  Future<List<OrderModel>> _fetchData(
      {required String limit,
      String? offset,
      String? id,
      String? activeStatus}) async {
    try {
      //body of post request
      final body = {
        limitKey: limit,
        offsetKey: offset ?? "",
        idKey: id ?? "",
      };

      if (offset == null) {
        body.remove(offset);
      }
      if (activeStatus != null) {
        body[activeStatusKey] = activeStatus;
      }
      final result = await Api.post(
          body: body, url: Api.getOrdersUrl, token: true, errorCode: true);
      totalHasMore = result[totalKey].toString();
      return (result[dataKey] as List)
          .map((e) => OrderModel.fromJson(e))
          .toList();
    } catch (e) {
      ApiMessageAndCodeException apiMessageAndCodeException =
          e as ApiMessageAndCodeException;
      throw ApiMessageAndCodeException(
          errorMessage: apiMessageAndCodeException.errorMessage,
          errorStatusCode: apiMessageAndCodeException.errorStatusCode);
    }
  }

  void fetchOrder(String limit, String id, String activeStatus) {
    emit(OrderDetailProgress());
    _fetchData(limit: limit, id: id, activeStatus: activeStatus).then((value) {
      final List<OrderModel> usersDetails = value;
      final total = int.parse(totalHasMore!);
      emit(OrderDetailSuccess(
        usersDetails,
        total,
        total > usersDetails.length,
      ));
    }).catchError((e) {
      ApiMessageAndCodeException apiMessageAndCodeException = e;
      emit(OrderDetailFailure(
          apiMessageAndCodeException.errorMessage.toString(),
          apiMessageAndCodeException.errorStatusCode.toString()));
    });
  }

  void fetchMoreOrderData(String limit, String? id, String? activeStatus) {
    _fetchData(
            limit: limit,
            offset: (state as OrderDetailSuccess).orderList.length.toString(),
            id: id,
            activeStatus: activeStatus)
        .then((value) {
      final oldState = (state as OrderDetailSuccess);
      final List<OrderModel> usersDetails = value;
      final List<OrderModel> updatedUserDetails = List.from(oldState.orderList);
      updatedUserDetails.addAll(usersDetails);
      emit(OrderDetailSuccess(updatedUserDetails, oldState.totalData,
          oldState.totalData > updatedUserDetails.length));
    }).catchError((e) {
      ApiMessageAndCodeException apiMessageAndCodeException = e;
      emit(OrderDetailFailure(
          apiMessageAndCodeException.errorMessage.toString(),
          apiMessageAndCodeException.errorStatusCode.toString()));
    });
  }

  bool hasMoreData() {
    if (state is OrderDetailSuccess) {
      return (state as OrderDetailSuccess).hasMore;
    } else {
      return false;
    }
  }

  void updateOrderRateData(OrderModel orderModel) {
    if (state is OrderDetailSuccess) {
      List<OrderModel> currentOrder = (state as OrderDetailSuccess).orderList;
      bool hasMore = (state as OrderDetailSuccess).hasMore;
      int totalData = (state as OrderDetailSuccess).totalData;
      int i = currentOrder.indexWhere((element) => element.id == orderModel.id);
      currentOrder[i] = orderModel;

      emit(OrderDetailSuccess(
          List<OrderModel>.from(currentOrder), totalData, hasMore));
    }
  }

  void removeCancelledOrder(String orderId) {
    if (state is OrderDetailSuccess) {
      List<OrderModel> currentOrder = (state as OrderDetailSuccess).orderList;
      bool hasMore = (state as OrderDetailSuccess).hasMore;
      int totalData = (state as OrderDetailSuccess).totalData;
      currentOrder.removeWhere((element) => element.id == orderId);
      emit(OrderDetailSuccess(
          List<OrderModel>.from(currentOrder), totalData, hasMore));
    }
  }
}
