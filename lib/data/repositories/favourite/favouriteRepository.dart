import 'package:erestroSingleVender/data/repositories/favourite/favouriteDataSource.dart';
import 'package:erestroSingleVender/data/model/sectionsModel.dart';
import 'package:erestroSingleVender/utils/apiMessageAndCodeException.dart';

class FavouriteRepository {
  static final FavouriteRepository _favouriteRepository =
      FavouriteRepository._internal();
  late FavouriteRemoteDataSource _favouriteRemoteDataSource;

  factory FavouriteRepository() {
    _favouriteRepository._favouriteRemoteDataSource =
        FavouriteRemoteDataSource();
    return _favouriteRepository;
  }

  FavouriteRepository._internal();

  Future getFavouriteAdd(String? type, String? typeId, String? branchId) async {
    try {
      final result =
          await _favouriteRemoteDataSource.favouriteAdd(type, typeId, branchId);
      return result;
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

  Future getFavouriteRemove(
      String? type, String? typeId, String? branchId) async {
    try {
      final result = await _favouriteRemoteDataSource.favouriteRemove(
          type, typeId, branchId);
      return result;
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

  Future favoriteRestaurant(
      {required String type,
      required String restaurantId,
      String? branchId}) async {
    try {
      final result = await _favouriteRemoteDataSource.favouriteAdd(
          type, restaurantId, branchId);
      return result;
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

  Future unFavoriteRestaurant(
      {required String type,
      required String restaurantId,
      required String branchId}) async {
    try {
      final result = await _favouriteRemoteDataSource.favouriteRemove(
          type, restaurantId, branchId);
      return result;
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

  Future<List<ProductDetails>> getFavoriteProducts(
      String? type, String? branchId) async {
    try {
      List<ProductDetails> result = await _favouriteRemoteDataSource
          .getFavouriteProducts(type: type, branchId: branchId);
      return result;
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

  Future favoriteProduct(
      {required String type,
      required String productId,
      required String? branchId}) async {
    try {
      final result = await _favouriteRemoteDataSource.favouriteAdd(
          type, productId, branchId);
      return result;
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

  Future unFavoriteProduct(
      {required String type,
      required String productId,
      required String? branchId}) async {
    try {
      final result = await _favouriteRemoteDataSource.favouriteRemove(
          type, productId, branchId);
      return result;
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
}
