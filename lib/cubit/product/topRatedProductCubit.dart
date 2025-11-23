import 'package:erestroSingleVender/data/model/sectionsModel.dart';
import 'package:erestroSingleVender/utils/api.dart';
import 'package:erestroSingleVender/utils/apiMessageException.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:erestroSingleVender/utils/apiBodyParameterLabels.dart';

@immutable
abstract class TopRatedProductState {}

class TopRatedProductInitial extends TopRatedProductState {}

class TopRatedProductProgress extends TopRatedProductState {}

class TopRatedProductSuccess extends TopRatedProductState {
  final List<ProductDetails> topRatedProductList;
  final int totalData;
  final bool hasMore;
  TopRatedProductSuccess(
      this.topRatedProductList, this.totalData, this.hasMore);
}

class TopRatedProductFailure extends TopRatedProductState {
  final String errorMessage;
  TopRatedProductFailure(this.errorMessage);
}

String? totalHasMore;

class TopRatedProductCubit extends Cubit<TopRatedProductState> {
  TopRatedProductCubit() : super(TopRatedProductInitial());
  Future<List<ProductDetails>> _fetchData(
      {required String limit,
      String? offset,
      String? topRatedFood,
      String? userId,
      String? branchId}) async {
    try {
      //body of post request
      final body = {
        limitKey: limit,
        offsetKey: offset ?? "",
        topRatedFoodsKey: topRatedFood ?? "",
        userIdKey: userId ?? "",
        branchIdKey: branchId ?? "",
        filterByKey: filterByProductKey
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

  fetchTopRatedProduct(
      String limit, String? topRatedFood, String? userId, String? branchId) {
    emit(TopRatedProductProgress());
    _fetchData(
            limit: limit,
            topRatedFood: topRatedFood,
            userId: userId,
            branchId: branchId)
        .then((value) {
      final List<ProductDetails> usersDetails = value;
      final total = int.parse(totalHasMore!);
      emit(TopRatedProductSuccess(
        usersDetails,
        total,
        total > usersDetails.length,
      ));
    }).catchError((e) {
      emit(TopRatedProductFailure(e.toString()));
    });
  }

  void fetchMoreTopRatedProductData(
      String limit, String? topRatedFood, String? userId, String? branchId) {
    _fetchData(
            limit: limit,
            offset: (state as TopRatedProductSuccess)
                .topRatedProductList
                .length
                .toString(),
            topRatedFood: topRatedFood,
            userId: userId,
            branchId: branchId)
        .then((value) {
      final oldState = (state as TopRatedProductSuccess);
      final List<ProductDetails> usersDetails = value;
      final List<ProductDetails> updatedUserDetails =
          List.from(oldState.topRatedProductList);
      updatedUserDetails.addAll(usersDetails);
      emit(TopRatedProductSuccess(updatedUserDetails, oldState.totalData,
          oldState.totalData > updatedUserDetails.length));
    }).catchError((e) {
      emit(TopRatedProductFailure(e.toString()));
    });
  }

  bool hasMoreData() {
    if (state is TopRatedProductSuccess) {
      return (state as TopRatedProductSuccess).hasMore;
    } else {
      return false;
    }
  }
}
