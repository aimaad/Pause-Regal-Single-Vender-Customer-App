import 'package:erestroSingleVender/data/model/transactionModel.dart';
import 'package:erestroSingleVender/utils/api.dart';
import 'package:erestroSingleVender/utils/apiMessageAndCodeException.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:erestroSingleVender/utils/apiBodyParameterLabels.dart';

@immutable
abstract class TransactionState {}

class TransactionInitial extends TransactionState {}

class TransactionProgress extends TransactionState {}

class TransactionSuccess extends TransactionState {
  final List<TransactionModel> transactionList;
  final int totalData;
  final bool hasMore;
  TransactionSuccess(this.transactionList, this.totalData, this.hasMore);
}

class TransactionFailure extends TransactionState {
  final String errorMessage, errorStatusCode;
  TransactionFailure(this.errorMessage, this.errorStatusCode);
}

String? totalHasMore;

class TransactionCubit extends Cubit<TransactionState> {
  TransactionCubit() : super(TransactionInitial());
  Future<List<TransactionModel>> _fetchData(
      {required String limit, String? offset, String? transactionType}) async {
    try {
      final body = {
        limitKey: limit,
        offsetKey: offset ?? "",
        transactionTypeKey: transactionType ?? ""
      };
      if (offset == null) {
        body.remove(offset);
      }
      final result = await Api.post(
          body: body, url: Api.transactionsUrl, token: true, errorCode: true);
      totalHasMore = result[totalKey].toString();
      return (result[dataKey] as List)
          .map((e) => TransactionModel.fromJson(e))
          .toList();
    } catch (e) {
      ApiMessageAndCodeException apiMessageAndCodeException =
          e as ApiMessageAndCodeException;
      throw ApiMessageAndCodeException(
          errorMessage: apiMessageAndCodeException.errorMessage,
          errorStatusCode: apiMessageAndCodeException.errorStatusCode);
    }
  }

  void fetchTransaction(String limit, String? transactionType) {
    emit(TransactionProgress());
    _fetchData(limit: limit, transactionType: transactionType).then((value) {
      final List<TransactionModel> usersDetails = value;
      final total = int.parse(totalHasMore!);
      emit(TransactionSuccess(
        usersDetails,
        total,
        total > usersDetails.length,
      ));
    }).catchError((e) {
      ApiMessageAndCodeException apiMessageAndCodeException = e;
      emit(TransactionFailure(
          apiMessageAndCodeException.errorMessage.toString(),
          apiMessageAndCodeException.errorStatusCode.toString()));
    });
  }

  void fetchMoreTransactionData(String limit, String? transactionType) {
    _fetchData(
            limit: limit,
            offset:
                (state as TransactionSuccess).transactionList.length.toString(),
            transactionType: transactionType)
        .then((value) {
      final oldState = (state as TransactionSuccess);
      final List<TransactionModel> usersDetails = value;
      final List<TransactionModel> updatedUserDetails =
          List.from(oldState.transactionList);
      updatedUserDetails.addAll(usersDetails);
      emit(TransactionSuccess(updatedUserDetails, oldState.totalData,
          oldState.totalData > updatedUserDetails.length));
    }).catchError((e) {
      ApiMessageAndCodeException apiMessageAndCodeException = e;
      emit(TransactionFailure(
          apiMessageAndCodeException.errorMessage.toString(),
          apiMessageAndCodeException.errorStatusCode.toString()));
    });
  }

  bool hasMoreData() {
    if (state is TransactionSuccess) {
      return (state as TransactionSuccess).hasMore;
    } else {
      return false;
    }
  }

  void addTransaction(TransactionModel transactionModel) {
    if (state is TransactionSuccess) {
      List<TransactionModel> currentTransaction =
          (state as TransactionSuccess).transactionList;
      int offset = (state as TransactionSuccess).totalData;
      bool limit = (state as TransactionSuccess).hasMore;
      currentTransaction.insert(0, transactionModel);
      emit(TransactionSuccess(
          List<TransactionModel>.from(currentTransaction), offset, limit));
    }
  }

  List<TransactionModel> getTransactionList() {
    if (state is TransactionSuccess) {
      final transactionList = (state as TransactionSuccess).transactionList;
      return transactionList;
    }
    return [];
  }
}
