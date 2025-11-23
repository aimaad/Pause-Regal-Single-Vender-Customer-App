import 'package:erestroSingleVender/app/app.dart';
import 'package:erestroSingleVender/data/localDataStore/authLocalDataSource.dart';
import 'package:erestroSingleVender/utils/apiBodyParameterLabels.dart';
import 'package:erestroSingleVender/utils/apiMessageAndCodeException.dart';
import 'package:erestroSingleVender/utils/apiMessageException.dart';
import 'package:erestroSingleVender/utils/constants.dart';
import 'package:erestroSingleVender/utils/string.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';

class Api {
  //jwt key tocken
  static Map<String, String> getHeaders() {
    String jwtToken = AuthLocalDataSource().getJwtTocken()!;
    return {"Authorization": 'Bearer $jwtToken'};
  }

  static Future<dynamic> post(
      {required Map<dynamic, dynamic> body,
      required String url,
      bool? token,
      bool? errorCode}) async {
    try {
      http.Response response;
      if (token!) {
        response = await http.post(Uri.parse(url),
            body: body, headers: Api.getHeaders());
      } else {
        response = await http.post(Uri.parse(url), body: body);
      }
      print("url:$url\nparameter:$body\njwtToken:${Api.getHeaders()}");
      if (response.statusCode == 503) {
        isMaintenance(navigatorKey.currentContext!);
      }
      final responseJson = convertJson(response);
      print("response:$responseJson");
      if (responseJson[errorKey]) {
        if (errorCode!) {
          throw ApiMessageAndCodeException(
              errorMessage: responseJson[messageKey],
              errorStatusCode: responseJson[statusCodeKey].toString());
        } else {
          throw ApiMessageException(errorMessage: responseJson[messageKey]);
        }
      }

      return responseJson;
    } on SocketException catch (_) {
      throw ApiMessageAndCodeException(errorMessage: StringsRes.noInternet);
    } on ApiMessageAndCodeException catch (e) {
      ApiMessageAndCodeException apiMessageAndCodeException = e;
      print(
          "error:${apiMessageAndCodeException.errorMessage.toString()} -- ${apiMessageAndCodeException.errorStatusCode.toString()}");
      if (apiMessageAndCodeException.errorStatusCode == tockenExpireCode) {
        reLogin(navigatorKey.currentContext!);
      }
      if (errorCode!) {
        throw ApiMessageAndCodeException(
            errorMessage: apiMessageAndCodeException.errorMessage.toString(),
            errorStatusCode:
                apiMessageAndCodeException.errorStatusCode.toString());
      } else {
        throw ApiMessageAndCodeException(
            errorMessage: apiMessageAndCodeException.errorMessage.toString());
      }
    } catch (e) {
      throw ApiMessageAndCodeException(errorMessage: e.toString());
    }
  }

  static Future postApiFile(
      Uri url,
      List<File> images,
      Map<String, String?> body,
      String? userId,
      String? productId,
      String? rating,
      String? comment) async {
    try {
      var request = http.MultipartRequest('POST', url);
      request.headers.addAll(Api.getHeaders());
      body.forEach((key, value) {
        request.fields[key] = value!;
      });
      body[userIdKey] = userId;
      body[productIdKey] = productId;
      body[ratingKey] = rating;
      body[commentKey] = comment;
      for (var i = 0; i < images.length; i++) {
        final mimeType = lookupMimeType(images[i].path);

        var extension = mimeType!.split("/");
        var pic = await http.MultipartFile.fromPath(imagesKey, images[i].path,
            contentType: MediaType('image', extension[1]));
        request.files.add(pic);
        print(images[i].path);
      }

      var res = await request.send();
      var responseData = await res.stream.toBytes();
      var response = String.fromCharCodes(responseData);
      if (res.statusCode == 503) {
        isMaintenance(navigatorKey.currentContext!);
      }
      if (res.statusCode == 200) {
        return response;
      }
    } on SocketException catch (_) {
      throw ApiMessageAndCodeException(errorMessage: StringsRes.noInternet);
    } on ApiMessageAndCodeException catch (e) {
      ApiMessageAndCodeException apiMessageAndCodeException = e;
      if (apiMessageAndCodeException.errorStatusCode == tockenExpireCode) {
        reLogin(navigatorKey.currentContext!);
      }
      throw ApiMessageAndCodeException(
          errorMessage: apiMessageAndCodeException.errorMessage.toString(),
          errorStatusCode:
              apiMessageAndCodeException.errorStatusCode.toString());
    } catch (e) {
      throw ApiMessageAndCodeException(errorMessage: e.toString());
    }
  }

