import 'package:erestroSingleVender/data/model/faqsModel.dart';
import 'package:erestroSingleVender/utils/apiMessageException.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:erestroSingleVender/utils/api.dart';
import 'package:flutter/material.dart';
import 'package:erestroSingleVender/utils/apiBodyParameterLabels.dart';

@immutable
abstract class FaqsState {}

class FaqsInitial extends FaqsState {}

class FaqsProgress extends FaqsState {}

class FaqsSuccess extends FaqsState {
  final List<FaqsModel> faqsList;
  final int totalData;
  final bool hasMore;
  FaqsSuccess(this.faqsList, this.totalData, this.hasMore);
}

class FaqsFailure extends FaqsState {
  final String errorMessage;
  FaqsFailure(this.errorMessage);
}

String? totalHasMore;

class FaqsCubit extends Cubit<FaqsState> {
  FaqsCubit() : super(FaqsInitial());
  Future<List<FaqsModel>> _fetchData({
    required String limit,
    String? offset,
  }) async {
    try {
      //body of post request
      final body = {
        limitKey: limit,
        offsetKey: offset ?? "",
      };
      if (offset == null) {
        body.remove(offset);
      }
      final result = await Api.post(
          body: body, url: Api.getFaqsUrl, token: true, errorCode: false);
      totalHasMore = result[totalKey].toString();
      return (result[dataKey] as List)
          .map((e) => FaqsModel.fromJson(e))
          .toList();
    } catch (e) {
      throw ApiMessageException(errorMessage: e.toString());
    }
  }

  void fetchFaqs(String limit) {
    emit(FaqsProgress());
    _fetchData(limit: limit).then((value) {
      final List<FaqsModel> usersDetails = value;
      final total = int.parse(totalHasMore!);
      emit(FaqsSuccess(
        usersDetails,
        total,
        total > usersDetails.length,
      ));
    }).catchError((e) {
      emit(FaqsFailure(e.toString()));
    });
  }

  void fetchMoreFaqsData(String limit) {
    _fetchData(
            limit: limit,
            offset: (state as FaqsSuccess).faqsList.length.toString())
        .then((value) {
      final oldState = (state as FaqsSuccess);
      final List<FaqsModel> usersDetails = value;
      final List<FaqsModel> updatedUserDetails = List.from(oldState.faqsList);
      updatedUserDetails.addAll(usersDetails);
      emit(FaqsSuccess(updatedUserDetails, oldState.totalData,
          oldState.totalData > updatedUserDetails.length));
    }).catchError((e) {
      emit(FaqsFailure(e.toString()));
    });
  }

  bool hasMoreData() {
    if (state is FaqsSuccess) {
      return (state as FaqsSuccess).hasMore;
    } else {
      return false;
    }
  }
}
