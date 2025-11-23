import 'package:erestroSingleVender/data/model/sectionsModel.dart';
import 'package:erestroSingleVender/utils/api.dart';
import 'package:erestroSingleVender/utils/apiMessageException.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:erestroSingleVender/utils/apiBodyParameterLabels.dart';

@immutable
abstract class SectionsState {}

class SectionsInitial extends SectionsState {}

class SectionsProgress extends SectionsState {}

class SectionsSuccess extends SectionsState {
  final List<SectionsModel> sectionsList;
  final int totalData;
  final bool hasMore;
  SectionsSuccess(this.sectionsList, this.totalData, this.hasMore);
}

class SectionsFailure extends SectionsState {
  final String errorMessage;
  SectionsFailure(this.errorMessage);
}

String? totalHasMore;

class SectionsCubit extends Cubit<SectionsState> {
  SectionsCubit() : super(SectionsInitial());
  Future<List<SectionsModel>> _fetchData(
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
        branchIdKey: branchId ?? "",
      };
      if (offset == null) {
        body.remove(offset);
      }
      if (sectionId != null) {
        body[sectionIdKey] = sectionId;
      }
      final result = await Api.post(
          body: body, url: Api.getSectionsUrl, token: true, errorCode: false);
      if (sectionId!.isEmpty) {
      } else {
        totalHasMore = result[dataKey][0][totalKey].toString();
      }
      return (result[dataKey] as List)
          .map((e) => SectionsModel.fromJson(e))
          .toList();
    } catch (e) {
      throw ApiMessageException(errorMessage: e.toString());
    }
  }

  fetchSections(
      String limit, String? userId, String? sectionId, String? branchId) {
    emit(SectionsProgress());
    _fetchData(
            limit: limit,
            userId: userId,
            sectionId: sectionId,
            branchId: branchId)
        .then((value) {
      final List<SectionsModel> usersDetails = value;
      final total = sectionId!.isEmpty
          ? value.length
          : int.parse(totalHasMore.toString());
      emit(SectionsSuccess(
        usersDetails,
        total,
        total > usersDetails.length,
      ));
    }).catchError((e) {
      emit(SectionsFailure(e.toString()));
    });
  }

  void fetchMoreSectionsData(
      String limit, String? userId, String? sectionId, String? branchId) {
    _fetchData(
            limit: limit,
            offset: sectionId!.isEmpty
                ? (state as SectionsSuccess).sectionsList.length.toString()
                : (state as SectionsSuccess)
                    .sectionsList[0]
                    .productDetails!
                    .length
                    .toString(),
            userId: userId,
            sectionId: sectionId,
            branchId: branchId)
        .then((value) {
      final oldState = (state as SectionsSuccess);
      final List<SectionsModel> usersDetails = value;
      final List<SectionsModel> updatedUserDetails =
          List.from(oldState.sectionsList);
      updatedUserDetails.addAll(usersDetails);
      emit(SectionsSuccess(updatedUserDetails, oldState.totalData,
          oldState.totalData > updatedUserDetails.length));
    }).catchError((e) {
      emit(SectionsFailure(e.toString()));
    });
  }

  bool hasMoreData() {
    if (state is SectionsSuccess) {
      return (state as SectionsSuccess).hasMore;
    } else {
      return false;
    }
  }

  getSectionsList() {
    if (state is SectionsSuccess) {
      return (state as SectionsSuccess).sectionsList;
    }
    return [];
  }
}
