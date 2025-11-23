import 'package:erestroSingleVender/data/model/orderModel.dart';
import 'package:erestroSingleVender/utils/api.dart';
import 'package:erestroSingleVender/utils/apiMessageAndCodeException.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:erestroSingleVender/utils/apiBodyParameterLabels.dart';

@immutable
abstract class OrderAgainState {}

class OrderAgainInitial extends OrderAgainState {}

class OrderAgainProgress extends OrderAgainState {}

class OrderAgainSuccess extends OrderAgainState {
  final List<OrderModel> orderList;
  final int totalData;
  final bool hasMore;
  OrderAgainSuccess(this.orderList, this.totalData, this.hasMore);
}

class OrderAgainFailure extends OrderAgainState {
  final String errorMessage, errorStatusCode;
  OrderAgainFailure(this.errorMessage, this.errorStatusCode);
}

String? totalHasMore;

class OrderAgainCubit extends Cubit<OrderAgainState> {
  OrderAgainCubit() : super(OrderAgainInitial());
  Future<List<OrderModel>> _fetchData(
      {required String limit,
      String? offset,
      String? id,
      String? activeStatus,
      String? branchId}) async {
    try {
      //body of post request
      final body = {
        limitKey: limit,
        offsetKey: offset ?? "",
        branchIdKey: branchId ?? "",
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

  void fetchOrderAgain(
      String limit, String id, String activeStatus, String? branchId) {
    emit(OrderAgainProgress());
    _fetchData(
            limit: limit,
            id: id,
            activeStatus: activeStatus,
            branchId: branchId)
        .then((value) {
      final List<OrderModel> usersDetails = value;
      final total = int.parse(totalHasMore!);
      emit(OrderAgainSuccess(
        usersDetails,
        total,
        total > usersDetails.length,
      ));
    }).catchError((e) {
      ApiMessageAndCodeException apiMessageAndCodeException = e;
      emit(OrderAgainFailure(apiMessageAndCodeException.errorMessage.toString(),
          apiMessageAndCodeException.errorStatusCode.toString()));
    });
  }

  void fetchMoreOrderAgainData(
      String limit, String? id, String? activeStatus, String? branchId) {
    _fetchData(
            limit: limit,
            offset: (state as OrderAgainSuccess).orderList.length.toString(),
            id: id,
            activeStatus: activeStatus,
            branchId: branchId)
        .then((value) {
      final oldState = (state as OrderAgainSuccess);
      final List<OrderModel> usersDetails = value;
      final List<OrderModel> updatedUserDetails = List.from(oldState.orderList);
      updatedUserDetails.addAll(usersDetails);
      emit(OrderAgainSuccess(updatedUserDetails, oldState.totalData,
          oldState.totalData > updatedUserDetails.length));
    }).catchError((e) {
      ApiMessageAndCodeException apiMessageAndCodeException = e;
      emit(OrderAgainFailure(apiMessageAndCodeException.errorMessage.toString(),
          apiMessageAndCodeException.errorStatusCode.toString()));
    });
  }

  bool hasMoreData() {
    if (state is OrderAgainSuccess) {
      return (state as OrderAgainSuccess).hasMore;
    } else {
      return false;
    }
  }
}