  static Future postApiFileProductRating(Uri url, Map<String, String?> body,
      String? userId, Map<dynamic, File> filelist, String? orderId) async {
    try {
      var request = http.MultipartRequest('POST', url);
      request.headers.addAll(Api.getHeaders());
      body.forEach((key, value) {
        request.fields[key] = value!;
      });
      body[userIdKey] = userId;
      body[orderIdKey] = orderId;
      if (filelist.isNotEmpty) {
        filelist.forEach((key, value) async {
          final mimeType = lookupMimeType(value.path);
          var extension = mimeType!.split("/");
          var pic = await http.MultipartFile.fromPath(key, value.path,
              contentType: MediaType(imageKey, extension[1]));
          request.files.add(pic);
        });
      }

      var res = await request.send();
      var responseData = await res.stream.toBytes();
      var response = String.fromCharCodes(responseData);
      if (res.statusCode == 503) {
        isMaintenance(navigatorKey.currentContext!);
      }
      if (res.statusCode == 200) {
        return response;
      } else {
        return null;
      }
    } on SocketException catch (_) {
      throw ApiMessageAndCodeException(errorMessage: StringsRes.noInternet);
    } on ApiMessageAndCodeException catch (e) {
      ApiMessageAndCodeException apiMessageAndCodeException = e;
      if (apiMessageAndCodeException.errorStatusCode == tockenExpireCode) {
        reLogin(navigatorKey.currentContext!);
      }
      throw ApiMessageAndCodeException(
          errorMessage: apiMessageAndCodeException.errorMessage.toString(),
          errorStatusCode:
              apiMessageAndCodeException.errorStatusCode.toString());
    } catch (e) {
      throw ApiMessageAndCodeException(errorMessage: e.toString());
    }
  }

  static Future postApiFileProfilePic(
      Uri url, Map<String, File?> fileList, Map<String, String?> body) async {
    try {
      var request = http.MultipartRequest('POST', url);
      request.headers.addAll(Api.getHeaders());
      body.forEach((key, value) {
        request.fields[key] = value!;
      });

      fileList.forEach((key, value) async {
        final mimeType = lookupMimeType(value!.path);
        var extension = mimeType!.split("/");
        var pic = await http.MultipartFile.fromPath(key, value.path,
            contentType: MediaType(imageKey, extension[1]));
        request.files.add(pic);
      });
      var res = await request.send();
      var responseData = await res.stream.toBytes();
      var response = String.fromCharCodes(responseData);
      if (res.statusCode == 503) {
        isMaintenance(navigatorKey.currentContext!);
      }
      if (res.statusCode == 200) {
        return response;
      } else {
        return null;
      }
    } on SocketException catch (_) {
      throw ApiMessageAndCodeException(errorMessage: StringsRes.noInternet);
    } on ApiMessageAndCodeException catch (e) {
      ApiMessageAndCodeException apiMessageAndCodeException = e;
      if (apiMessageAndCodeException.errorStatusCode == tockenExpireCode) {
        reLogin(navigatorKey.currentContext!);
      }
      throw ApiMessageAndCodeException(
          errorMessage: apiMessageAndCodeException.errorMessage.toString(),
          errorStatusCode:
              apiMessageAndCodeException.errorStatusCode.toString());
    } catch (e) {
      throw ApiMessageAndCodeException(errorMessage: e.toString());
    }
  }

