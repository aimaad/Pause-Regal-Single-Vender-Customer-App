import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:erestroSingleVender/cubit/address/addressCubit.dart';
import 'package:erestroSingleVender/cubit/auth/authCubit.dart';
import 'package:erestroSingleVender/cubit/cart/getCartCubit.dart';
import 'package:erestroSingleVender/cubit/settings/settingsCubit.dart';
import 'package:erestroSingleVender/cubit/transaction/transactionCubit.dart';
import 'package:erestroSingleVender/data/model/transactionModel.dart';
import 'package:erestroSingleVender/ui/styles/color.dart';
import 'package:erestroSingleVender/utils/api.dart';
import 'package:erestroSingleVender/utils/string.dart';
import 'package:erestroSingleVender/ui/screen/cart/cart_screen.dart';
import 'package:erestroSingleVender/ui/screen/order/thank_you_for_order.dart';
import 'package:erestroSingleVender/utils/apiBodyParameterLabels.dart';
import 'package:erestroSingleVender/utils/uiUtils.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

class PaypalWebView extends StatefulWidget {
  final String? url, from, msg, amt, orderId, addNote;
  final TransactionCubit? transactionCubit;

  const PaypalWebView(
      {Key? key,
      this.url,
      this.from,
      this.msg,
      this.amt,
      this.orderId,
      this.addNote,
      this.transactionCubit})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return StatePayPalWebView();
  }
}

class StatePayPalWebView extends State<PaypalWebView> {
  String message = "";
  bool isloading = true;
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  late final WebViewController _controller;
  DateTime? currentBackPressTime;
  double? width, height;

  @override
  void initState() {
    super.initState();
    webViewInitiliased();
  }

