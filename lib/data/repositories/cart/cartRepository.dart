import 'package:erestroSingleVender/cubit/auth/authCubit.dart';
import 'package:erestroSingleVender/cubit/cart/getCartCubit.dart';
import 'package:erestroSingleVender/data/model/cartModel.dart';
import 'package:erestroSingleVender/data/model/offlineCartModel.dart';
import 'package:erestroSingleVender/data/repositories/cart/cartRemoteDataSource.dart';
import 'package:erestroSingleVender/utils/apiMessageAndCodeException.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../utils/SqliteData.dart';
import '../../model/sectionsModel.dart';

class CartRepository {
  static final CartRepository _cartRepository = CartRepository._internal();
  late CartRemoteDataSource _cartRemoteDataSource;

  factory CartRepository() {
    _cartRepository._cartRemoteDataSource = CartRemoteDataSource();
    return _cartRepository;
  }
  CartRepository._internal();

  //to manageCart
  Future<Map<String, dynamic>> manageCartData(
      {String? productVariantId,
      String? isSavedForLater,
      String? qty,
      String? addOnId,
      String? addOnQty,
      String? branchId,
      String? cartId,
      String? from}) async {
    try {
      final result = await _cartRemoteDataSource.manageCart(
          productVariantId: productVariantId,
          isSavedForLater: isSavedForLater,
          qty: qty,
          addOnId: addOnId,
          addOnQty: addOnQty,
          branchId: branchId,
          cartId: cartId,
          from: from);
      return Map.from(result);
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

  //to placeOrder
  Future<Map<String, dynamic>> placeOrderData(
      {String? mobile,
      String? productVariantId,
      String? quantity,
      String? total,
      String? deliveryCharge,
      String? taxAmount,
      String? taxPercentage,
      String? finalTotal,
      String? latitude,
      String? longitude,
      String? promoCode,
      String? paymentMethod,
      String? addressId,
      String? isWalletUsed,
      String? walletBalanceUsed,
      String? activeStatus,
      String? orderNote,
      String? deliveryTip}) async {
    final result = await _cartRemoteDataSource.placeOrder(
        mobile: mobile,
        productVariantId: productVariantId,
        quantity: quantity,
        total: total,
        deliveryCharge: deliveryCharge,
        taxAmount: taxAmount,
        taxPercentage: taxPercentage,
        finalTotal: finalTotal,
        latitude: latitude,
        longitude: longitude,
        promoCode: promoCode,
        paymentMethod: paymentMethod,
        addressId: addressId,
        isWalletUsed: isWalletUsed,
        walletBalanceUsed: walletBalanceUsed,
        activeStatus: activeStatus,
        orderNote: orderNote,
        deliveryTip: deliveryTip);
    return Map.from(result);
  }

  //to removeFromCart
  Future<Map<String, dynamic>> removeFromCart(
      {String? cartId, String? branchId}) async {
    final result = await _cartRemoteDataSource.removeCart(
        cartId: cartId, branchId: branchId);
    return Map.from(result);
  }

  //to clearCart
  Future<Map<String, dynamic>> clearCart({String? branchId}) async {
    final result = await _cartRemoteDataSource.clearCart(branchId: branchId);
    return Map.from(result);
  }

  //to getCart
  Future<CartModel> getCartData(String? branchId, String? from) async {
    try {
      CartModel result =
          await _cartRemoteDataSource.getCart(branchId: branchId, from: from);
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

  Future<String> AllVarianntQty(
      String id, ProductDetails productDetails, BuildContext context) async {
    if (context.read<GetCartCubit>().state is GetCartSuccess) {
      int qtyTotal = 0;
      List<Data> filteredRecords =
          (context.read<GetCartCubit>().state as GetCartSuccess)
              .cartModel
              .data!
              .where((element) => element.id == id)
              .toList();

      for (var record in filteredRecords) {
        qtyTotal += int.parse(record.qty ??
            "0"); // Assuming qty is an int in your Data model, default to 0 if null
      }
      return qtyTotal.toString();
    } else {
      if (context.read<AuthCubit>().state is AuthInitial ||
          context.read<AuthCubit>().state is Unauthenticated) {
        var db = DatabaseHelper();
        int qtyTotal = 0;
        List<OfflineCartModel> offlineCartDataList = [];
        List<Map> data = (await db.getOfflineCartData());
        offlineCartDataList =
            (data as List).map((e) => OfflineCartModel.fromJson(e)).toList();
        for (int i = 0; i < offlineCartDataList.length; i++) {
          if (productDetails.id!.contains(offlineCartDataList[i].pId!))
            for (int j = 0; j < productDetails.variants!.length; j++) {
              if (offlineCartDataList[i]
                  .vId!
                  .contains(productDetails.variants![j].id!)) {
                String qty = offlineCartDataList[i].qty!;
                productDetails.variants![j].cartCount = qty;
                qtyTotal += int.parse(qty);
              }
            }
        }
        return qtyTotal.toString();
      } else {
        return "0";
      }
    }
  }
}