  static convertJson(Response response) {
    return json.decode(response.body);
  }

//api end points
  static String loginUrl = "${databaseUrl}login";
  static String updateFcmUrl = "${databaseUrl}update_fcm";
  // static String getLoginIdentityUrl = "${databaseUrl}get_login_identity";
  static String verifyUserUrl = "${databaseUrl}verify_user";
  static String registerUserUrl = "${databaseUrl}register_user";
  static String updateUserUrl = "${databaseUrl}update_user";
  static String isCityDeliverableUrl = "${databaseUrl}is_city_deliverable";
  static String getSliderImagesUrl = "${databaseUrl}get_slider_images";
  static String getOfferImagesUrl = "${databaseUrl}get_offer_images";
  static String getCategoriesUrl = "${databaseUrl}get_categories";
  static String getCitiesUrl = "${databaseUrl}get_cities";
  static String getProductsUrl = "${databaseUrl}get_products";
  static String validatePromoCodeUrl = "${databaseUrl}validate_promo_code";
  static String getPartnersUrl = "${databaseUrl}get_partners";
  static String getBranchesUrl = "${databaseUrl}get_branches";
  static String addAddressUrl = "${databaseUrl}add_address";
  static String updateAddressUrl = "${databaseUrl}update_address";
  static String getAddressUrl = "${databaseUrl}get_address";
  static String deleteAddressUrl = "${databaseUrl}delete_address";
  static String getSettingsUrl = "${databaseUrl}get_settings";
  static String placeOrderUrl = "${databaseUrl}place_order";
  static String getOrdersUrl = "${databaseUrl}get_orders";
  static String setProductRatingUrl = "${databaseUrl}set_product_rating";
  static String deleteProductRatingUrl = "${databaseUrl}delete_product_rating";
  static String getProductRatingUrl = "${databaseUrl}get_product_rating";
  static String manageCartUrl = "${databaseUrl}manage_cart";
  static String getUserCartUrl = "${databaseUrl}get_user_cart";
  static String addToFavoritesUrl = "${databaseUrl}add_to_favorites";
  static String removeFromFavoritesUrl = "${databaseUrl}remove_from_favorites";
  static String getFavoritesUrl = "${databaseUrl}get_favorites";
  static String getNotificationsUrl = "${databaseUrl}get_notifications";
  static String updateOrderStatusUrl = "${databaseUrl}update_order_status";
  static String addTransactionUrl = "${databaseUrl}add_transaction";
  static String getSectionsUrl = "${databaseUrl}get_sections";
  static String transactionsUrl = "${databaseUrl}transactions";
  static String deleteOrderUrl = "${databaseUrl}delete_order";
  static String getTicketTypesUrl = "${databaseUrl}get_ticket_types";
  static String addTicketUrl = "${databaseUrl}add_ticket";
  static String editTicketUrl = "${databaseUrl}edit_ticket";
  static String sendMessageUrl = "${databaseUrl}send_message";
  static String getTicketsUrl = "${databaseUrl}get_tickets";
  static String getMessagesUrl = "${databaseUrl}get_messages";
  static String setRiderRatingUrl = "${databaseUrl}set_rider_rating";
  static String getRiderRatingUrl = "${databaseUrl}get_rider_rating";
  static String deleteRiderRatingUrl = "${databaseUrl}delete_rider_rating";
  static String getFaqsUrl = "${databaseUrl}get_faqs";
  static String getPromoCodesUrl = "${databaseUrl}get_promo_codes";
  static String removeFromCartUrl = "${databaseUrl}remove_from_cart";
  static String makePaymentsUrl = "${databaseUrl}make_payments";
  static String getPaypalLinkUrl = "${databaseUrl}get_paypal_link";
  static String paypalTransactionWebviewUrl =
      "${databaseUrl}paypal_transaction_webview";
  static String appPaymentStatusUrl = "${databaseUrl}app_payment_status";
  static String ipnUrl = "${databaseUrl}ipn";
  static String stripeWebhookUrl = "${databaseUrl}stripe_webhook";
  static String generatePaytmChecksumUrl =
      "${databaseUrl}generate_paytm_checksum";
  static String generatePaytmTxnTokenUrl =
      "${databaseUrl}generate_paytm_txn_token";
  static String validatePaytmChecksumUrl =
      "${databaseUrl}validate_paytm_checksum";
  static String validateReferCodeUrl = "${databaseUrl}validate_refer_code";
  static String flutterwaveWebviewUrl = "${databaseUrl}flutterwave_webview";
  static String flutterwavePaymentResponseUrl =
      "${databaseUrl}flutterwave_payment_response";
  static String getDeliveryChargesUrl = "${databaseUrl}get_delivery_charges";
  static String getLiveTrackingDetailsUrl =
      "${databaseUrl}get_live_tracking_details";
  static String deleteMyAccountUrl = "${databaseUrl}delete_my_account";
  static String sendWithdrawRequestUrl =
      "${databaseUrl}send_withdrawal_request";
  static String getWithdrawRequestUrl = "${databaseUrl}get_withdrawal_request";
  static String setOrderRatingUrl = "${databaseUrl}set_order_rating";
  static String deleteOrderRatingUrl = "${databaseUrl}delete_order_rating";
  static String getOrderRatingUrl = "${databaseUrl}get_order_rating";
  static String getPartnerRatingsUrl = "${databaseUrl}get_partner_ratings";
  static String signUpUrl = "${databaseUrl}sign_up";
  static String isOrderDeliverableUrl = "${databaseUrl}is_order_deliverable";
  static String createMidtransTransactionUrl =
      "${databaseUrl}create_midtrans_transaction";
  static String getMidtransTransactionStatusUrl =
      "${databaseUrl}get_midtrans_transaction_status";
  static String midtransWalletTransactionUrl =
      "${databaseUrl}midtrans_wallet_transaction";
  static String reOrderUrl = "${databaseUrl}re_order";
  static String phonepeCheckSumUrl = "${databaseUrl}phonepe_app";
  static String verifyOtpUrl = "${databaseUrl}verify_otp";
  static String resendOtpUrl = "${databaseUrl}resend_otp";
  static String getOfflineProductsUrl = "${databaseUrl}get_offline_products";
  static String searchLocationUrl = "${databaseUrl}search_location";
  static String getLocationDetailsUrl = "${databaseUrl}get_location_details";
}
