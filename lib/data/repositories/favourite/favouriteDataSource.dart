import 'package:erestroSingleVender/data/model/sectionsModel.dart';
import 'package:erestroSingleVender/utils/api.dart';
import 'package:erestroSingleVender/utils/apiBodyParameterLabels.dart';
import 'package:erestroSingleVender/utils/apiMessageAndCodeException.dart';

class FavouriteRemoteDataSource {
  Future<List<ProductDetails>> getFavouriteProducts(
      {String? type, String? branchId}) async {
    try {
      final body = {typeKey: type, branchIdKey: branchId};
      final result = await Api.post(
          body: body, url: Api.getFavoritesUrl, token: true, errorCode: true);
      return (result[dataKey] as List)
          .map((e) => ProductDetails.fromJson(e))
          .toList();
    } catch (e) {
      ApiMessageAndCodeException apiMessageAndCodeException =
          e as ApiMessageAndCodeException;
      throw ApiMessageAndCodeException(
          errorMessage: apiMessageAndCodeException.errorMessage,
          errorStatusCode: apiMessageAndCodeException.errorStatusCode);
    }
  }

  Future favouriteAdd(String? type, String? typeId, String? branchId) async {
    try {
      final body = {typeKey: type, typeIdKey: typeId, branchIdKey: branchId};
      final result = await Api.post(
          body: body, url: Api.addToFavoritesUrl, token: true, errorCode: true);
      return result[dataKey];
    } catch (e) {
      throw ApiMessageAndCodeException(errorMessage: e.toString());
    }
  }

  Future favouriteRemove(String? type, String? typeId, String? branchId) async {
    try {
      final body = {typeKey: type, typeIdKey: typeId, branchIdKey: branchId};
      final result = await Api.post(
          body: body,
          url: Api.removeFromFavoritesUrl,
          token: true,
          errorCode: true);
      return result[dataKey];
    } catch (e) {
      throw ApiMessageAndCodeException(errorMessage: e.toString());
    }
  }
}