  webViewInitiliased() {
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final WebViewController controller =
        WebViewController.fromPlatformCreationParams(params);
    // #enddocregion platform_features

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            debugPrint('WebView is loading (progress : $progress%)');
          },
          onPageStarted: (String url) {
            debugPrint('Page started loading: $url');
          },
          onPageFinished: (String url) {
            setState(
              () {
                isloading = false;
              },
            );
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('''
              Page resource error:
                code: ${error.errorCode}
                description: ${error.description}
                errorType: ${error.errorType}
                isForMainFrame: ${error.isForMainFrame}
            ''');
          },
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith(Api.appPaymentStatusUrl) ||
                request.url.startsWith(Api.flutterwavePaymentResponseUrl)) {
              if (mounted) {
                setState(() {
                  isloading = true;
                });
              }

              String responseurl = request.url;

              if (responseurl.contains("Failed") ||
                  responseurl.contains("failed")) {
                if (mounted) {
                  setState(() {
                    isloading = false;
                    message = "Transaction Failed";
                  });
                }
                Timer(const Duration(seconds: 1), () {
                  Navigator.pop(context);
                });
              } else if (responseurl.contains("Completed") ||
                  responseurl.contains("completed") ||
                  responseurl.toLowerCase().contains("success") ||
                  responseurl.toLowerCase().contains("successful")) {
                if (mounted) {
                  setState(() {
                    if (mounted) {
                      setState(() {
                        message = "Transaction Successfull";
                      });
                    }
                  });
                }
                List<String> testdata = responseurl.split("&");
                for (String data in testdata) {
                  if (data.split("=")[0].toLowerCase() == "tx" ||
                      data.split("=")[0].toLowerCase() == "transaction_id") {
                    if (widget.from == "order") {
                      if (request.url.startsWith(Api.appPaymentStatusUrl) ||
                          request.url
                              .startsWith(Api.flutterwavePaymentResponseUrl)) {
                        print("flutterwave--webview--${widget.orderId}");
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ThankYouForOrderScreen(
                                    orderId: widget.orderId.toString())));
                        // context.read<GetCartCubit>().clearCartModel();
                      } else {
                        // String txid = data.split("=")[1];

                        // placeOrder(txid);
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ThankYouForOrderScreen(
                                    orderId: widget.orderId.toString()))).then(
                            (onValue) {
                          context.read<GetCartCubit>().clearCartModel();
                        });
                      }
                    } else if (widget.from == "wallet") {
                      if (request.url
                          .startsWith(Api.flutterwavePaymentResponseUrl)) {
                        // String txid = data.split("=")[1];
                        Navigator.of(context).pop({
                          "walletBalance": null
                        }); //sendRequest(txid, "flutterwave");
                      } else {
                        String txid = data.split("=")[1];
                        sendRequest(txid, "paypal");
                      }
                    }

                    break;
                  }
                }
              }

              if (request.url.startsWith(Api.appPaymentStatusUrl) &&
                  widget.orderId != null &&
                  (responseurl.contains('Canceled-Reversal') ||
                      responseurl.contains('Denied') ||
                      responseurl.contains('Failed'))) {
                deleteOrder();
              }
              return NavigationDecision.prevent;
            } else {}

            return NavigationDecision.navigate;
          },
        ),
      )
      ..addJavaScriptChannel(
        'Toaster',
        onMessageReceived: (JavaScriptMessage message) {
          UiUtils.setSnackBar(message.message, context, false, type: "1");
        },
      )
      ..loadRequest(Uri.parse(widget.url!));

    // #docregion platform_features
    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }
    // #enddocregion platform_features

    _controller = controller;
  }

  @override
  void dispose() {
    super.dispose();
  }

  appBar() {
    return PreferredSize(
      preferredSize: Size.fromHeight(kToolbarHeight),
      child: Container(
        decoration: BoxDecoration(boxShadow: [
          BoxShadow(
            color:
                Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.1),
            offset: Offset(0, 2.0),
            blurRadius: 12.0,
          )
        ]),
        child: AppBar(
          leading: InkWell(
              onTap: () {
                DateTime now = DateTime.now();
                if (currentBackPressTime == null ||
                    now.difference(currentBackPressTime!) >
                        const Duration(seconds: 2)) {
                  currentBackPressTime = now;
                  UiUtils.setSnackBar(
                      "Don't press back while doing payment!\n Double tap back button to exit",
                      context,
                      false,
                      type: "1");
                }
                if (widget.from == "order" && widget.orderId != null)
                  deleteOrder();
                Navigator.pop(context);
              },
              child: Padding(
                  padding: EdgeInsetsDirectional.only(start: width! / 20),
                  child: Icon(
                      Platform.isIOS ? Icons.arrow_back_ios : Icons.arrow_back,
                      color: Theme.of(context).colorScheme.onPrimary))),
          backgroundColor: Theme.of(context).colorScheme.onSurface,
          shadowColor: textFieldBackground,
          elevation: 0,
          centerTitle: false,
          title: Text(StringsRes.appName,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w500)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    DateTime now = DateTime.now();
    return Scaffold(
        key: scaffoldKey,
        backgroundColor: Theme.of(context).colorScheme.onSurface,
        appBar: appBar(),
        body: PopScope(
            canPop: currentBackPressTime == null ||
                    now.difference(currentBackPressTime!) >
                        const Duration(seconds: 2)
                ? false
                : true,
            onPopInvokedWithResult: (value, dynamic) => onWillPop(),
            child: Container(
              margin: EdgeInsetsDirectional.only(
                  start: width! / 20.0,
                  end: width! / 20.0,
                  top: height! / 50.0),
              child: Stack(
                children: <Widget>[
                  WebViewWidget(
                    controller: _controller,
                  ),
                  isloading
                      ? Center(
                          child: CircularProgressIndicator(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        )
                      : const SizedBox(
                          width: 0,
                          height: 0,
                        ),
                  message.trim().isEmpty
                      ? Container()
                      : Center(
                          child: Container(
                              color: Theme.of(context).colorScheme.primary,
                              padding: const EdgeInsets.all(5),
                              margin: const EdgeInsets.all(5),
                              child: Text(
                                message,
                                style: const TextStyle(color: white),
                              )))
                ],
              ),
            )));
  }

  Future<bool> onWillPop() {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime!) > const Duration(seconds: 2)) {
      currentBackPressTime = now;
      // UiUtils.setSnackBar(
      //     "Don't press back while doing payment!\n Double tap back button to exit",
      //     context,
      //     false,
      //     type: "1");

      return Future.value(false);
    }
    if (widget.from == "order" && widget.orderId != null) deleteOrder();
    return Future.value(true);
  }

  Future<void> sendRequest(String txnId, String payMethod) async {
    String orderId =
        "wallet-refill-user-${context.read<AuthCubit>().getId()}-${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(900) + 100}";
    try {
      var parameter = {
        amountKey: widget.amt,
        transactionTypeKey: 'wallet',
        typeKey: 'credit',
        messageKey: (widget.msg == '' ||
                widget.msg.toString().isEmpty ||
                widget.msg == null)
            ? "Added through wallet"
            : widget.msg,
        txnIdKey: txnId,
        orderIdKey: orderId,
        statusKey: "success",
        paymentMethodKey: payMethod.toLowerCase()
      };

      if (payMethod.toLowerCase() == "stripe" ||
          payMethod.toLowerCase() == "paypal") {
        parameter[skipVerifyTransactionKey] =
            (payMethod.toLowerCase() == "stripe" ||
                    payMethod.toLowerCase() == "paypal")
                ? "true"
                : "false";
      }

      Response response = await post(Uri.parse(Api.addTransactionUrl),
              body: parameter, headers: Api.getHeaders())
          .timeout(const Duration(seconds: 50));

      var getdata = json.decode(response.body);

      bool error = getdata[errorKey];

      if (!error) {}
      if (mounted) {
        setState(() {
          isloading = false;
          context
              .read<TransactionCubit>()
              .addTransaction(TransactionModel.fromJson(getdata[dataKey][0]));
        });
      }
      Navigator.of(context).pop({"walletBalance": getdata['new_balance']});
    } on TimeoutException catch (_) {
      UiUtils.setSnackBar(StringsRes.somethingMsg, context, false, type: "2");

      setState(() {
        isloading = false;
      });
    }
  }

  Future<void> deleteOrder() async {
    try {
      var parameter = {
        orderIdKey: widget.orderId,
      };

      Response response = await post(Uri.parse(Api.deleteOrderUrl),
              body: parameter, headers: Api.getHeaders())
          .timeout(const Duration(seconds: 50));

      var getdata = json.decode(response.body);
      print('getdata*****delete order****$getdata');
      bool error = getdata[errorKey];
      if (!error) {}

      if (mounted) {
        setState(() {
          isloading = false;
        });
      }

      Navigator.of(context).pop();
    } on TimeoutException catch (_) {
      UiUtils.setSnackBar(StringsRes.somethingMsg, context, false, type: "2");

      setState(() {
        isloading = false;
      });
    }
  }

  setSnackbar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        msg,
        textAlign: TextAlign.center,
        style: const TextStyle(color: black),
      ),
      backgroundColor: Theme.of(context).colorScheme.onSurface,
      elevation: 1.0,
    ));
  }

  double total() {
    if (isUseWallet == true) {
      return (context.read<GetCartCubit>().getCartModel().overallAmount! +
          deliveryCharge +
          deliveryTip -
          promoAmt -
          walletBalanceUsed);
    } else {
      return (context.read<GetCartCubit>().getCartModel().overallAmount! +
          deliveryCharge +
          deliveryTip -
          promoAmt +
          walletBalanceUsed);
    }
  }

  Future<void> placeOrder(String tranId) async {
    setState(() {
      isloading = true;
    });

    String? varientId, quantity, cartIds;
    final cartModel = context.read<GetCartCubit>().getCartModel();
    varientId = cartModel.variantId!.join(",");
    for (int i = 0; i < cartModel.data!.length; i++) {
      quantity = quantity != null
          ? "$quantity,${cartModel.data![i].qty!}"
          : cartModel.data![i].qty!;
      cartIds = cartIds != null
          ? "$cartIds,${cartModel.data![i].cartId}"
          : cartModel.data![i].cartId;
    }
    String payVia;

    payVia = "flutterwave";

    try {
      var parameter = {
        mobileKey:
            context.read<AddressCubit>().gerCurrentAddress().mobile.toString(),
        productVariantIdKey: varientId,
        quantityKey: quantity,
        totalKey: overAllAmount.toStringAsFixed(2),
        finalTotalKey: total().toStringAsFixed(2),
        deliveryChargeKey: deliveryCharge.toString(),
        taxAmountKey: taxAmount.toString(),
        taxPercentageKey: taxPercentage.toString(),
        latitudeKey: latitude.toString(),
        longitudeKey: longitude.toString(),
        paymentMethodKey: payVia,
        addressIdKey: orderTypeIndex.toString() == "0" ? selAddress : "",
        isWalletUsedKey: isUseWallet! ? "1" : "0",
        walletBalanceUsedKey: walletBalanceUsed.toString(),
        orderNoteKey: widget.addNote ?? "",
        deliveryTipKey: deliveryTip.toString(),
        isSelfPickUpKey: orderTypeIndex.toString(),
        branchIdKey: context.read<SettingsCubit>().getSettings().branchId,
        cartIdsKey: cartIds,
        activeStatusKey: waitingKey,
      };
      print("Hello----$parameter");

      if (isPromoValid!) {
        parameter[promoCodeKey] = promoCode;
      }

      Response response = await post(Uri.parse(Api.placeOrderUrl),
              body: parameter, headers: Api.getHeaders())
          .timeout(const Duration(seconds: 50));

      if (response.statusCode == 200) {
        var getdata = json.decode(response.body);
        bool error = getdata[errorKey];
        String? msg = getdata[messageKey];
        if (!error) {
          String orderId = getdata[orderIdKey].toString();
          addTransaction(tranId, orderId, "Success", msg, true);
        } else {
          UiUtils.setSnackBar(msg!, context, false, type: "2");
        }
        if (mounted) {
          setState(() {
            isloading = false;
          });
        }
      }
    } on TimeoutException catch (_) {
      if (mounted) {
        setState(() {
          isloading = false;
        });
      }
    }
  }

  Future<void> addTransaction(String tranId, String orderID, String status,
      String? msg, bool redirect) async {
    try {
      var parameter = {
        orderIdKey: orderID,
        typeKey: paymentMethod,
        txnIdKey: tranId,
        amountKey: total().toStringAsFixed(2),
        statusKey: status,
        messageKey: msg
      };

      Response response = await post(Uri.parse(Api.addTransactionUrl),
              body: parameter, headers: Api.getHeaders())
          .timeout(const Duration(seconds: 50));

      DateTime now = DateTime.now();
      currentBackPressTime = now;
      var getdata = json.decode(response.body);

      bool error = getdata[errorKey];
      String? msg1 = getdata[messageKey];
      if (!error) {
        if (redirect) {
          promoAmt = 0;
          remWalBal = 0;
          walletBalanceUsed = 0;
          paymentMethod = '';
          isPromoValid = false;
          isUseWallet = false;
          isPayLayShow = true;
          selectedMethod = null;
          finalTotal = 0;
          subTotal = 0;

          taxPercentage = 0;
          deliveryCharge = 0;
          orderTypeIndex = 0;

          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      ThankYouForOrderScreen(orderId: orderID.toString())));
          context.read<GetCartCubit>().clearCartModel();
        }
      } else {
        UiUtils.setSnackBar(msg1!, context, false, type: "2");
      }
    } on TimeoutException catch (_) {
      UiUtils.setSnackBar(StringsRes.somethingMsg, context, false, type: "2");
    }
  }
}
