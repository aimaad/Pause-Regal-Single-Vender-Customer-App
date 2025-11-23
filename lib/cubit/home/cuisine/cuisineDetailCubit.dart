import 'package:erestroSingleVender/data/model/sectionsModel.dart';
import 'package:erestroSingleVender/utils/api.dart';
import 'package:erestroSingleVender/utils/apiMessageException.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:erestroSingleVender/utils/apiBodyParameterLabels.dart';

@immutable
abstract class CuisineDetailState {}

class CuisineDetailInitial extends CuisineDetailState {}

class CuisineDetailProgress extends CuisineDetailState {}

class CuisineDetailSuccess extends CuisineDetailState {
  final List<ProductDetails> cuisineDetailList;
  final int totalData;
  final bool hasMore;
  CuisineDetailSuccess(this.cuisineDetailList, this.totalData, this.hasMore);
}

class CuisineDetailFailure extends CuisineDetailState {
  final String errorMessage;
  CuisineDetailFailure(this.errorMessage);
}

String? totalHasMore;

class CuisineDetailCubit extends Cubit<CuisineDetailState> {
  CuisineDetailCubit() : super(CuisineDetailInitial());
  Future<List<ProductDetails>> _fetchData(
      {required String limit,
      String? offset,
      required String? categoryId,
      String? userId,
      String? branchId}) async {
    try {
      //body of post request
      final body = {
        limitKey: limit,
        offsetKey: offset ?? "",
        categoryIdKey: categoryId,
        filterByKey: filterByProductKey,
        userIdKey: userId ?? "",
        branchIdKey: branchId
      };
      if (offset == null) {
        body.remove(offset);
      }
      final result = await Api.post(
          body: body, url: Api.getProductsUrl, token: true, errorCode: false);
      totalHasMore = result[totalKey].toString();
      return (result[dataKey] as List)
          .map((e) => ProductDetails.fromJson(e))
          .toList();
    } catch (e) {
      throw ApiMessageException(errorMessage: e.toString());
    }
  }

  void fetchCuisineDetail(
      String limit, String categoryId, String? userId, String? branchId) {
    emit(CuisineDetailProgress());
    _fetchData(
            limit: limit,
            categoryId: categoryId,
            userId: userId,
            branchId: branchId)
        .then((value) {
      final List<ProductDetails> usersDetails = value;
      final total = int.parse(totalHasMore!);
      emit(CuisineDetailSuccess(
        usersDetails,
        total,
        total > usersDetails.length,
      ));
    }).catchError((e) {
      emit(CuisineDetailFailure(e.toString()));
    });
  }

  void fetchMoreCuisineDetailData(
      String limit, String categoryId, String userId, String? branchId) {
    _fetchData(
            limit: limit,
            offset: (state as CuisineDetailSuccess)
                .cuisineDetailList
                .length
                .toString(),
            categoryId: categoryId,
            userId: userId,
            branchId: branchId)
        .then((value) {
      final oldState = (state as CuisineDetailSuccess);
      final List<ProductDetails> usersDetails = value;
      final List<ProductDetails> updatedUserDetails =
          List.from(oldState.cuisineDetailList);
      updatedUserDetails.addAll(usersDetails);
      emit(CuisineDetailSuccess(updatedUserDetails, oldState.totalData,
          oldState.totalData > updatedUserDetails.length));
    }).catchError((e) {
      emit(CuisineDetailFailure(e.toString()));
    });
  }

  bool hasMoreData() {
    if (state is CuisineDetailSuccess) {
      return (state as CuisineDetailSuccess).hasMore;
    } else {
      return false;
    }
  }
}
