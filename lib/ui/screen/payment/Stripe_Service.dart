import 'dart:convert';
import 'dart:math';
import 'package:erestroSingleVender/cubit/auth/authCubit.dart';
import 'package:erestroSingleVender/ui/screen/cart/cart_screen.dart';
import 'package:erestroSingleVender/utils/apiBodyParameterLabels.dart';
import 'package:erestroSingleVender/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

class StripeTransactionResponse {
  final String? message, status;
  bool? success;

  StripeTransactionResponse({this.message, this.success, this.status});
}

class StripeService {
  static String apiBase = 'https://api.stripe.com/v1';
  static String paymentApiUrl = '${StripeService.apiBase}/payment_intents';
  static String? secret;

  static Map<String, String> headers = {
    'Authorization': 'Bearer ${StripeService.secret}',
    'Content-Type': 'application/x-www-form-urlencoded'
  };

  static init(String? stripeId, String? stripeMode) async {
    Stripe.publishableKey = stripeId ?? '';
    Stripe.merchantIdentifier = merchantIdentifierData;
    await Stripe.instance.applySettings();
  }

  static Future<StripeTransactionResponse> payWithPaymentSheet(
      {String? amount,
      String? currency,
      String? from,
      BuildContext? context}) async {
    try {
      //create Payment intent
      var paymentIntent = await (StripeService.createPaymentIntent(
          amount, currency, from, context));
      //setting up Payment Sheet
      await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
              paymentIntentClientSecret: paymentIntent![clientSecretKey],
              applePay: const PaymentSheetApplePay(
                merchantCountryCode: merchantCountryCodeData,
              ),
              googlePay: const PaymentSheetGooglePay(
                merchantCountryCode: merchantCountryCodeData,
                testEnv: true,
              ),
              style: ThemeMode.light,
              merchantDisplayName: merchantDisplayNameData));

      //open payment sheet
      await Stripe.instance.presentPaymentSheet();

      //store paymentID of customer
      stripePayId = paymentIntent[idKey];

      //confirm payment
      var response = await http.post(
          Uri.parse('${StripeService.paymentApiUrl}/$stripePayId'),
          headers: headers);
      var getdata = json.decode(response.body);
      var statusOfTransaction = getdata[statusKey];
      print("$response\n$getdata\n${getdata[statusKey]}\n$statusOfTransaction");

      if (statusOfTransaction == succeededKey) {
        return StripeTransactionResponse(
            message: transactionSuccessful,
            success: true,
            status: statusOfTransaction);
      } else if (statusOfTransaction == pendingKey ||
          statusOfTransaction == capturedKey) {
        return StripeTransactionResponse(
            message: transactionPending,
            success: true,
            status: statusOfTransaction);
      } else {
        return StripeTransactionResponse(
            message: transactionFailed,
            success: false,
            status: statusOfTransaction);
      }
    } on PlatformException catch (error) {
      return StripeService.getPlatformExceptionErrorResult(error);
    } catch (error) {
      return StripeTransactionResponse(
          message: '$transactionFailed: ${error.toString()}',
          success: false,
          status: 'fail');
    }
  }

  static getPlatformExceptionErrorResult(err) {
    String message = defaultErrorMessage;
    if (err.code == cancelledKey) {
      message = transactionCancelled;
    }
    return StripeTransactionResponse(
        message: message, success: false, status: cancelledKey);
  }

  static Future<Map<String, dynamic>?> createPaymentIntent(String? amount,
      String? currency, String? from, BuildContext? context) async {
    //pre-define style to add transaction using webhook
    String orderId =
        'wallet-refill-user-${context!.read<AuthCubit>().getId()}-${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(900) + 100}';

    try {
      Map<String, dynamic> parameter = {
        amountKey: amount,
        currencyKey: currency,
        paymentMethodTypesKey: 'card',
        descriptionKey: from,
      };
      if (from == 'wallet') parameter[metadataOrderIdKey] = orderId;

      var response = await http.post(Uri.parse(StripeService.paymentApiUrl),
          body: parameter, headers: StripeService.headers);
      print("$response\n$parameter\n${response.body}");

      return jsonDecode(response.body.toString());
    } catch (error) {
      print(error.toString());
    }
    return null;
  }
}
