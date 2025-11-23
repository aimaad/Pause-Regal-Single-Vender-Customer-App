import 'package:erestroSingleVender/cubit/auth/authCubit.dart';
import 'package:erestroSingleVender/data/model/offlineCartModel.dart';
import 'package:erestroSingleVender/data/model/productModel.dart';
import 'package:erestroSingleVender/data/model/sectionsModel.dart';
import 'package:erestroSingleVender/data/repositories/product/productRemoteDataSource.dart';
import 'package:erestroSingleVender/utils/SqliteData.dart';
import 'package:erestroSingleVender/utils/apiMessageException.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProductRepository {
  static final ProductRepository _productRepository =
      ProductRepository._internal();
  late ProductRemoteDataSource _productRemoteDataSource;

  factory ProductRepository() {
    _productRepository._productRemoteDataSource = ProductRemoteDataSource();
    return _productRepository;
  }
  ProductRepository._internal();

  //to getProduct
  Future<ProductModel> getProductData(
      String? partnerId,
      String? latitude,
      String? longitude,
      String? userId,
      String? cityId,
      String? vegetarian) async {
    try {
      ProductModel result = await _productRemoteDataSource.getProduct(
          partnerId: partnerId,
          latitude: latitude ?? "",
          longitude: longitude ?? "",
          userId: userId,
          cityId: cityId,
          vegetarian: vegetarian);
      return result;
    } catch (e) {
      throw ApiMessageException(errorMessage: e.toString());
    }
  }

  //to getOfflineCartData
  Future<List<ProductDetails>> getOfflineCartData(
      String? productVariantIds, String? branchId) async {
    try {
      List<ProductDetails> result =
          await _productRemoteDataSource.getOfflineCart(
              productVariantIds: productVariantIds, branchId: branchId);
      return result;
    } catch (e) {
      throw ApiMessageException(errorMessage: e.toString());
    }
  }

  //to manageOfflineCartData
  Future<ProductModel> manageOfflineCartData(String? latitude,
      String? longitude, String? cityId, String? productVariantIds) async {
    try {
      ProductModel result = await _productRemoteDataSource.manageOfflineCart(
          latitude: latitude ?? "",
          longitude: longitude ?? "",
          cityId: cityId,
          productVariantIds: productVariantIds);
      return result;
    } catch (e) {
      throw ApiMessageException(errorMessage: e.toString());
    }
  }

  Future<List<OfflineCartModel>> getOfflineCart(
      ProductDetails productDetails, BuildContext context) async {
    if (context.read<AuthCubit>().state is AuthInitial ||
        context.read<AuthCubit>().state is Unauthenticated) {
      var db = DatabaseHelper();
      List<OfflineCartModel> offlineCartList = [];
      List<OfflineCartModel> offlineCartDataFinalList = [];
      List<Map> data = (await db.getOfflineCartData());
      offlineCartList =
          (data as List).map((e) => OfflineCartModel.fromJson(e)).toList();
      for (int i = 0; i < offlineCartList.length; i++) {
        if (productDetails.id == offlineCartList[i].pId) {
          offlineCartDataFinalList.add(offlineCartList[i]);
        }
      }
      return offlineCartDataFinalList;
    } else {
      return [];
    }
  }
}
