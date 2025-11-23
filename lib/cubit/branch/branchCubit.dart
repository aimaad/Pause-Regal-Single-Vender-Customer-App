import 'package:erestroSingleVender/data/model/branchModel.dart';
import 'package:erestroSingleVender/utils/ApiMessageException.dart';
import 'package:erestroSingleVender/utils/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:erestroSingleVender/utils/apiBodyParameterLabels.dart';

@immutable
abstract class BranchState {}

class BranchInitial extends BranchState {}

class BranchProgress extends BranchState {}

class BranchSuccess extends BranchState {
  final List<BranchModel> branchList;
  final int totalData;
  final bool hasMore;
  BranchSuccess(this.branchList, this.totalData, this.hasMore);
}

class BranchFailure extends BranchState {
  final String errorMessage;
  BranchFailure(this.errorMessage);
}

String? totalHasMore;

class BranchCubit extends Cubit<BranchState> {
  BranchCubit() : super(BranchInitial());
  Future<List<BranchModel>> _fetchData(
      {required String limit,
      String? offset,
      String? cityId,
      String? latitude,
      String? longitude,
      String? search}) async {
    try {
      //body of post request
      final body = {
        limitKey: limit,
        offsetKey: offset ?? "",
        cityIdKey: cityId ?? "",
        latitudeKey: latitude ?? "",
        longitudeKey: longitude ?? "",
        searchKey: search ?? ""
      };
      if (offset == null) {
        body.remove(offset);
      }
      final result = await Api.post(
          body: body, url: Api.getBranchesUrl, token: true, errorCode: false);
      totalHasMore = result[totalKey].toString();
      return (result[dataKey] as List)
          .map((e) => BranchModel.fromJson(e))
          .toList();
    } catch (e) {
      throw ApiMessageException(errorMessage: e.toString());
    }
  }

  fetchBranch(String limit, String? cityId, String? latitude, String? longitude,
      String? search) {
    emit(BranchProgress());
    _fetchData(
            limit: limit,
            cityId: cityId,
            latitude: latitude,
            longitude: longitude,
            search: search)
        .then((value) {
      final List<BranchModel> usersDetails = value;
      final total = int.parse(totalHasMore!);
      emit(BranchSuccess(
        usersDetails,
        total,
        total > usersDetails.length,
      ));
    }).catchError((e) {
      emit(BranchFailure(e.toString()));
    });
  }

  void fetchMoreBranchData(String limit, String? cityId, String? latitude,
      String? longitude, String? search) {
    _fetchData(
            limit: limit,
            offset: (state as BranchSuccess).branchList.length.toString(),
            cityId: cityId,
            latitude: latitude,
            longitude: longitude,
            search: search)
        .then((value) {
      final oldState = (state as BranchSuccess);
      final List<BranchModel> usersDetails = value;
      final List<BranchModel> updatedUserDetails =
          List.from(oldState.branchList);
      updatedUserDetails.addAll(usersDetails);
      emit(BranchSuccess(updatedUserDetails, oldState.totalData,
          oldState.totalData > updatedUserDetails.length));
    }).catchError((e) {
      emit(BranchFailure(e.toString()));
    });
  }

  bool hasMoreData() {
    if (state is BranchSuccess) {
      return (state as BranchSuccess).hasMore;
    } else {
      return false;
    }
  }
}
