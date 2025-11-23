import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:erestroSingleVender/cubit/address/addressCubit.dart';
import 'package:erestroSingleVender/cubit/auth/authCubit.dart';
import 'package:erestroSingleVender/cubit/settings/settingsCubit.dart';
import 'package:erestroSingleVender/data/model/cartModel.dart';
import 'package:erestroSingleVender/cubit/cart/getCartCubit.dart';
import 'package:erestroSingleVender/cubit/home/search/filterCubit.dart';
import 'package:erestroSingleVender/cubit/systemConfig/systemConfigCubit.dart';
import 'package:erestroSingleVender/ui/screen/payment/Stripe_Service.dart';
import 'package:erestroSingleVender/ui/screen/payment/midtransWebView.dart';
import 'package:erestroSingleVender/ui/screen/payment/payment_radio.dart';
import 'package:erestroSingleVender/ui/screen/payment/paypal_webview_screen.dart';
import 'package:erestroSingleVender/ui/screen/cart/cart_screen.dart';
import 'package:erestroSingleVender/ui/screen/settings/no_internet_screen.dart';
import 'package:erestroSingleVender/ui/screen/order/thank_you_for_order.dart';
import 'package:erestroSingleVender/ui/widgets/buttomContainer.dart';
import 'package:erestroSingleVender/ui/widgets/simmer/cartSimmer.dart';
import 'package:erestroSingleVender/utils/api.dart';
import 'package:erestroSingleVender/utils/apiBodyParameterLabels.dart';
import 'package:erestroSingleVender/utils/constants.dart';
import 'package:erestroSingleVender/utils/internetConnectivity.dart';
import 'package:erestroSingleVender/utils/labelKeys.dart';
import 'package:erestroSingleVender/utils/uiUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:erestroSingleVender/ui/styles/design.dart';
import 'package:erestroSingleVender/utils/string.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_paystack/flutter_paystack.dart';
import 'package:http/http.dart';
import 'package:paytmpayments_allinonesdk/paytmpayments_allinonesdk.dart';
import 'package:phonepe_payment_sdk/phonepe_payment_sdk.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:crypto/crypto.dart';

class PaymentScreen extends StatefulWidget {
  final CartModel? cartModel;
  final String? addNote;
  const PaymentScreen({Key? key, this.cartModel, this.addNote})
      : super(key: key);

  @override
  PaymentScreenState createState() => PaymentScreenState();
  static Route<dynamic> route(RouteSettings routeSettings) {
    Map arguments = routeSettings.arguments as Map;
    return CupertinoPageRoute(
        builder: (_) => BlocProvider<FilterCubit>(
              create: (_) => FilterCubit(),
              child: PaymentScreen(
                  cartModel: arguments['cartModel'] as CartModel,
                  addNote: arguments['addNote']),
            ));
  }
}

bool codAllowed = true;
String? bankName, bankNo, acName, acNo, exDetails;

class PaymentScreenState extends State<PaymentScreen> {
  double? width, height;
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  int? addressIndex;
  String? startingDate;
  CartModel cartModel = CartModel();

  late bool cod = false,
      paypal = false,
      razorpay = false,
      paumoney = false,
      paystack = false,
      flutterwave = false,
      stripe = false,
      paytm = true,
      gpay = false,
      midtrans = false,
      phonepe = false;
  List<RadioModel> paymentModel = [];

  List<String?> paymentMethodList = [];
  List<String> paymentIconList = [
    'cash_delivery',
    'paypal',
    'rozerpay',
    'paystack',
    'flutterwave',
    'stripe',
    'paytm',
    'midtrans',
    'phonepe'
  ];

  Razorpay? _razorpay;
  final payStackPlugin = PaystackPlugin();
  bool _placeOrder = false;
  final plugin = PaystackPlugin();
  String addressId = "";
  List<String> codAllowedList = [];

