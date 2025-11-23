import 'dart:convert';
import 'dart:io';
import 'package:erestroSingleVender/utils/api.dart';
import 'package:erestroSingleVender/utils/apiMessageAndCodeException.dart';
import 'package:erestroSingleVender/utils/string.dart';
import 'package:erestroSingleVender/utils/apiBodyParameterLabels.dart';

class RatingRemoteDataSource {
  Future setProductRating(
      String? userId, List? productRatingData, String? orderId) async {
    try {
      Map<String, String> body = {userIdKey: userId!, orderIdKey: orderId!};
      Map<dynamic, File> filelist = {};
      for (int i = 0; i < productRatingData!.length; i++) {
        body["$productRatingDataKey[$i][$productIdKey]"] =
            productRatingData[i]["$productIdKey"];
        body["$productRatingDataKey[$i][$ratingKey]"] =
            productRatingData[i]["$ratingKey"];
        body["$productRatingDataKey[$i][$commentKey]"] =
            productRatingData[i]["$commentKey"];
        for (int j = 0; j < productRatingData[i]["$imagessKey"].length; j++) {
          filelist.addAll({
            '$productRatingDataKey[$i][$imagessKey][$j]': productRatingData[i]
                ["$imagessKey"][j]
          });
        }
      }
      final response = await Api.postApiFileProductRating(
          Uri.parse(Api.setProductRatingUrl), body, userId, filelist, orderId);
      final responseJson = json.decode(response);

      if (responseJson[errorKey]) {
        throw ApiMessageAndCodeException(
            errorMessage: responseJson[messageKey],
            errorStatusCode: responseJson[statusCodeKey].toString());
      }

      return responseJson[dataKey];
    } on SocketException catch (_) {
      throw ApiMessageAndCodeException(errorMessage: StringsRes.noInternet);
    } on ApiMessageAndCodeException catch (e) {
      ApiMessageAndCodeException apiMessageAndCodeException = e;
      throw ApiMessageAndCodeException(
          errorMessage: apiMessageAndCodeException.errorMessage.toString(),
          errorStatusCode:
              apiMessageAndCodeException.errorStatusCode.toString());
    } catch (e) {
      throw ApiMessageAndCodeException(errorMessage: e.toString());
    }
  }

  Future setRiderRating(
      String? riderId, String? rating, String? comment, String? orderId) async {
    try {
      final body = {
        riderIdKey: riderId,
        ratingKey: rating,
        commentKey: comment,
        orderIdKey: orderId
      };
      final result = await Api.post(
          body: body, url: Api.setRiderRatingUrl, token: true, errorCode: true);
      return result[dataKey];
    } catch (e) {
      throw ApiMessageAndCodeException(errorMessage: e.toString());
    }
  }

  Future deleteProductRating(String? ratingId) async {
    try {
      final body = {ratingIdKey: ratingId};
      final result = await Api.post(
          body: body,
          url: Api.deleteProductRatingUrl,
          token: true,
          errorCode: true);
      return result[dataKey];
    } catch (e) {
      throw ApiMessageAndCodeException(errorMessage: e.toString());
    }
  }

  Future deleteRiderRating(String? ratingId) async {
    try {
      final body = {ratingIdKey: ratingId};
      final result = await Api.post(
          body: body,
          url: Api.deleteRiderRatingUrl,
          token: true,
          errorCode: true);
      return result[dataKey];
    } catch (e) {
      throw ApiMessageAndCodeException(errorMessage: e.toString());
    }
  }

  Future setOrderRating(String? userId, String? orderId, String? rating,
      String? comment, List<File> images) async {
    try {
      Map<String, String?> body = {
        userIdKey: userId,
        orderIdKey: orderId,
        ratingKey: rating,
        commentKey: comment
      };
      List<File> imagesList = images;
      final response = await Api.postApiFile(Uri.parse(Api.setOrderRatingUrl),
          imagesList, body, userId, orderId, rating, comment);
      final responseJson = json.decode(response);
      if (responseJson[errorKey]) {
        throw ApiMessageAndCodeException(
            errorMessage: responseJson[messageKey],
            errorStatusCode: responseJson[statusCodeKey].toString());
      }

      return responseJson[dataKey];
    } on SocketException catch (_) {
      throw ApiMessageAndCodeException(errorMessage: StringsRes.noInternet);
    } on ApiMessageAndCodeException catch (e) {
      ApiMessageAndCodeException apiMessageAndCodeException = e;
      throw ApiMessageAndCodeException(
          errorMessage: apiMessageAndCodeException.errorMessage.toString(),
          errorStatusCode:
              apiMessageAndCodeException.errorStatusCode.toString());
    } catch (e) {
      throw ApiMessageAndCodeException(errorMessage: e.toString());
    }
  }

  Future deleteOrderRating(String? orderId) async {
    try {
      final body = {ratingIdKey: orderId};
      final result = await Api.post(
          body: body,
          url: Api.deleteOrderRatingUrl,
          token: true,
          errorCode: true);
      return result[dataKey];
    } catch (e) {
      throw ApiMessageAndCodeException(errorMessage: e.toString());
    }
  }
}
