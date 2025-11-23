import 'package:erestroSingleVender/data/model/sectionsModel.dart';
import 'package:erestroSingleVender/utils/api.dart';
import 'package:erestroSingleVender/utils/apiMessageException.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:erestroSingleVender/utils/apiBodyParameterLabels.dart';

@immutable
abstract class SectionsDetailState {}

class SectionsDetailInitial extends SectionsDetailState {}

class SectionsDetailProgress extends SectionsDetailState {}

class SectionsDetailSuccess extends SectionsDetailState {
  final List<ProductDetails> sectionsDetailList;
  final int totalData;
  final bool hasMore;
  SectionsDetailSuccess(this.sectionsDetailList, this.totalData, this.hasMore);
}

class SectionsDetailFailure extends SectionsDetailState {
  final String errorMessage;
  SectionsDetailFailure(this.errorMessage);
}

String? totalHasMore;

class SectionsDetailCubit extends Cubit<SectionsDetailState> {
  SectionsDetailCubit() : super(SectionsDetailInitial());
  Future<List<ProductDetails>> _fetchData(
      {required String limit,
      String? offset,
      String? userId,
      String? sectionId,
      String? branchId}) async {
    try {
      //body of post request
      final body = {
        pLimitKey: limit,
        pOffsetKey: offset ?? "",
        userIdKey: userId ?? "",
        sectionIdKey: sectionId ?? "",
        branchIdKey: branchId ?? ""
      };
      if (offset == null) {
        body.remove(offset);
      }
      final result = await Api.post(
          body: body, url: Api.getSectionsUrl, token: true, errorCode: false);
      if (sectionId!.isEmpty) {
      } else {
        totalHasMore = result[totalKey].toString();
      }
      return (result[dataKey][0]['product_details'] as List)
          .map((e) => ProductDetails.fromJson(e))
          .toList();
    } catch (e) {
      throw ApiMessageException(errorMessage: e.toString());
    }
  }

  fetchSectionsDetail(
      String limit, String? userId, String? sectionId, String? branchId) {
    emit(SectionsDetailProgress());
    _fetchData(
            limit: limit,
            userId: userId,
            sectionId: sectionId,
            branchId: branchId)
        .then((value) {
      final List<ProductDetails> usersDetails = value;
      final total = int.parse(totalHasMore.toString());
      emit(SectionsDetailSuccess(
        usersDetails,
        total,
        total > usersDetails.length,
      ));
    }).catchError((e) {
      emit(SectionsDetailFailure(e.toString()));
    });
  }

  void fetchMoreSectionsDetailData(
      String limit, String? userId, String? sectionId, String? branchId) {
    _fetchData(
            limit: limit,
            offset: (state as SectionsDetailSuccess)
                .sectionsDetailList
                .length
                .toString(),
            userId: userId,
            sectionId: sectionId,
            branchId: branchId)
        .then((value) {
      final oldState = (state as SectionsDetailSuccess);
      final List<ProductDetails> usersDetails = value;
      final List<ProductDetails> updatedUserDetails =
          List.from(oldState.sectionsDetailList);
      updatedUserDetails.addAll(usersDetails);
      emit(SectionsDetailSuccess(updatedUserDetails, oldState.totalData,
          oldState.totalData > updatedUserDetails.length));
    }).catchError((e) {
      emit(SectionsDetailFailure(e.toString()));
    });
  }

  bool hasMoreData() {
    if (state is SectionsDetailSuccess) {
      return (state as SectionsDetailSuccess).hasMore;
    } else {
      return false;
    }
  }
}