  @override
  void initState() {
    super.initState();
    context
        .read<SystemConfigCubit>()
        .getSystemConfig(context.read<AuthCubit>().getId());
    getPaymentMethod();
    CheckInternet.initConnectivity().then((List<ConnectivityResult> results) {
      if (results.isNotEmpty) {
        setState(() {
          _connectionStatus = results;
        });
      }
    });

    _connectivitySubscription = _connectivity.onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      if (results.isNotEmpty) {
        CheckInternet.updateConnectionStatus(results).then((value) {
          setState(() {
            _connectionStatus = value;
          });
        });
      }
    });

    _razorpay = Razorpay();
    _razorpay!.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay!.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay!.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    Future.delayed(Duration.zero, () {
      paymentMethodList = [
        UiUtils.getTranslatedLabel(context, caseOnDeliveryLblLabel),
        UiUtils.getTranslatedLabel(context, payPalLblLabel),
        UiUtils.getTranslatedLabel(context, razorpayLblLabel),
        UiUtils.getTranslatedLabel(context, payStackLblLabel),
        UiUtils.getTranslatedLabel(context, flutterWaveLblLabel),
        UiUtils.getTranslatedLabel(context, stripeLblLabel),
        UiUtils.getTranslatedLabel(context, paytmLblLabel),
        UiUtils.getTranslatedLabel(context, midtransLable),
        UiUtils.getTranslatedLabel(context, phonePeLable),
      ];
    });
    if (context.read<GetCartCubit>().getCartModel().variantId!.isEmpty) {
      Future.delayed(Duration.zero, () async {
        await context.read<GetCartCubit>().getCartUser(
            branchId: context.read<SettingsCubit>().getSettings().branchId);
      }).then((value) => codeMethodCheck());
    }
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
  }

  double total() {
    if (isUseWallet == true) {
      if (orderTypeIndex.toString() == "0") {
        return (context.read<GetCartCubit>().getCartModel().overallAmount! +
            deliveryCharge +
            deliveryTip -
            promoAmt -
            walletBalanceUsed);
      } else {
        return (context.read<GetCartCubit>().getCartModel().overallAmount! +
            deliveryTip -
            promoAmt -
            walletBalanceUsed);
      }
    } else {
      if (orderTypeIndex.toString() == "0") {
        return (context.read<GetCartCubit>().getCartModel().overallAmount! +
            deliveryCharge +
            deliveryTip -
            promoAmt +
            walletBalanceUsed);
      } else {
        return (context.read<GetCartCubit>().getCartModel().overallAmount! +
            deliveryTip -
            promoAmt +
            walletBalanceUsed);
      }
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    placeOrder(response.paymentId);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    print("payment error" + response.toString());
    if (mounted) {
      setState(() {
        _placeOrder = false;
      });
    }
    var getdata = json.decode(response.message!);
    String errorMsg = getdata[errorKey]["description"];
    UiUtils.setSnackBar(errorMsg, context, false, type: "2");
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    if (mounted) {
      setState(() {
        _placeOrder = false;
      });
    }
  }

  Future<void> getPaymentMethod() async {
    try {
      var parameter = {
        typeKey: paymentMethodKey,
        userIdKey: context.read<AuthCubit>().getId()
      };
      Response response = await post(Uri.parse(Api.getSettingsUrl),
              body: parameter, headers: Api.getHeaders())
          .timeout(const Duration(seconds: 50));

      if (response.statusCode == 200) {
        var getdata = json.decode(response.body);

        bool error = getdata[errorKey];
        if (!error) {
          var data = getdata[dataKey];
          var payment = data["payment_method"];
          print("payment:$payment");
          paypal = payment["paypal_payment_method"] == "1" ? true : false;
          paumoney = payment["payumoney_payment_method"] == "1" ? true : false;
          flutterwave =
              payment["flutterwave_payment_method"] == "1" ? true : false;
          razorpay = payment["razorpay_payment_method"] == "1" ? true : false;
          paystack = payment["paystack_payment_method"] == "1" ? true : false;
          stripe = payment["stripe_payment_method"] == "1" ? true : false;
          paytm = payment["paytm_payment_method"] == "1" ? true : false;
          midtrans = payment["midtrans_payment_method"] == "1" ? true : false;
          phonepe = payment['phonepe_payment_method'] == '1' ? true : false;

          for (int i = 0; i < cartModel.data!.length; i++) {
            codAllowedList
                .add(cartModel.data![i].productDetails![0].codAllowed!);
          }
          if (codAllowedList.contains("0")) {
            cod = false;
            codAllowed = false;
          } else {
            codAllowed = data["is_cod_allowed"] == 1 ? true : false;
            cod = codAllowed
                ? payment["cod_method"] == "1"
                    ? true
                    : false
                : false;
          }

          if (razorpay) razorpayId = payment["razorpay_key_id"];
          if (paystack) {
            paystackId = payment["paystack_key_id"];

            await plugin.initialize(publicKey: paystackId!);
          }
          if (stripe) {
            stripeId = payment['stripe_publishable_key'];
            stripeSecret = payment['stripe_secret_key'];
            stripeCurCode = payment['stripe_currency_code'];
            stripeMode = payment['stripe_mode'] ?? 'test';
            StripeService.secret = stripeSecret;
            StripeService.init(stripeId, stripeMode);
          }
          if (paytm) {
            paytmMerId = payment['paytm_merchant_id'];
            paytmMerKey = payment['paytm_merchant_key'];
            payTesting =
                payment['paytm_payment_mode'] == 'sandbox' ? true : false;
          }
          if (midtrans) {
            midTranshMerchandId = payment['midtrans_merchant_id'];
            midtransPaymentMethod = payment['midtrans_payment_method'];
            midtransPaymentMode = payment['midtrans_payment_mode'];
            midtransServerKey = payment['midtrans_server_key'];
            midtrasClientKey = payment['midtrans_client_key'];
          }

          for (int i = 0; i < paymentMethodList.length; i++) {
            paymentModel.add(RadioModel(
                isSelected: i == selectedMethod ? true : false,
                name: paymentMethodList[i],
                img: paymentIconList[i]));
          }
        } else {}
      }
      if (mounted) {
        setState(() {});
      }
    } on TimeoutException catch (_) {}
  }

  doPayment() {
    if (paymentMethod == UiUtils.getTranslatedLabel(context, payPalLblLabel)) {
      placeOrder('');
    } else if (paymentMethod ==
        UiUtils.getTranslatedLabel(context, razorpayLblLabel)) {
      razorpayPayment();
    } else if (paymentMethod ==
        UiUtils.getTranslatedLabel(context, payStackLblLabel)) {
      payStackPayment(context);
    } else if (paymentMethod ==
        UiUtils.getTranslatedLabel(context, flutterWaveLblLabel)) {
      placeOrder('');
    } else if (paymentMethod ==
        UiUtils.getTranslatedLabel(context, stripeLblLabel)) {
      stripePayment();
    } else if (paymentMethod ==
        UiUtils.getTranslatedLabel(context, paytmLblLabel)) {
      paytmPayment();
    } else if (paymentMethod ==
        UiUtils.getTranslatedLabel(context, phonePeLable)) {
      placeOrder('');
    } else {
      placeOrder('');
    }
  }

  void paytmPayment() async {
    String? paymentResponse;

    String orderId = DateTime.now().millisecondsSinceEpoch.toString();

    String callBackUrl =
        '${payTesting ? 'https://securegw-stage.paytm.in' : 'https://securegw.paytm.in'}/theia/paytmCallback?ORDER_ID=$orderId';

    var body = {
      amountKey: "${total().toStringAsFixed(2)}",
      userIdKey: context.read<AuthCubit>().getId(),
      orderIdKey: orderId
    };

    try {
      final result = await Api.post(
          body: body,
          url: Api.generatePaytmTxnTokenUrl,
          token: true,
          errorCode: true);
      bool error = result[errorKey];

      if (!error) {
        String txnToken = result["txn_token"];

        setState(() {
          paymentResponse = txnToken;
        });

        var paytmResponse = PaytmPaymentsAllinonesdk().startTransaction(
            callBackUrl,
            paytmMerId!,
            orderId,
            txnToken,
            total().toStringAsFixed(2),
            payTesting,
            false);
        paytmResponse.then((value) {
          _placeOrder = false;
          setState(() {});
          if (value![errorKey]) {
            paymentResponse = value['errorMessage'];

            if (value['response'] != "") {
              addTransaction(value['response']['TXNID'], orderId,
                  value['response']['STATUS'] ?? '', paymentResponse, false);
            }
          } else {
            if (value['response'] != "") {
              paymentResponse = value['response']['STATUS'];
              if (paymentResponse == "TXN_SUCCESS") {
                placeOrder(value['response']['TXNID']);
              } else {
                addTransaction(
                    value['response']['TXNID'],
                    orderId,
                    value['response']['STATUS'],
                    value['errorMessage'] ?? '',
                    false);
              }
            }
          }
          UiUtils.setSnackBar(paymentResponse!, context, false, type: "1");
        });
      } else {
        if (mounted) {
          setState(() {
            _placeOrder = false;
          });
        }
        if (!mounted) return;
        UiUtils.setSnackBar(result[messageKey], context, false, type: "2");
      }
    } catch (e) {
      print(e);
    }
  }

  razorpayPayment() async {
    String? contact = context.read<AuthCubit>().getMobile();
    String? email = context.read<AuthCubit>().getEmail();
    String? name = context.read<AuthCubit>().getName();

    String? amt = ((total()) * 100).toStringAsFixed(2);

    var options = {
      key: razorpayId,
      amountKey: "${(double.parse(amt)).toStringAsFixed(2)}",
      nameKey: name,
      'prefill': {contactKey: contact, emailKey: email},
    };

    try {
      _razorpay!.open(options);
    } catch (e) {
      UiUtils.setSnackBar(e.toString(), context, false, type: "2");
      if (mounted) {
        setState(() {
          _placeOrder = false;
        });
      }
      debugPrint(e.toString());
    }
  }

  payStackPayment(BuildContext context) async {
    await payStackPlugin.initialize(publicKey: paystackId!);
    if (!mounted) return;
    String? email = context.read<AuthCubit>().getEmail();

    int amountdata = (total() * 100).toInt();
    Charge charge = Charge()
      ..amount = amountdata
      ..reference = _getReference()
      ..email = email;

    try {
      CheckoutResponse response = await payStackPlugin.checkout(
        context,
        method: CheckoutMethod.card,
        charge: charge,
      );
      if (response.status) {
        placeOrder(response.reference);
      } else {
        UiUtils.setSnackBar(response.message, context, false, type: "2");
        if (mounted) {
          setState(() {
            _placeOrder = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        _placeOrder = false;
      });
      rethrow;
    }
  }

  String _getReference() {
    String platform;
    if (Platform.isIOS) {
      platform = 'iOS';
    } else {
      platform = 'Android';
    }

    return 'ChargedFrom${platform}_${DateTime.now().millisecondsSinceEpoch}';
  }

  Future<void> phonepeCheckSum(String orderId) async {
    try {
      var parameter = {
        typeKey: "cart",
        transationIdKey: orderId,
        deviceOsKey: Platform.isAndroid ? "ANDROID" : "IOS",
        orderIdKey: orderId,
      };
      Response response = await post(Uri.parse(Api.phonepeCheckSumUrl),
              body: parameter, headers: Api.getHeaders())
          .timeout(const Duration(seconds: 50));
      var getdata = json.decode(response.body);
      print('getdata*****checksum order****$getdata--$parameter');

      var jsonData = getdata['data']['payload'];
      String checksum = getdata['data']['checksum'];
      print("payload:${getdata['data']['payload']}--$checksum");
      phonePeMode = getdata['data']["environment"];
      phonePeMerId = getdata['data']['payload']["merchantId"];
      appId = getdata['data']["appId"];
      phonePeEndPointUrl = getdata['data']['payload']["callbackUrl"];
      initPhonePeSdk(
          orderId: orderId, jsonDatas: jsonData, checksums: checksum);

      if (mounted) {
        setState(() {});
      }
    } on TimeoutException catch (_) {
      UiUtils.setSnackBar(StringsRes.somethingMsg, context, false, type: "2");

      setState(() {});
    }
  }

  void initPhonePeSdk(
      {required String orderId,
      Map<String, dynamic>? jsonDatas,
      String? checksums}) async {
    print("phonePeMerId:$phonePeMerId--$phonePeMode");

    PhonePePaymentSdk.init(phonePeMode!, appId!, phonePeMerId!, true)
        .then((isInitialized) {
      print("phonePeMerId:$phonePeMerId");
      startPaymentPhonePe(
          orderId: orderId, jsonDatas: jsonDatas, checksums: checksums);
    }).catchError((error) {
      print("error::$error");

      return error;
    });
  }

  void startPaymentPhonePe(
      {required String orderId,
      Map<String, dynamic>? jsonDatas,
      String? checksums}) async {
    try {
      print("verify:${jsonDatas}");

      String body = '';

      print("verify:--$body");
      String base64Data = base64Encode(utf8.encode(jsonEncode(jsonDatas)));
      body = base64Data;

      PhonePePaymentSdk.startTransaction(body, phonePeEndPointUrl!, checksums!,
              Platform.isAndroid ? packageName : iosPackage)
          .then((response) async {
        if (kDebugMode) {
          print("response ::--${response != null}");
        }
        if (response != null) {
          String status = response['status'].toString();

          if (status == 'SUCCESS') {
            print("data:--");

            clearAll();

            await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        ThankYouForOrderScreen(orderId: orderId.toString())));
            context.read<GetCartCubit>().clearCartModel();
          } else {
            deleteOrder(orderId).then((value) {
              context.read<GetCartCubit>().getCartUser(
                  branchId:
                      context.read<SettingsCubit>().getSettings().branchId);
            });
            if (mounted) {
              setState(() {
                _placeOrder = true;
              });
            }
          }
        } else {
          deleteOrder(orderId).then((value) {
            context.read<GetCartCubit>().getCartUser(
                branchId: context.read<SettingsCubit>().getSettings().branchId);
          });
          if (mounted) {
            setState(() {
              _placeOrder = true;
            });
          }
        }
      }).catchError((error) {
        print("error 82 ${error}");

        UiUtils.setSnackBar(error.toString(), context, false, type: "2");
      });
    } catch (error) {
      print("error 91 ${error}");
    }
  }

  String generateSha256Hash(String input) {
    var bytes = utf8.encode(input);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<void> placeOrder(String? tranId) async {
    try {
      String? varientId, quantity, cartIds;

      print(
          "cartMdel:${cartModel.variantId}----${(context.read<GetCartCubit>().getCartModel().variantId)}");
      varientId = cartModel.variantId!.join(",");
      for (int i = 0; i < cartModel.data!.length; i++) {
        quantity = quantity != null
            ? "$quantity,${cartModel.data![i].qty!}"
            : cartModel.data![i].qty!;
        cartIds = cartIds != null
            ? "$cartIds,${cartModel.data![i].cartId}"
            : cartModel.data![i].cartId;
      }

      String? payVia;
      if (paymentMethod ==
          UiUtils.getTranslatedLabel(context, caseOnDeliveryLblLabel)) {
        payVia = "COD";
      } else if (paymentMethod ==
          UiUtils.getTranslatedLabel(context, payPalLblLabel)) {
        payVia = "PayPal";
      } else if (paymentMethod ==
          UiUtils.getTranslatedLabel(context, razorpayLblLabel)) {
        payVia = "RazorPay";
      } else if (paymentMethod ==
          UiUtils.getTranslatedLabel(context, payStackLblLabel)) {
        payVia = "Paystack";
      } else if (paymentMethod ==
          UiUtils.getTranslatedLabel(context, flutterWaveLblLabel)) {
        payVia = "Flutterwave";
      } else if (paymentMethod ==
          UiUtils.getTranslatedLabel(context, stripeLblLabel)) {
        payVia = "Stripe";
      } else if (paymentMethod ==
          UiUtils.getTranslatedLabel(context, paytmLblLabel)) {
        payVia = "Paytm";
      } else if (paymentMethod ==
          UiUtils.getTranslatedLabel(context, walletLabel)) {
        payVia = "Wallet";
      } else if (paymentMethod ==
          UiUtils.getTranslatedLabel(context, midtransLable)) {
        payVia = "midtrans";
      } else if (paymentMethod ==
          UiUtils.getTranslatedLabel(context, phonePeLable)) {
        payVia = "phonepe";
      }

      var parameter = {
        mobileKey: context
                .read<AddressCubit>()
                .gerCurrentAddress()
                .mobile
                .toString()
                .isEmpty
            ? context.read<AuthCubit>().getMobile()
            : context
                .read<AddressCubit>()
                .gerCurrentAddress()
                .mobile
                .toString(), //context.read<SystemConfigCubit>().getMobile(),
        productVariantIdKey: varientId,
        quantityKey: quantity,
        totalKey:
            overAllAmount.toStringAsFixed(2), //subTotal.toStringAsFixed(2),
        finalTotalKey: total().toStringAsFixed(2),
        deliveryChargeKey:
            orderTypeIndex.toString() == "0" ? deliveryCharge.toString() : "0",
        taxAmountKey: taxAmount.toString(),
        promoCodeKey: promoCode ?? "",
        taxPercentageKey: taxPercentage.toString(),
        latitudeKey: latitude.toString(),
        longitudeKey: longitude.toString(),
        paymentMethodKey: payVia,
        addressIdKey: orderTypeIndex.toString() == "0" ? selAddress : "",
        isWalletUsedKey: isUseWallet! ? "1" : "0",
        walletBalanceUsedKey: walletBalanceUsed.toString(),
        orderNoteKey: widget.addNote,
        deliveryTipKey: deliveryTip.toString(),
        isSelfPickUpKey: orderTypeIndex.toString(),
        branchIdKey: context.read<SettingsCubit>().getSettings().branchId,
        cartIdsKey: cartIds
      };

      if (isPromoValid!) {
        parameter[promoCodeKey] = promoCode;
      }
      if (orderTypeIndex.toString() == "0") {
        parameter[addressIdKey] = selAddress;
      }

      if (paymentMethod ==
          UiUtils.getTranslatedLabel(context, payPalLblLabel)) {
        parameter["active_status"] = waitingKey;
      } else if (paymentMethod ==
          UiUtils.getTranslatedLabel(context, stripeLblLabel)) {
        parameter["active_status"] = waitingKey;
      } else if (paymentMethod ==
          UiUtils.getTranslatedLabel(context, midtransLable)) {
        parameter["active_status"] = waitingKey;
      } else if (paymentMethod ==
          UiUtils.getTranslatedLabel(context, phonePeLable)) {
        parameter["active_status"] = draftKey;
      } else if (paymentMethod ==
          UiUtils.getTranslatedLabel(context, flutterWaveLblLabel)) {
        parameter["active_status"] = waitingKey;
      }

      print("body:$parameter");

      Response response = await post(Uri.parse(Api.placeOrderUrl),
              body: parameter, headers: Api.getHeaders())
          .timeout(const Duration(seconds: 50));

      print(response.statusCode);
      if (response.statusCode == 200) {
        var getdata = json.decode(response.body);
        print(getdata);
        bool error = getdata[errorKey];
        String? msg = getdata[messageKey];
        print("placeOrder:$msg");
        if (!error) {
          String orderId = getdata[orderIdKey].toString();

          if (paymentMethod ==
              UiUtils.getTranslatedLabel(context, razorpayLblLabel)) {
            addTransaction(tranId, orderId, "success", msg, true);
          } else if (paymentMethod ==
              UiUtils.getTranslatedLabel(context, payPalLblLabel)) {
            paypalPayment(orderId);
          } else if (paymentMethod ==
              UiUtils.getTranslatedLabel(context, stripeLblLabel)) {
            addTransaction(stripePayId, orderId,
                tranId == "succeeded" ? placedKey : waitingKey, msg, true);
          } else if (paymentMethod ==
              UiUtils.getTranslatedLabel(context, payStackLblLabel)) {
            addTransaction(tranId, orderId, "success", msg, true);
          } else if (paymentMethod ==
              UiUtils.getTranslatedLabel(context, paytmLblLabel)) {
            addTransaction(tranId, orderId, "success", msg, true);
          } else if (paymentMethod ==
              UiUtils.getTranslatedLabel(context, midtransLable)) {
            midtrasPayment(orderId, waitingKey, msg, true);
          } else if (paymentMethod ==
              UiUtils.getTranslatedLabel(context, phonePeLable)) {
            phonepeCheckSum(orderId);
          } else if (paymentMethod ==
              UiUtils.getTranslatedLabel(context, flutterWaveLblLabel)) {
            flutterWavePayment(orderId);
          } else {
            clearAll();

            await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        ThankYouForOrderScreen(orderId: orderId.toString())));
            context.read<GetCartCubit>().clearCartModel();
          }
          context
              .read<SystemConfigCubit>()
              .getSystemConfig(context.read<AuthCubit>().getId());
        } else {
          if (getdata[statusCodeKey].toString() == tockenExpireCode) {
            reLogin(context);
          }
          if (!mounted) return;
          UiUtils.setSnackBar(msg!, context, false, type: "2");
          if (mounted) {
            setState(() {
              _placeOrder = false;
            });
          }
        }
      } else {
        var getdata = json.decode(response.body);
        print("getdata: $getdata");
        if (getdata[statusCodeKey].toString() == tockenExpireCode) {
          reLogin(context);
        }
        if (!mounted) return;

        if (mounted) {
          setState(() {
            _placeOrder = false;
          });
        }
      }
    } on TimeoutException catch (_) {
      if (mounted) {
        setState(() {
          _placeOrder = false;
        });
      }
      UiUtils.setSnackBar(StringsRes.somethingMsg, context, false, type: "2");
    } catch (e) {
      if (mounted) {
        setState(() {
          _placeOrder = false;
        });
      }
      UiUtils.setSnackBar(e.toString(), context, false, type: "2");
    }
  }

  Future<void> paypalPayment(String orderId) async {
    try {
      var body = {
        userIdKey: context.read<AuthCubit>().getId(),
        orderIdKey: orderId,
        amountKey: total().toStringAsFixed(2)
      };
      final result = await Api.post(
          body: body, url: Api.getPaypalLinkUrl, token: true, errorCode: true);

      bool error = result[errorKey];
      String? msg = result[messageKey];
      if (!error) {
        String? data = result[dataKey];
        Navigator.push(
            context,
            CupertinoPageRoute(
                builder: (BuildContext context) => PaypalWebView(
                      url: data,
                      from: "order",
                      orderId: orderId,
                      addNote: widget.addNote,
                    ))).then((value) {
          Navigator.pop(context);
          context.read<GetCartCubit>().getCartUser(
              branchId: context.read<SettingsCubit>().getSettings().branchId);
        });
      } else {
        UiUtils.setSnackBar(msg!, context, false, type: "2");
      }
    } on TimeoutException catch (_) {
      UiUtils.setSnackBar(StringsRes.somethingMsg, context, false, type: "2");
    }
  }

  clearAll() {
    finalTotal = 0;
    subTotal = 0;
    taxPercentage = 0;
    deliveryCharge = 0;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {});

    promoAmt = 0;
    remWalBal = 0;
    walletBalanceUsed = 0;
    paymentMethod = '';
    promoCode = '';
    isPromoValid = false;
    isUseWallet = false;
    isPayLayShow = true;
    selectedMethod = null;
    orderTypeIndex = 0;
  }

  midtrasPayment(
    String orderID,
    String? status,
    String? msg,
    bool redirect,
  ) async {
    try {
      setState(() {
        _placeOrder = true;
      });

      var parameter = {
        amountKey: "${total().toStringAsFixed(2)}",
        userIdKey: context.read<AuthCubit>().getMobile(),
        orderIdKey: orderID
      };
      await post(Uri.parse(Api.createMidtransTransactionUrl),
              body: parameter, headers: Api.getHeaders())
          .timeout(const Duration(seconds: 50))
          .then(
        (result) {
          var getdata = json.decode(result.body);
          bool error = getdata[errorKey];
          String? msg = getdata[messageKey];
          if (!error) {
            var data = getdata[dataKey];

            String redirectUrl = data['redirect_url'];
            setState(() {
              _placeOrder = false;
            });
            Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (BuildContext context) => MidTrashWebview(
                  url: redirectUrl,
                  from: 'order',
                  orderId: orderID,
                ),
              ),
            ).then(
              (value) async {
                print("value---->: $value");
                Navigator.pop(context);
                setState(() {
                  _placeOrder = false;
                });
                context.read<GetCartCubit>().getCartUser(
                    branchId:
                        context.read<SettingsCubit>().getSettings().branchId);
                if (value == 'true') {
                  setState(() {
                    _placeOrder = true;
                  });
                } else {}
              },
            );
          } else {
            UiUtils.setSnackBar(msg.toString(), context, false, type: "2");
          }
        },
        onError: (error) {
          UiUtils.setSnackBar(error.toString(), context, false, type: "2");
        },
      );
    } on TimeoutException catch (_) {
      UiUtils.setSnackBar(StringsRes.somethingMsg, context, false, type: "2");
    }
  }

  Future<Map<String, dynamic>> updateOrderStatus(
      {required String status, required String orderId}) async {
    var parameter = {orderIdKey: orderId, statusKey: status};
    var response = await post(Uri.parse(Api.updateOrderStatusUrl),
            body: parameter, headers: Api.getHeaders())
        .timeout(const Duration(seconds: 50));
    print('order update status result****$response');
    var result = json.decode(response.body);
    return {errorKey: result[errorKey], messageKey: result[messageKey]};
  }

  Future<void> deleteOrder(String orderId) async {
    try {
      var parameter = {
        orderIdKey: orderId,
      };

      Response response = await post(Uri.parse(Api.deleteOrderUrl),
              body: parameter, headers: Api.getHeaders())
          .timeout(const Duration(seconds: 50));
      var getdata = json.decode(response.body);
      print('getdata*****delete order****$getdata');
      bool error = getdata[errorKey];
      if (!error) {}

      if (mounted) {
        setState(() {});
      }

      Navigator.of(context).pop();
    } on TimeoutException catch (_) {
      UiUtils.setSnackBar(StringsRes.somethingMsg, context, false, type: "2");

      setState(() {});
    }
  }

  stripePayment() async {
    int amountData = ((total() * 100)).toInt();
    var response = await StripeService.payWithPaymentSheet(
        amount: amountData.toString(),
        currency: stripeCurCode,
        from: "order",
        context: context);
    if (response.message == "Transaction successful") {
      placeOrder(response.status);
    } else if (response.status == 'pending' || response.status == "captured") {
      placeOrder(response.status);
    } else {
      if (mounted) {
        setState(() {
          _placeOrder = false;
        });
      }
    }
    if (response.status == 'succeeded') {
      UiUtils.setSnackBar(response.message!, context, false, type: "1");
    } else {
      UiUtils.setSnackBar(response.message!, context, false, type: "2");
    }
  }

  Future<void> addTransaction(String? tranId, String orderID, String? status,
      String? msg, bool redirect) async {
    print("orderId:$orderID");
    try {
      var body = {
        orderIdKey: orderID,
        typeKey: paymentMethod,
        txnIdKey: tranId,
        amountKey: total().toStringAsFixed(2),
        statusKey: status,
        messageKey: msg
      };
      final result = await Api.post(
          body: body, url: Api.addTransactionUrl, token: true, errorCode: true);
      print("addTransaction:$result-----$body");

      bool error = result[errorKey];
      if (!error) {
        if (redirect) {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    ThankYouForOrderScreen(orderId: orderID.toString())),
          );
          context.read<GetCartCubit>().clearCartModel();
        }
      } else {
        if (!mounted) return;
        UiUtils.setSnackBar(msg!, context, false, type: "2");
      }
    } on TimeoutException catch (_) {
      UiUtils.setSnackBar(StringsRes.somethingMsg, context, false, type: "2");
    }
  }

  Future<void> flutterWavePayment(String orderId) async {
    try {
      setState(() {
        _placeOrder = true;
      });
      var body = {
        // amountKey: "${total().toStringAsFixed(2)}",
        referenceKey: orderId,
        userIdKey: context.read<AuthCubit>().getId(),
      };
      final result = await Api.post(
          body: body,
          url: Api.flutterwaveWebviewUrl,
          token: true,
          errorCode: true);
      bool error = result[errorKey];
      String? msg = result[messageKey];
      if (!error) {
        var data = result["link"];
        setState(() {
          _placeOrder = false;
        });
        // if (!mounted) return;
        Navigator.push(
            context,
            CupertinoPageRoute(
                builder: (BuildContext context) => PaypalWebView(
                      url: data,
                      from: "order",
                      addNote: widget.addNote,
                      orderId: orderId,
                    ))).then(
          (value) async {
            // Navigator.pop(context);
            setState(
              () {
                _placeOrder = false;
              },
            );
            context.read<GetCartCubit>().getCartUser(
                branchId: context.read<SettingsCubit>().getSettings().branchId);
            if (value == 'true') {
              setState(() {
                _placeOrder = true;
              });
            } else {}
          },
        );
      } else {
        // if (!mounted) return;
        UiUtils.setSnackBar(msg.toString(), context, false, type: "2");
      }
    } on TimeoutException catch (_) {
      UiUtils.setSnackBar(StringsRes.somethingMsg, context, false, type: "2");
    }
  }

  codeMethodCheck() {
    for (int i = 0; i < cartModel.data!.length; i++) {
      codAllowedList.add(cartModel.data![i].productDetails![0].codAllowed!);
      print("codData$codAllowedList");
    }
    if (codAllowedList.contains("0")) {
      if (paymentMethod ==
          UiUtils.getTranslatedLabel(context, caseOnDeliveryLblLabel)) {
        cod = false;
        codAllowed = false;
      }
    }
  }

  @override
  void dispose() {
    if (_razorpay != null) _razorpay!.clear();
    _connectivitySubscription.cancel();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarIconBrightness: Brightness.dark,
        ),
        child: _connectionStatus == connectivityCheck
            ? const NoInternetScreen()
            : Scaffold(
                backgroundColor: Theme.of(context).colorScheme.surface,
                appBar: DesignConfig.appBar(
                    context,
                    width!,
                    UiUtils.getTranslatedLabel(context, paymentLabel),
                    const PreferredSize(
                        preferredSize: Size.zero, child: SizedBox())),
                bottomNavigationBar: ButtonContainer(
                  color: Theme.of(context).colorScheme.primary,
                  height: height,
                  width: width,
                  text: UiUtils.getTranslatedLabel(context, placeOrderLabel),
                  start: width! / 40.0,
                  end: width! / 40.0,
                  bottom: height! / 55.0,
                  top: 0,
                  status: _placeOrder,
                  borderColor: Theme.of(context).colorScheme.primary,
                  textColor: Theme.of(context).colorScheme.onPrimary,
                  onPressed: () {
                    if (paymentMethod == null || paymentMethod!.isEmpty) {
                      setState(() {
                        _placeOrder = false;
                      });

                      UiUtils.setSnackBar(
                          StringsRes.selectPaymentMethod, context, false,
                          type: "2");
                    } else {
                      if (total() <
                              double.parse(context
                                  .read<SystemConfigCubit>()
                                  .getCartMinAmount()
                                  .toString()) &&
                          total() != 0.00) {
                        UiUtils.setSnackBar(
                            "${StringsRes.cartAmountLessThen}${context.read<SystemConfigCubit>().getCurrency()}${context.read<SystemConfigCubit>().getCartMinAmount().toString()}${StringsRes.totalIs}${context.read<SystemConfigCubit>().getCurrency()}${total().toStringAsFixed(2)}",
                            context,
                            false,
                            type: "2");
                      } else {
                        if (paymentMethod ==
                            UiUtils.getTranslatedLabel(
                                context, caseOnDeliveryLblLabel)) {
                          if (codAllowedList.contains("0")) {
                            UiUtils.setSnackBar(
                                StringsRes.selectAnotherPaymentMethod,
                                context,
                                false,
                                type: "2");
                          } else {
                            if (mounted) {
                              setState(() {
                                _placeOrder = true;
                              });
                            }
                            doPayment();
                          }
                        } else {
                          if (mounted) {
                            setState(() {
                              _placeOrder = true;
                            });
                          }
                          doPayment();
                        }
                      }
                    }
                  },
                ),
                body: BlocBuilder<AuthCubit, AuthState>(
                    builder: (context, state) {
                  return (context.read<AuthCubit>().state is AuthInitial ||
                          context.read<AuthCubit>().state is Unauthenticated)
                      ? Container()
                      : BlocConsumer<GetCartCubit, GetCartState>(
                          bloc: context.read<GetCartCubit>(),
                          listener: (context, state) {},
                          builder: (context, state) {
                            if (state is GetCartProgress ||
                                state is GetCartInitial) {
                              return CartSimmer(width: width!, height: height!);
                            }
                            if (state is GetCartFailure) {
                              return Center(
                                  child: Text(
                                state.errorMessage.toString(),
                                textAlign: TextAlign.center,
                              ));
                            }
                            final cartList =
                                (state as GetCartSuccess).cartModel;
                            cartModel = cartList;

                            return Container(
                              height: height!,
                              width: width,
                              child: SingleChildScrollView(
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                          padding: EdgeInsetsDirectional.only(
                                              start: width! / 20.0,
                                              end: width! / 20.0,
                                              top: height! / 40.0,
                                              bottom: height! / 40.0),
                                          decoration: DesignConfig
                                              .boxDecorationContainer(
                                                  Theme.of(context)
                                                      .colorScheme
                                                      .onSurface,
                                                  0.0),
                                          child: Row(children: [
                                            Text(
                                                UiUtils.getTranslatedLabel(
                                                    context, totalBillLabel),
                                                style: TextStyle(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onPrimary,
                                                    fontWeight: FontWeight.w700,
                                                    fontStyle: FontStyle.normal,
                                                    fontSize: 16.0)),
                                            const Spacer(),
                                            Text(
                                                "${context.read<SystemConfigCubit>().getCurrency()}${total().toStringAsFixed(2)}",
                                                style: TextStyle(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .secondary,
                                                    fontWeight: FontWeight.w600,
                                                    fontStyle: FontStyle.normal,
                                                    fontSize: 14.0))
                                          ])),
                                      BlocBuilder<SystemConfigCubit,
                                          SystemConfigState>(
                                        builder: (context, state) {
                                          return Container(
                                            padding: EdgeInsetsDirectional.only(
                                                start: width! / 20.0,
                                                end: width! / 20.0),
                                            margin: EdgeInsetsDirectional.only(
                                                top: height! / 80.0),
                                            decoration: DesignConfig
                                                .boxDecorationContainer(
                                                    Theme.of(context)
                                                        .colorScheme
                                                        .onSurface,
                                                    0.0),
                                            child: context
                                                            .read<
                                                                SystemConfigCubit>()
                                                            .getWallet() !=
                                                        "0" &&
                                                    context
                                                        .read<
                                                            SystemConfigCubit>()
                                                        .getWallet()
                                                        .isNotEmpty &&
                                                    context
                                                            .read<
                                                                SystemConfigCubit>()
                                                            .getWallet() !=
                                                        ""
                                                ? Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            EdgeInsetsDirectional
                                                                .only(
                                                          top: height! / 60.0,
                                                        ),
                                                        child: Text(
                                                          UiUtils
                                                              .getTranslatedLabel(
                                                                  context,
                                                                  walletLabel),
                                                          style: TextStyle(
                                                              color: Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .onPrimary,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                              fontStyle:
                                                                  FontStyle
                                                                      .normal,
                                                              fontSize: 16.0),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            EdgeInsetsDirectional
                                                                .only(
                                                                    top: height! /
                                                                        80.0),
                                                        child: DesignConfig
                                                            .divider(),
                                                      ),
                                                      CheckboxListTile(
                                                        checkboxShape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                            side: BorderSide(
                                                                color: Theme.of(
                                                                        context)
                                                                    .colorScheme
                                                                    .secondary)),
                                                        dense: true,
                                                        checkColor:
                                                            Theme.of(context)
                                                                .colorScheme
                                                                .onPrimary,
                                                        side:
                                                            WidgetStateBorderSide
                                                                .resolveWith(
                                                          (states) => BorderSide(
                                                              width: 1.0,
                                                              color: Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .secondary,
                                                              strokeAlign: 5),
                                                        ),
                                                        activeColor:
                                                            Theme.of(context)
                                                                .colorScheme
                                                                .primary,
                                                        contentPadding:
                                                            const EdgeInsets
                                                                .all(0),
                                                        value: isUseWallet,
                                                        onChanged:
                                                            (bool? value) {
                                                          if (mounted) {
                                                            setState(() {
                                                              isUseWallet =
                                                                  value;
                                                              if (value!) {
                                                                if (total() <=
                                                                    double.parse(context
                                                                        .read<
                                                                            SystemConfigCubit>()
                                                                        .getWallet())) {
                                                                  remWalBal = (double.parse(context
                                                                          .read<
                                                                              SystemConfigCubit>()
                                                                          .getWallet()) -
                                                                      total());
                                                                  walletBalanceUsed =
                                                                      total();
                                                                  paymentMethod =
                                                                      "Wallet";
                                                                  isPayLayShow =
                                                                      false;
                                                                } else {
                                                                  remWalBal = 0;
                                                                  walletBalanceUsed =
                                                                      double.parse(context
                                                                          .read<
                                                                              SystemConfigCubit>()
                                                                          .getWallet());
                                                                  isPayLayShow =
                                                                      true;
                                                                }
                                                              } else {
                                                                remWalBal = double
                                                                    .parse(context
                                                                        .read<
                                                                            SystemConfigCubit>()
                                                                        .getWallet());

                                                                walletBalanceUsed =
                                                                    0;
                                                                isPayLayShow =
                                                                    true;
                                                              }
                                                            });
                                                          }
                                                        },
                                                        title: Text(
                                                          isUseWallet!
                                                              ? UiUtils
                                                                  .getTranslatedLabel(
                                                                      context,
                                                                      remainingBalanceLabel)
                                                              : UiUtils
                                                                  .getTranslatedLabel(
                                                                      context,
                                                                      balanceLabel),
                                                          style: TextStyle(
                                                              color: Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .onPrimary,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              fontStyle:
                                                                  FontStyle
                                                                      .normal,
                                                              fontSize: 14.0),
                                                        ),
                                                        subtitle: Text(
                                                          isUseWallet!
                                                              ? "${context.read<SystemConfigCubit>().getCurrency()}${remWalBal.toStringAsFixed(2)}"
                                                              : "${context.read<SystemConfigCubit>().getCurrency()}${double.parse(context.read<SystemConfigCubit>().getWallet()).toStringAsFixed(2)}",
                                                          style: TextStyle(
                                                              color: Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .secondary,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                              fontStyle:
                                                                  FontStyle
                                                                      .normal,
                                                              fontSize: 16.0),
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                : Container(),
                                          );
                                        },
                                      ),
                                      isPayLayShow!
                                          ? Container(
                                              padding:
                                                  EdgeInsetsDirectional.only(
                                                      start: width! / 20.0,
                                                      end: width! / 20.0),
                                              decoration: DesignConfig
                                                  .boxDecorationContainer(
                                                      Theme.of(context)
                                                          .colorScheme
                                                          .onSurface,
                                                      0.0),
                                              margin:
                                                  EdgeInsetsDirectional.only(
                                                      top: height! / 80.0),
                                              child: Column(
                                                children: [
                                                  Row(children: [
                                                    Padding(
                                                      padding:
                                                          EdgeInsetsDirectional
                                                              .only(
                                                                  top: height! /
                                                                      60.0),
                                                      child: Text(
                                                        UiUtils.getTranslatedLabel(
                                                            context,
                                                            paymentMethodLabel),
                                                        style: TextStyle(
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .onPrimary,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            fontStyle: FontStyle
                                                                .normal,
                                                            fontSize: 16.0),
                                                        textAlign:
                                                            TextAlign.start,
                                                      ),
                                                    ),
                                                    const Spacer(),
                                                  ]),
                                                  Padding(
                                                    padding:
                                                        EdgeInsetsDirectional
                                                            .only(
                                                                top: height! /
                                                                    80.0,
                                                                bottom:
                                                                    height! /
                                                                        60.0),
                                                    child:
                                                        DesignConfig.divider(),
                                                  ),
                                                  ListView.builder(
                                                      shrinkWrap: true,
                                                      physics:
                                                          const NeverScrollableScrollPhysics(),
                                                      itemCount:
                                                          paymentMethodList
                                                              .length,
                                                      itemBuilder:
                                                          (context, index) {
                                                        if (index == 0 && cod) {
                                                          return paymentItem(
                                                              index);
                                                        } else if (index == 1 &&
                                                            paypal) {
                                                          return paymentItem(
                                                              index);
                                                        } else if (index == 2 &&
                                                            razorpay) {
                                                          return paymentItem(
                                                              index);
                                                        } else if (index == 3 &&
                                                            paystack) {
                                                          return paymentItem(
                                                              index);
                                                        } else if (index == 4 &&
                                                            flutterwave) {
                                                          return paymentItem(
                                                              index);
                                                        } else if (index == 5 &&
                                                            stripe) {
                                                          return paymentItem(
                                                              index);
                                                        } else if (index == 6 &&
                                                            paytm) {
                                                          return paymentItem(
                                                              index);
                                                        } else if (index == 7 &&
                                                            midtrans) {
                                                          return paymentItem(
                                                              index);
                                                        } else if (index == 8 &&
                                                            phonepe) {
                                                          return paymentItem(
                                                              index);
                                                        } else {
                                                          return Container();
                                                        }
                                                      }),
                                                ],
                                              ),
                                            )
                                          : Container(),
                                    ]),
                              ),
                            );
                          });
                })));
  }

  Widget paymentItem(int index) {
    return InkWell(
      onTap: () {
        if (mounted) {
          setState(() {
            selectedMethod = index;
            paymentMethod = paymentMethodList[selectedMethod!]!;
            print("${paymentMethod}Payment");

            for (var element in paymentModel) {
              element.isSelected = false;
            }
            paymentModel[index].isSelected = true;
            setState(() {
              _placeOrder = false;
            });
          });
        }
      },
      child: paymentModel.isNotEmpty
          ? RadioItem(paymentModel[index], height: height, width: width)
          : Container(),
    );
  }
}
