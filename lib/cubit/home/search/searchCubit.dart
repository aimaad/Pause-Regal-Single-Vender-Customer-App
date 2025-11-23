import 'package:erestroSingleVender/data/model/sectionsModel.dart';
import 'package:erestroSingleVender/utils/api.dart';
import 'package:erestroSingleVender/utils/apiMessageException.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:erestroSingleVender/utils/apiBodyParameterLabels.dart';

@immutable
abstract class SearchState {}

class SearchInitial extends SearchState {}

class SearchProgress extends SearchState {}

class SearchSuccess extends SearchState {
  final List<ProductDetails> searchList;
  final int totalData;
  final bool hasMore;
  SearchSuccess(this.searchList, this.totalData, this.hasMore);
}

class SearchFailure extends SearchState {
  final String errorMessage;
  SearchFailure(this.errorMessage);
}

String? totalHasMore;

class SearchCubit extends Cubit<SearchState> {
  SearchCubit() : super(SearchInitial());
  Future<List<ProductDetails>> _fetchData(
      {required String limit,
      String? offset,
      String? search,
      String? userId,
      String? branchId}) async {
    try {
      //body of post request
      final body = {
        limitKey: limit,
        offsetKey: offset ?? "",
        searchKey: search ?? "",
        filterByKey: filterByProductKey,
        userIdKey: userId ?? "",
        branchIdKey: branchId ?? ""
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

  void fetchSearch(
      String limit, String search, String? userId, String? branchId) {
    emit(SearchProgress());
    _fetchData(limit: limit, search: search, userId: userId, branchId: branchId)
        .then((value) {
      final List<ProductDetails> usersDetails = value;
      final total = int.parse(totalHasMore!);
      emit(SearchSuccess(
        usersDetails,
        total,
        total > usersDetails.length,
      ));
    }).catchError((e) {
      emit(SearchFailure(e.toString()));
    });
  }

  void fetchMoreSearchData(
      String limit, String search, String? userId, String? branchId) {
    _fetchData(
            limit: limit,
            offset: (state as SearchSuccess).searchList.length.toString(),
            search: search,
            userId: userId,
            branchId: branchId)
        .then((value) {
      final oldState = (state as SearchSuccess);
      final List<ProductDetails> usersDetails = value;
      final List<ProductDetails> updatedUserDetails =
          List.from(oldState.searchList);
      updatedUserDetails.addAll(usersDetails);
      emit(SearchSuccess(updatedUserDetails, oldState.totalData,
          oldState.totalData > updatedUserDetails.length));
    }).catchError((e) {
      emit(SearchFailure(e.toString()));
    });
  }

  bool hasMoreData() {
    if (state is SearchSuccess) {
      return (state as SearchSuccess).hasMore;
    } else {
      return false;
    }
  }
}
