import 'package:erestroSingleVender/data/model/cartModel.dart';
import 'package:erestroSingleVender/utils/api.dart';
import 'package:erestroSingleVender/utils/apiBodyParameterLabels.dart';
import 'package:erestroSingleVender/utils/apiMessageAndCodeException.dart';

class CartRemoteDataSource {
//to manageCart
  Future<dynamic> manageCart(
      {String? productVariantId,
      String? isSavedForLater,
      String? qty,
      String? addOnId,
      String? addOnQty,
      String? branchId,
      String? cartId,
      String? from}) async {
    try {
      //body of post request
      final body = {
        productVariantIdKey: productVariantId,
        isSavedForLaterKey: isSavedForLater,
        qtyKey: qty,
        addOnIdKey: addOnId ?? "",
        addOnQtyKey: addOnQty ?? "",
        branchIdKey: branchId ?? ""
      };
      if ((cartId != null) && (cartId != "") && (cartId.isNotEmpty)) {
        body[cartIdKey] = cartId;
      }
      final result = await Api.post(
          body: body, url: Api.manageCartUrl, token: true, errorCode: true);
      return result;
    } catch (e) {
      ApiMessageAndCodeException apiMessageAndCodeException =
          e as ApiMessageAndCodeException;
      throw ApiMessageAndCodeException(
          errorMessage: apiMessageAndCodeException.errorMessage,
          errorStatusCode: apiMessageAndCodeException.errorStatusCode);
    }
  }

  //to placeOrder
  Future<dynamic> placeOrder(
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
      String? deliveryTip,
      String? branchId}) async {
    try {
      //body of post request
      final body = {
        mobileKey: mobile,
        productVariantIdKey: productVariantId,
        quantityKey: quantity,
        totalKey: total,
        deliveryChargeKey: deliveryCharge,
        taxAmountKey: taxAmount,
        taxPercentageKey: taxPercentage,
        finalTotalKey: finalTotal,
        latitudeKey: latitude,
        longitudeKey: longitude,
        promoCodeKey: promoCode,
        paymentMethodKey: paymentMethod,
        addressIdKey: addressId,
        isWalletUsedKey: isWalletUsed,
        walletBalanceUsedKey: walletBalanceUsed,
        activeStatusKey: activeStatus,
        orderNoteKey: orderNote,
        deliveryTipKey: deliveryTip,
        branchIdKey: branchId
      };
      final result = await Api.post(
          body: body, url: Api.placeOrderUrl, token: true, errorCode: true);
      return result[dataKey];
    } catch (e) {
      ApiMessageAndCodeException apiMessageAndCodeException =
          e as ApiMessageAndCodeException;
      throw ApiMessageAndCodeException(
          errorMessage: apiMessageAndCodeException.errorMessage,
          errorStatusCode: apiMessageAndCodeException.errorStatusCode);
    }
  }

  //to removeCart
  Future<dynamic> removeCart({String? cartId, String? branchId}) async {
    try {
      //body of post request
      final body = {cartIdKey: cartId, branchIdKey: branchId};
      final result = await Api.post(
          body: body, url: Api.removeFromCartUrl, token: true, errorCode: true);
      return result[dataKey];
    } catch (e) {
      ApiMessageAndCodeException apiMessageAndCodeException =
          e as ApiMessageAndCodeException;
      throw ApiMessageAndCodeException(
          errorMessage: apiMessageAndCodeException.errorMessage,
          errorStatusCode: apiMessageAndCodeException.errorStatusCode);
    }
  }

  //to clearCart
  Future<dynamic> clearCart({String? branchId}) async {
    try {
      //body of post request
      final body = {branchIdKey: branchId};
      final result = await Api.post(
          body: body, url: Api.removeFromCartUrl, token: true, errorCode: true);
      return result[dataKey];
    } catch (e) {
      ApiMessageAndCodeException apiMessageAndCodeException =
          e as ApiMessageAndCodeException;
      throw ApiMessageAndCodeException(
          errorMessage: apiMessageAndCodeException.errorMessage,
          errorStatusCode: apiMessageAndCodeException.errorStatusCode);
    }
  }

  //to getUserCart
  Future<CartModel> getCart({String? branchId, String? from}) async {
    try {
      //body of post request
      final body = {branchIdKey: branchId};
      final result = await Api.post(
          body: body, url: Api.getUserCartUrl, token: true, errorCode: true);
      return CartModel.fromJson(result);
    } catch (e) {
      ApiMessageAndCodeException apiMessageAndCodeException =
          e as ApiMessageAndCodeException;
      throw ApiMessageAndCodeException(
          errorMessage: apiMessageAndCodeException.errorMessage,
          errorStatusCode: apiMessageAndCodeException.errorStatusCode);
    }
  }
}
