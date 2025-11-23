import 'package:erestroSingleVender/data/model/sectionsModel.dart';
import 'package:erestroSingleVender/utils/api.dart';
import 'package:erestroSingleVender/utils/apiMessageException.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:erestroSingleVender/utils/apiBodyParameterLabels.dart';

@immutable
abstract class ProductState {}

class ProductInitial extends ProductState {}

class ProductProgress extends ProductState {}

class ProductSuccess extends ProductState {
  final List<ProductDetails> productList;
  final int totalData;
  final bool hasMore;
  ProductSuccess(this.productList, this.totalData, this.hasMore);
}

class ProductFailure extends ProductState {
  final String errorMessage;
  ProductFailure(this.errorMessage);
}

String? totalHasMore;

class ProductCubit extends Cubit<ProductState> {
  ProductCubit() : super(ProductInitial());
  Future<List<ProductDetails>> _fetchData(
      {required String limit,
      String? offset,
      String? userId,
      String? branchId,
      String? categoryId,
      String? vegetarian,
      String? order,
      String? sort}) async {
    try {
      //body of post request
      final body = {
        limitKey: limit,
        offsetKey: offset ?? "",
        userIdKey: userId ?? "",
        branchIdKey: branchId ?? "",
        filterByKey: filterByProductKey,
        categoryIdKey: categoryId ?? "",
        vegetarianKey: vegetarian ?? "",
        orderKey: order ?? "",
        sortKey: sort ?? ""
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

  fetchProduct(String limit, String? userId, String? branchId,
      String? categoryId, String? vegetarian, String? order, String? sort) {
    emit(ProductProgress());
    _fetchData(
            limit: limit,
            userId: userId,
            branchId: branchId,
            categoryId: categoryId,
            vegetarian: vegetarian,
            order: order,
            sort: sort)
        .then((value) {
      final List<ProductDetails> usersDetails = value;
      final total = int.parse(totalHasMore!);
      emit(ProductSuccess(
        usersDetails,
        total,
        total > usersDetails.length,
      ));
    }).catchError((e) {
      emit(ProductFailure(e.toString()));
    });
  }

  void fetchMoreProductData(String limit, String? userId, String? branchId,
      String? categoryId, String? vegetarian, String? order, String? sort) {
    _fetchData(
            limit: limit,
            offset: (state as ProductSuccess).productList.length.toString(),
            userId: userId,
            branchId: branchId,
            categoryId: categoryId,
            vegetarian: vegetarian,
            order: order,
            sort: sort)
        .then((value) {
      final oldState = (state as ProductSuccess);
      final List<ProductDetails> usersDetails = value;
      final List<ProductDetails> updatedUserDetails =
          List.from(oldState.productList);
      updatedUserDetails.addAll(usersDetails);
      emit(ProductSuccess(updatedUserDetails, oldState.totalData,
          oldState.totalData > updatedUserDetails.length));
    }).catchError((e) {
      emit(ProductFailure(e.toString()));
    });
  }

  bool hasMoreData() {
    if (state is ProductSuccess) {
      return (state as ProductSuccess).hasMore;
    } else {
      return false;
    }
  }

  void clearQty(List<ProductDetails>? productDetails) async {
    if (state is ProductSuccess) {
      List<ProductDetails> currentProduct =
          (state as ProductSuccess).productList;
      int totalData = (state as ProductSuccess).totalData;
      bool hasMore = (state as ProductSuccess).hasMore;
      for (int i = 0; i < currentProduct.length; i++) {
        for (int j = 0; j < currentProduct[i].variants!.length; j++) {
          currentProduct[i].variants![j].cartCount = "0";
          currentProduct[i].variants![j].addOnsData = [];
        }
      }
      emit(ProductSuccess(currentProduct, totalData, hasMore));
    }
  }

  String AllVarianntQty(ProductDetails productDetails) {
    if (state is ProductSuccess) {
      int qtyTotal = 0;
      for (int j = 0; j < productDetails.variants!.length; j++) {
        qtyTotal = qtyTotal + int.parse(productDetails.variants![j].cartCount!);
      }
      return qtyTotal.toString();
    }
    return "";
  }

  getProductList() {
    if (state is ProductSuccess) {
      return (state as ProductSuccess).productList;
    }
    return [];
  }
}
