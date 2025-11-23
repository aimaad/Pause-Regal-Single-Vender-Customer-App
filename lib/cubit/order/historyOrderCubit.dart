import 'package:erestroSingleVender/data/model/orderModel.dart';
import 'package:erestroSingleVender/utils/api.dart';
import 'package:erestroSingleVender/utils/apiMessageAndCodeException.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:erestroSingleVender/utils/apiBodyParameterLabels.dart';

@immutable
abstract class HistoryOrderState {}

class HistoryOrderInitial extends HistoryOrderState {}

class HistoryOrderProgress extends HistoryOrderState {}

class HistoryOrderSuccess extends HistoryOrderState {
  final List<OrderModel> historyOrderList;
  final int totalData;
  final bool hasMore;
  HistoryOrderSuccess(this.historyOrderList, this.totalData, this.hasMore);
}

class HistoryOrderFailure extends HistoryOrderState {
  final String errorMessage, errorStatusCode;
  HistoryOrderFailure(this.errorMessage, this.errorStatusCode);
}

String? totalHasMore;

class HistoryOrderCubit extends Cubit<HistoryOrderState> {
  HistoryOrderCubit() : super(HistoryOrderInitial());
  Future<List<OrderModel>> _fetchData(
      {required String limit,
      String? offset,
      String? id,
      String? activeStatus,
      String? isSelfPickup}) async {
    try {
      //body of post request
      final body = {
        limitKey: limit,
        offsetKey: offset ?? "",
        idKey: id ?? "",
        isSelfPickUpKey: isSelfPickup ?? ""
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

  void fetchHistoryOrder(
      String limit, String id, String activeStatus, String isSelfPickup) {
    emit(HistoryOrderProgress());
    _fetchData(
            limit: limit,
            id: id,
            activeStatus: activeStatus,
            isSelfPickup: isSelfPickup)
        .then((value) {
      final List<OrderModel> usersDetails = value;
      final total = int.parse(totalHasMore!);
      emit(HistoryOrderSuccess(
        usersDetails,
        total,
        total > usersDetails.length,
      ));
    }).catchError((e) {
      ApiMessageAndCodeException apiMessageAndCodeException = e;
      emit(HistoryOrderFailure(
          apiMessageAndCodeException.errorMessage.toString(),
          apiMessageAndCodeException.errorStatusCode.toString()));
    });
  }

  void fetchMoreHistoryOrderData(
      String limit, String? id, String? activeStatus, String? isSelfPickup) {
    _fetchData(
            limit: limit,
            offset: (state as HistoryOrderSuccess)
                .historyOrderList
                .length
                .toString(),
            id: id,
            activeStatus: activeStatus,
            isSelfPickup: isSelfPickup)
        .then((value) {
      final oldState = (state as HistoryOrderSuccess);
      final List<OrderModel> usersDetails = value;
      final List<OrderModel> updatedUserDetails =
          List.from(oldState.historyOrderList);
      updatedUserDetails.addAll(usersDetails);
      emit(HistoryOrderSuccess(updatedUserDetails, oldState.totalData,
          oldState.totalData > updatedUserDetails.length));
    }).catchError((e) {
      ApiMessageAndCodeException apiMessageAndCodeException = e;
      emit(HistoryOrderFailure(
          apiMessageAndCodeException.errorMessage.toString(),
          apiMessageAndCodeException.errorStatusCode.toString()));
    });
  }

  bool hasMoreData() {
    if (state is HistoryOrderSuccess) {
      return (state as HistoryOrderSuccess).hasMore;
    } else {
      return false;
    }
  }

  void updateOrderRateData(OrderModel orderModel) {
    if (state is HistoryOrderSuccess) {
      List<OrderModel> currentOrder =
          (state as HistoryOrderSuccess).historyOrderList;
      bool hasMore = (state as HistoryOrderSuccess).hasMore;
      int totalData = (state as HistoryOrderSuccess).totalData;
      int i = currentOrder.indexWhere((element) => element.id == orderModel.id);
      currentOrder[i] = orderModel;

      emit(HistoryOrderSuccess(
          List<OrderModel>.from(currentOrder), totalData, hasMore));
    }
  }

  void addOrderAtBeginning(OrderModel orderModel) {
    if (state is HistoryOrderSuccess) {
      List<OrderModel> currentOrder =
          (state as HistoryOrderSuccess).historyOrderList;
      bool hasMore = (state as HistoryOrderSuccess).hasMore;
      int totalData = (state as HistoryOrderSuccess).totalData;

      // Add the new orderModel at index 0
      currentOrder.insert(0, orderModel);
      totalData++; // Update totalData as an order is added

      emit(HistoryOrderSuccess(
          List<OrderModel>.from(currentOrder), totalData, hasMore));
    }
  }
}
