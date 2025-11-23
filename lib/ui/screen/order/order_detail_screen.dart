import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:erestroSingleVender/app/routes.dart';
import 'package:erestroSingleVender/cubit/order/orderDetailCubit.dart';
import 'package:erestroSingleVender/cubit/rating/setRiderRatingCubit.dart';
import 'package:erestroSingleVender/data/model/addOnsDataModel.dart';
import 'package:erestroSingleVender/data/model/orderModel.dart';
import 'package:erestroSingleVender/cubit/systemConfig/systemConfigCubit.dart';
import 'package:erestroSingleVender/ui/screen/settings/no_internet_screen.dart';
import 'package:erestroSingleVender/ui/widgets/buttomContainer.dart';
import 'package:erestroSingleVender/ui/widgets/simmer/orderDetailSimmer.dart';
import 'package:erestroSingleVender/ui/widgets/smallButtomContainer.dart';
import 'package:erestroSingleVender/utils/apiBodyParameterLabels.dart';
import 'package:erestroSingleVender/utils/constants.dart';
import 'package:erestroSingleVender/utils/labelKeys.dart';
import 'package:erestroSingleVender/utils/uiUtils.dart';
import 'package:external_path/external_path.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:erestroSingleVender/ui/styles/color.dart';
import 'package:erestroSingleVender/ui/styles/design.dart';
import 'package:erestroSingleVender/utils/string.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html_to_pdf/flutter_html_to_pdf.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:intl/intl.dart';
import 'package:erestroSingleVender/utils/internetConnectivity.dart';

class OrderDetailScreen extends StatefulWidget {
  final String? id,
      riderId,
      riderName,
      riderRating,
      riderImage,
      riderMobile,
      riderNoOfRating,
      isSelfPickup,
      from;
  const OrderDetailScreen(
      {Key? key,
      this.id,
      this.riderId,
      this.riderName,
      this.riderRating,
      this.riderImage,
      this.riderMobile,
      this.riderNoOfRating,
      this.isSelfPickup,
      this.from})
      : super(key: key);

  @override
  OrderDetailScreenState createState() => OrderDetailScreenState();
  static Route<dynamic> route(RouteSettings routeSettings) {
    Map arguments = routeSettings.arguments as Map;
    return CupertinoPageRoute(
        builder: (_) => OrderDetailScreen(
            id: arguments['id'] as String,
            riderId: arguments['riderId'] as String,
            riderName: arguments['riderName'] as String,
            riderRating: arguments['riderRating'] as String,
            riderImage: arguments['riderImage'] as String,
            riderMobile: arguments['riderMobile'] as String,
            riderNoOfRating: arguments['riderNoOfRating'] as String,
            isSelfPickup: arguments['isSelfPickup'] as String,
            from: arguments['from'] as String));
  }
}

class OrderDetailScreenState extends State<OrderDetailScreen> {
  double? width, height, latitude = 0.0, longitude = 0.0;
  int selectedIndex = 0;
  Future<List<Directory>?>? _externalStorageDirectories;
  ScrollController orderController = ScrollController();
  String? invoice = "",
      mobileNumber = "",
      activeStatusOrder = "",
      orderRiderRating;
  var inputFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
  var outputFormat = DateFormat('dd,MMMM yyyy hh:mm a');
  double? rating = 5.0;
  TextEditingController commentController = TextEditingController(text: "");
  StateSetter? dialogState;
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  bool _isProgress = false;
  RegExp regex = RegExp(r'([^\d]00)(?=[^\d]|$)');
  @override
  void initState() {
    super.initState();
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
    print(widget.from);
    _externalStorageDirectories =
        getExternalStorageDirectories(type: StorageDirectory.downloads);
    Future.delayed(Duration.zero, () {
      print("flutterwave--order detail page--${widget.id}");
      context.read<OrderDetailCubit>().fetchOrder(perPage, widget.id!, "");
    });
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
  }

  Future<bool> checkPermission() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      var result = await Permission.storage.request();
      if (result.isGranted) {
        return true;
      } else {
        return false;
      }
    } else {
      return true;
    }
  }

  downloadInvoice() {
    return FutureBuilder<List<Directory>?>(
        future: _externalStorageDirectories,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          return GestureDetector(
            onTap: () async {
              bool hasPermission = await checkPermission();
              setState(
                () {
                  _isProgress = true;
                },
              );

              String target = Platform.isAndroid && hasPermission
                  ? (await ExternalPath.getExternalStoragePublicDirectory(
                      ExternalPath.DIRECTORY_DOWNLOAD,
                    ))
                  : (await getApplicationDocumentsDirectory()).path;

              var targetFileName = 'Invoice_${widget.id}';
              var generatedPdfFile, filePath;
              try {
                generatedPdfFile =
                    await FlutterHtmlToPdf.convertFromHtmlContent(
                        invoice!, target, targetFileName);
                filePath = generatedPdfFile.path;

                File fileDef = File(filePath);
                await fileDef.create(recursive: true);
                Uint8List bytes = await generatedPdfFile.readAsBytes();
                await fileDef.writeAsBytes(bytes);
              } catch (e) {
                if (mounted) {
                  setState(() {
                    _isProgress = false;
                  });
                  UiUtils.setSnackBar(
                      StringsRes.somethingWentWrong, context, false,
                      type: "2");
                }
                return;
              }

              if (mounted) {
                setState(() {
                  _isProgress = false;
                });
              }
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(
                  "${UiUtils.getTranslatedLabel(context, invoicePathLabel)} $targetFileName",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: white),
                ),
                action: SnackBarAction(
                    label: UiUtils.getTranslatedLabel(context, viewLabel),
                    textColor: white,
                    onPressed: () async {
                      await OpenFile.open(filePath);
                    }),
                backgroundColor: Theme.of(context).colorScheme.onPrimary,
                elevation: 1.0,
              ));
            },
            child: Container(
              padding: EdgeInsetsDirectional.all(8.0),
              decoration: DesignConfig.boxDecorationContainer(
                  Theme.of(context).colorScheme.onPrimary, 100),
              child: _isProgress
                  ? const Center(
                      child: SizedBox(
                          width: 15.0,
                          height: 15.0,
                          child: CircularProgressIndicator(color: white)))
                  : SvgPicture.asset(DesignConfig.setSvgPath("download_fill"),
                      fit: BoxFit.scaleDown,
                      colorFilter: ColorFilter.mode(
                          Theme.of(context).colorScheme.onSurface,
                          BlendMode.srcIn),
                      width: 15.0,
                      height: 15.0),
            ),
          );
        });
  }

  Widget orderData() {
    return BlocConsumer<OrderDetailCubit, OrderDetailState>(
        bloc: context.read<OrderDetailCubit>(),
        listener: (context, state) {
          if (state is OrderDetailSuccess) {
            orderRiderRating = (state).orderList[0].orderRiderRating!;
          }
        },
        builder: (context, state) {
          if (state is OrderDetailProgress || state is OrderDetailInitial) {
            return OrderSimmer(width: width!, height: height!);
          }
          if (state is OrderDetailFailure) {
            return Center(
                child: Text(
              state.errorMessage.toString(),
              textAlign: TextAlign.center,
            ));
          }
          final orderList = (state as OrderDetailSuccess).orderList;
          invoice = orderList[0].invoiceHtml!;
          latitude = double.parse(orderList[0].branchModel!.latitude!);
          longitude = double.parse(orderList[0].branchModel!.longitude!);
          mobileNumber = orderList[0].branchModel!.contact!;
          activeStatusOrder = orderList[0].activeStatus!;
          return SizedBox(
              height: height! / 0.9,
              child: ListView.builder(
                  shrinkWrap: true,
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: orderList.length,
                  itemBuilder: (BuildContext context, index) {
                    var status = "";
                    if (orderList[index].activeStatus! == deliveredKey) {
                      status =
                          UiUtils.getTranslatedLabel(context, deliveredLabel);
                    } else if (orderList[index].activeStatus! == pendingKey) {
                      status =
                          UiUtils.getTranslatedLabel(context, pendingLbLabel);
                    } else if (orderList[index].activeStatus! == waitingKey) {
                      status =
                          UiUtils.getTranslatedLabel(context, awaitingLbLabel);
                    } else if (orderList[index].activeStatus! ==
                        readyForPickupKey) {
                      status = UiUtils.getTranslatedLabel(
                          context, readyForPickupLbLabel);
                    } else if (orderList[index].activeStatus! ==
                        outForDeliveryKey) {
                      status = UiUtils.getTranslatedLabel(
                          context, outForDeliveryLbLabel);
                    } else if (orderList[index].activeStatus! == confirmedKey) {
                      status =
                          UiUtils.getTranslatedLabel(context, confirmedLbLabel);
                    } else if (orderList[index].activeStatus! == cancelledKey) {
                      status = UiUtils.getTranslatedLabel(context, cancelLabel);
                    } else if (orderList[index].activeStatus! == preparingKey) {
                      status =
                          UiUtils.getTranslatedLabel(context, preparingLbLabel);
                    } else {
                      status = "";
                    }
                    var inputDate = inputFormat.parse(
                        orderList[index].dateAdded!); // <-- dd/MM 24H format
                    var outputDate = outputFormat.format(inputDate);
                    return Container(
                        width: width!,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            orderList[index].activeStatus == cancelledKey
                                ? const SizedBox()
                                : orderList[index].isSelfPickUp == "1"
                                    ? const SizedBox()
                                    : Container(
                                        decoration:
                                            DesignConfig.boxDecorationContainer(
                                                Theme.of(context)
                                                    .colorScheme
                                                    .onSurface,
                                                0.0),
                                        padding: EdgeInsetsDirectional.only(
                                          top: height! / 80.0,
                                          bottom: height! / 80.0,
                                          start: width! / 40.0,
                                          end: width! / 40.0,
                                        ),
                                        margin: EdgeInsetsDirectional.only(
                                            bottom: height! / 80.0),
                                        child: Container(
                                          margin: EdgeInsetsDirectional.only(
                                              start: width! / 40.0,
                                              end: width! / 40.0,
                                              top: height! / 80.0,
                                              bottom: height! / 80.0),
                                          padding: EdgeInsetsDirectional.only(
                                            top: height! / 80.0,
                                            bottom: height! / 80.0,
                                            start: width! / 40.0,
                                            end: width! / 40.0,
                                          ),
                                          decoration: DesignConfig
                                              .boxDecorationContainerBorder(
                                                  Theme.of(context)
                                                      .colorScheme
                                                      .primary,
                                                  Theme.of(context)
                                                      .colorScheme
                                                      .primary
                                                      .withValues(alpha: 0.10),
                                                  8.0),
                                          child: Row(children: [
                                            Text(
                                                UiUtils.getTranslatedLabel(
                                                    context, otpLabel),
                                                textAlign: TextAlign.left,
                                                style: TextStyle(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onPrimary,
                                                  fontStyle: FontStyle.normal,
                                                  fontSize: 14.0,
                                                  fontWeight: FontWeight.w600,
                                                )),
                                            const Spacer(),
                                            Text(orderList[index].otp!,
                                                textAlign: TextAlign.right,
                                                style: TextStyle(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .secondary,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w700,
                                                    letterSpacing: 0.8,
                                                    fontStyle:
                                                        FontStyle.normal)),
                                          ]),
                                        ),
                                      ),
                            Container(
                                decoration: DesignConfig.boxDecorationContainer(
                                    Theme.of(context).colorScheme.onSurface,
                                    0.0),
                                margin: EdgeInsetsDirectional.only(
                                    top: height! / 80.0),
                                padding: EdgeInsetsDirectional.only(
                                    top: height! / 40,
                                    start: width! / 20.0,
                                    end: width! / 20.0,
                                    bottom: height! / 40.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SvgPicture.asset(
                                        DesignConfig.setSvgPath("ic_invoice"),
                                        fit: BoxFit.scaleDown,
                                        colorFilter: ColorFilter.mode(
                                            Theme.of(context)
                                                .colorScheme
                                                .onPrimary,
                                            BlendMode.srcIn),
                                        width: 18.0,
                                        height: 18.0),
                                    SizedBox(width: width! / 40.0),
                                    Text(
                                        UiUtils.getTranslatedLabel(
                                            context, downloadBillLabel),
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onPrimary,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            fontStyle: FontStyle.normal)),
                                    const Spacer(),
                                    downloadInvoice(),
                                  ],
                                )),
                            (orderList[index].reason!.isEmpty ||
                                    orderList[index].reason == "")
                                ? const SizedBox()
                                : Container(
                                    decoration:
                                        DesignConfig.boxDecorationContainer(
                                            Theme.of(context)
                                                .colorScheme
                                                .onSurface,
                                            0.0),
                                    margin: EdgeInsetsDirectional.only(
                                        top: height! / 80.0),
                                    padding: EdgeInsetsDirectional.only(
                                        top: height! / 40,
                                        start: width! / 20.0,
                                        end: width! / 20.0,
                                        bottom: height! / 40.0),
                                    child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            UiUtils.getTranslatedLabel(
                                                context, orderCancelDueToLabel),
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onPrimary,
                                                fontWeight: FontWeight.w600),
                                          ),
                                          (orderList[index].reason!.isEmpty ||
                                                  orderList[index].reason == "")
                                              ? const SizedBox()
                                              : Padding(
                                                  padding: EdgeInsetsDirectional
                                                      .only(
                                                    top: height! / 99.0,
                                                    bottom: height! / 80.0,
                                                  ),
                                                  child: DesignConfig.divider(),
                                                ),
                                          (orderList[index].reason!.isEmpty ||
                                                  orderList[index].reason == "")
                                              ? const SizedBox()
                                              : Text(
                                                  "${orderList[index].reason}",
                                                  textAlign: TextAlign.start,
                                                  maxLines: 2,
                                                  style: TextStyle(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .onPrimary
                                                          .withValues(
                                                              alpha: 0.76),
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w500)),
                                        ])),
                            orderList[index].isSelfPickUp == "0"
                                ? const SizedBox()
                                : orderList[index].ownerNote!.isEmpty
                                    ? const SizedBox()
                                    : Container(
                                        decoration:
                                            DesignConfig.boxDecorationContainer(
                                                Theme.of(context)
                                                    .colorScheme
                                                    .onSurface,
                                                0.0),
                                        margin: EdgeInsetsDirectional.only(
                                            top: height! / 60.0),
                                        padding: EdgeInsetsDirectional.only(
                                            top: height! / 80,
                                            start: width! / 20.0,
                                            end: width! / 20.0,
                                            bottom: height! / 80.0),
                                        child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                UiUtils.getTranslatedLabel(
                                                    context,
                                                    additionalInstructionsLabel),
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onPrimary,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                              Padding(
                                                padding:
                                                    EdgeInsetsDirectional.only(
                                                  top: height! / 99.0,
                                                  bottom: height! / 80.0,
                                                ),
                                                child: DesignConfig.divider(),
                                              ),
                                              Text(orderList[index].ownerNote!,
                                                  textAlign: TextAlign.start,
                                                  style: TextStyle(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onPrimary
                                                        .withValues(
                                                            alpha: 0.76),
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                    fontStyle: FontStyle.normal,
                                                  )),
                                            ])),
                            orderList[index].isSelfPickUp == "0"
                                ? const SizedBox()
                                : orderList[index].selfPickupTime!.isEmpty
                                    ? const SizedBox()
                                    : Container(
                                        decoration:
                                            DesignConfig.boxDecorationContainer(
                                                Theme.of(context)
                                                    .colorScheme
                                                    .onSurface,
                                                0.0),
                                        margin: EdgeInsetsDirectional.only(
                                            top: height! / 60.0),
                                        padding: EdgeInsetsDirectional.only(
                                            top: height! / 80,
                                            start: width! / 20.0,
                                            end: width! / 20.0,
                                            bottom: height! / 80.0),
                                        child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                UiUtils.getTranslatedLabel(
                                                    context, pickupTimeLabel),
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onPrimary,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                              Padding(
                                                padding:
                                                    EdgeInsetsDirectional.only(
                                                  top: height! / 99.0,
                                                  bottom: height! / 80.0,
                                                ),
                                                child: DesignConfig.divider(),
                                              ),
                                              Text(
                                                  orderList[index]
                                                      .selfPickupTime!,
                                                  textAlign: TextAlign.start,
                                                  style: TextStyle(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onPrimary
                                                        .withValues(
                                                            alpha: 0.76),
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                    fontStyle: FontStyle.normal,
                                                  )),
                                            ])),
                            Container(
                              decoration: DesignConfig.boxDecorationContainer(
                                  Theme.of(context).colorScheme.onSurface, 0.0),
                              margin: EdgeInsetsDirectional.only(
                                  top: height! / 60.0),
                              padding: EdgeInsetsDirectional.only(
                                  top: height! / 40,
                                  start: width! / 20.0,
                                  end: width! / 20.0,
                                  bottom: height! / 40.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "${UiUtils.getTranslatedLabel(context, orderDetailsLabel)}",
                                            textAlign: TextAlign.start,
                                            maxLines: 1,
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onPrimary,
                                                fontSize: 14,
                                                overflow: TextOverflow.ellipsis,
                                                fontWeight: FontWeight.w700),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(outputDate.toString(),
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onPrimary
                                                    .withValues(alpha: 0.76),
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                              )),
                                        ],
                                      ),
                                      const Spacer(),
                                      FittedBox(
                                        fit: BoxFit.fitWidth,
                                        child: Container(
                                          alignment: Alignment.topLeft,
                                          padding:
                                              const EdgeInsetsDirectional.only(
                                                  top: 4.5,
                                                  bottom: 4.5,
                                                  start: 4.5,
                                                  end: 4.5),
                                          decoration: DesignConfig
                                              .boxDecorationContainerBorder(
                                                  DesignConfig
                                                      .orderStatusCartColor(
                                                          orderList[index]
                                                              .activeStatus!),
                                                  DesignConfig
                                                          .orderStatusCartColor(
                                                              orderList[index]
                                                                  .activeStatus!)
                                                      .withValues(alpha: 0.10),
                                                  4.0),
                                          child: Text(
                                            status,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: DesignConfig
                                                  .orderStatusCartColor(
                                                      orderList[index]
                                                          .activeStatus!),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: EdgeInsetsDirectional.only(
                                      top: height! / 80.0,
                                      bottom: height! / 80.0,
                                    ),
                                    child: DesignConfig.divider(),
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: List.generate(
                                        orderList[index].orderItems!.length,
                                        (i) {
                                      OrderItems data =
                                          orderList[index].orderItems![i];
                                      return InkWell(
                                          onTap: () {},
                                          child: Container(
                                              width: width!,
                                              margin:
                                                  EdgeInsetsDirectional.only(
                                                      top: height! / 99.0),
                                              child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(children: [
                                                      data.indicator == "1"
                                                          ? SvgPicture.asset(
                                                              DesignConfig
                                                                  .setSvgPath(
                                                                      "veg_icon"),
                                                              width: 15,
                                                              height: 15)
                                                          : data.indicator ==
                                                                  "2"
                                                              ? SvgPicture.asset(
                                                                  DesignConfig
                                                                      .setSvgPath(
                                                                          "non_veg_icon"),
                                                                  width: 15,
                                                                  height: 15)
                                                              : const SizedBox(
                                                                  height: 15,
                                                                  width: 15.0),
                                                      const SizedBox(
                                                          width: 5.0),
                                                      Text(
                                                        "${data.quantity!} x ",
                                                        textAlign:
                                                            Directionality.of(
                                                                        context) ==
                                                                    TextDirection
                                                                        .RTL
                                                                ? TextAlign.end
                                                                : TextAlign
                                                                    .start,
                                                        style: TextStyle(
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .onPrimary
                                                                .withValues(
                                                                    alpha:
                                                                        0.76),
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis),
                                                        maxLines: 1,
                                                      ),
                                                      Expanded(
                                                        flex: 5,
                                                        child: Text(
                                                          data.name!,
                                                          textAlign: Directionality.of(
                                                                      context) ==
                                                                  TextDirection
                                                                      .RTL
                                                              ? TextAlign.end
                                                              : TextAlign.start,
                                                          style: TextStyle(
                                                              color: Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .onPrimary
                                                                  .withValues(
                                                                      alpha:
                                                                          0.76),
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis),
                                                          maxLines: 1,
                                                        ),
                                                      ),
                                                      const Spacer(),
                                                      Text(
                                                          "${context.read<SystemConfigCubit>().getCurrency()}${data.price!}",
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                              color: Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .secondary,
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700)),
                                                    ]),
                                                    orderList[index]
                                                                .orderItems![i]
                                                                .attrName !=
                                                            ""
                                                        ? Container(
                                                            margin: EdgeInsetsDirectional
                                                                .only(
                                                                    start:
                                                                        width! /
                                                                            16.0),
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text(
                                                                    "${orderList[index].orderItems![i].attrName!} : ",
                                                                    textAlign:
                                                                        TextAlign
                                                                            .left,
                                                                    style: const TextStyle(
                                                                        color:
                                                                            lightFont,
                                                                        fontSize:
                                                                            12,
                                                                        fontWeight:
                                                                            FontWeight.w500)),
                                                                Text(
                                                                    orderList[
                                                                            index]
                                                                        .orderItems![
                                                                            i]
                                                                        .variantValues!,
                                                                    textAlign:
                                                                        TextAlign
                                                                            .left,
                                                                    style: TextStyle(
                                                                        color: Theme.of(context)
                                                                            .colorScheme
                                                                            .onPrimary
                                                                            .withValues(
                                                                                alpha:
                                                                                    0.76),
                                                                        fontSize:
                                                                            12,
                                                                        overflow:
                                                                            TextOverflow
                                                                                .ellipsis),
                                                                    maxLines:
                                                                        1),
                                                              ],
                                                            ),
                                                          )
                                                        : Container(),
                                                    const SizedBox(height: 5.0),
                                                    Wrap(
                                                        spacing: 5.0,
                                                        runSpacing: 2.0,
                                                        direction:
                                                            Axis.horizontal,
                                                        children: List.generate(
                                                            orderList[index]
                                                                .orderItems![i]
                                                                .addOns!
                                                                .length, (j) {
                                                          AddOnsDataModel
                                                              addOnData =
                                                              orderList[index]
                                                                  .orderItems![
                                                                      i]
                                                                  .addOns![j];
                                                          return Container(
                                                            width: width!,
                                                            margin: EdgeInsetsDirectional
                                                                .only(
                                                                    start:
                                                                        width! /
                                                                            16.0),
                                                            child: Row(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .min,
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Text(
                                                                      "${addOnData.qty!} x ",
                                                                      textAlign:
                                                                          TextAlign
                                                                              .start,
                                                                      style: TextStyle(
                                                                          color: Theme.of(context).colorScheme.onPrimary.withValues(
                                                                              alpha:
                                                                                  0.76),
                                                                          fontSize:
                                                                              10,
                                                                          overflow: TextOverflow
                                                                              .ellipsis),
                                                                      maxLines:
                                                                          2),
                                                                  Text(
                                                                      "${addOnData.title!} ",
                                                                      textAlign:
                                                                          TextAlign
                                                                              .start,
                                                                      style: TextStyle(
                                                                          color: Theme.of(context).colorScheme.onPrimary.withValues(
                                                                              alpha:
                                                                                  0.76),
                                                                          fontSize:
                                                                              10,
                                                                          overflow: TextOverflow
                                                                              .ellipsis),
                                                                      maxLines:
                                                                          2),
                                                                  Text(
                                                                      "${context.read<SystemConfigCubit>().getCurrency()}${addOnData.price!}, ",
                                                                      textAlign:
                                                                          TextAlign
                                                                              .start,
                                                                      style: TextStyle(
                                                                          color: Theme.of(context).colorScheme.onPrimary.withValues(
                                                                              alpha:
                                                                                  0.76),
                                                                          fontSize:
                                                                              10,
                                                                          overflow: TextOverflow
                                                                              .ellipsis,
                                                                          fontWeight:
                                                                              FontWeight.w600)),
                                                                ]),
                                                          );
                                                        }))
                                                  ])));
                                    }),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                                decoration: DesignConfig.boxDecorationContainer(
                                    Theme.of(context).colorScheme.onSurface,
                                    0.0),
                                margin: EdgeInsetsDirectional.only(
                                    top: height! / 60.0),
                                padding: EdgeInsetsDirectional.only(
                                    top: height! / 40,
                                    start: width! / 20.0,
                                    end: width! / 20.0,
                                    bottom: height! / 40.0),
                                child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          SvgPicture.asset(
                                              DesignConfig.setSvgPath(
                                                  "map_pin_line"),
                                              height: 14,
                                              width: 14,
                                              fit: BoxFit.scaleDown,
                                              colorFilter: ColorFilter.mode(
                                                  Theme.of(context)
                                                      .colorScheme
                                                      .onPrimary,
                                                  BlendMode.srcIn)),
                                          SizedBox(width: width! / 80.0),
                                          Text(
                                            (orderList[index].isSelfPickUp ==
                                                    "0")
                                                ? UiUtils.getTranslatedLabel(
                                                    context,
                                                    deliveryLocationLabel)
                                                : UiUtils.getTranslatedLabel(
                                                    context,
                                                    pickupLocationLabel),
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onPrimary,
                                                fontWeight: FontWeight.w600),
                                          ),
                                        ],
                                      ),
                                      Padding(
                                        padding: EdgeInsetsDirectional.only(
                                            top: height! / 99.0,
                                            bottom: height! / 99.0,
                                            start: width! / 20.0),
                                        child: DesignConfig.divider(),
                                      ),
                                      (widget.from == "orderDeliverd" &&
                                              orderList[index].isSelfPickUp ==
                                                  "0" &&
                                              orderList[index].address!.isEmpty)
                                          ? const SizedBox()
                                          : Padding(
                                              padding:
                                                  EdgeInsetsDirectional.only(
                                                      start: width! / 20.0,
                                                      bottom: height! / 80.0),
                                              child: Text(
                                                  (orderList[index]
                                                              .isSelfPickUp ==
                                                          "0")
                                                      ? orderList[index]
                                                          .address!
                                                      : orderList[index]
                                                          .branchModel!
                                                          .address!,
                                                  textAlign: TextAlign.start,
                                                  style: TextStyle(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onPrimary
                                                        .withValues(
                                                            alpha: 0.76),
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                    fontStyle: FontStyle.normal,
                                                  )),
                                            ),
                                      Padding(
                                        padding: EdgeInsetsDirectional.only(
                                            start: width! / 20.0, bottom: 2.0),
                                        child: Row(
                                          children: [
                                            ClipOval(
                                                child: DesignConfig.imageWidgets(
                                                    (orderList[index]
                                                                .isSelfPickUp ==
                                                            "0")
                                                        ? orderList[index]
                                                            .profile
                                                        : orderList[index]
                                                            .branchModel!
                                                            .image,
                                                    20,
                                                    20,
                                                    "1")),
                                            SizedBox(width: width! / 80.0),
                                            Text(
                                                (orderList[index]
                                                            .isSelfPickUp ==
                                                        "0")
                                                    ? orderList[index].username!
                                                    : orderList[index]
                                                        .branchModel!
                                                        .branchName!,
                                                textAlign: TextAlign.start,
                                                style: TextStyle(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onPrimary
                                                        .withValues(
                                                            alpha: 0.76),
                                                    fontSize: 14.0,
                                                    fontWeight: FontWeight.w500,
                                                    fontStyle:
                                                        FontStyle.normal)),
                                            Text(" | ",
                                                textAlign: TextAlign.start,
                                                style: TextStyle(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onPrimary
                                                        .withValues(
                                                            alpha: 0.76),
                                                    fontSize: 14.0,
                                                    fontWeight: FontWeight.w500,
                                                    fontStyle:
                                                        FontStyle.normal)),
                                            Text(
                                                (orderList[index]
                                                            .isSelfPickUp ==
                                                        "0")
                                                    ? orderList[index]
                                                        .usermobile!
                                                    : orderList[index]
                                                        .branchModel!
                                                        .contact!,
                                                textAlign: TextAlign.start,
                                                style: TextStyle(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onPrimary
                                                        .withValues(
                                                            alpha: 0.76),
                                                    fontSize: 14.0,
                                                    fontWeight: FontWeight.w500,
                                                    fontStyle:
                                                        FontStyle.normal)),
                                          ],
                                        ),
                                      ),
                                    ])),
                            (widget.from == "orderDeliverd" &&
                                    orderList[index].isSelfPickUp == "0")
                                ? Container(
                                    decoration:
                                        DesignConfig.boxDecorationContainer(
                                            Theme.of(context)
                                                .colorScheme
                                                .onSurface,
                                            0.0),
                                    margin: EdgeInsetsDirectional.only(
                                        top: height! / 60.0),
                                    padding: EdgeInsetsDirectional.only(
                                        top: height! / 40,
                                        start: width! / 20.0,
                                        end: width! / 20.0,
                                        bottom: height! / 40.0),
                                    child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              SvgPicture.asset(
                                                  DesignConfig.setSvgPath(
                                                      "delivery_bike"),
                                                  height: 14,
                                                  width: 14,
                                                  fit: BoxFit.scaleDown,
                                                  colorFilter: ColorFilter.mode(
                                                      Theme.of(context)
                                                          .colorScheme
                                                          .onPrimary,
                                                      BlendMode.srcIn)),
                                              SizedBox(width: width! / 80.0),
                                              Text(
                                                UiUtils.getTranslatedLabel(
                                                    context,
                                                    rateDeliveryBoyLabel),
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onPrimary,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                              const Spacer(),
                                              GestureDetector(
                                                onTap: () {
                                                  Navigator.of(context)
                                                      .pushNamed(
                                                          Routes
                                                              .riderRatingDetail,
                                                          arguments: {
                                                        'riderId':
                                                            widget.riderId!
                                                      });
                                                },
                                                child: Text(
                                                  UiUtils.getTranslatedLabel(
                                                      context, viewLabel),
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .secondary,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Padding(
                                            padding: EdgeInsetsDirectional.only(
                                                top: height! / 80.0,
                                                bottom: height! / 80.0,
                                                start: width! / 20.0),
                                            child: DesignConfig.divider(),
                                          ),
                                          Padding(
                                            padding: EdgeInsetsDirectional.only(
                                                start: width! / 20.0,
                                                bottom: 2.0),
                                            child: Row(
                                              children: [
                                                ClipOval(
                                                    child: DesignConfig
                                                        .imageWidgets(
                                                            orderList[index]
                                                                .riderImage,
                                                            36,
                                                            36,
                                                            "1")),
                                                SizedBox(width: width! / 40.0),
                                                Expanded(
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                          orderList[index]
                                                              .riderName!,
                                                          textAlign: TextAlign
                                                              .start,
                                                          style: TextStyle(
                                                              color: Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .onPrimary
                                                                  .withValues(
                                                                      alpha:
                                                                          0.76),
                                                              fontSize: 12.0,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontStyle:
                                                                  FontStyle
                                                                      .normal)),
                                                      const SizedBox(
                                                          height: 2.0),
                                                      Text(
                                                          UiUtils.getTranslatedLabel(
                                                              context,
                                                              yourDeliveryPartnerLabel),
                                                          textAlign:
                                                              TextAlign.start,
                                                          style: TextStyle(
                                                              color: Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .onPrimary
                                                                  .withValues(
                                                                      alpha:
                                                                          0.76),
                                                              fontSize: 10.0,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal,
                                                              fontStyle:
                                                                  FontStyle
                                                                      .normal)),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsetsDirectional.only(
                                                top: height! / 90.0,
                                                bottom: height! / 80.0,
                                                start: width! / 20.0),
                                            child: DesignConfig.divider(),
                                          ),
                                          Align(
                                            alignment: Alignment.topRight,
                                            child: (orderRiderRating == "" ||
                                                    orderRiderRating == "0.0" ||
                                                    orderRiderRating == null)
                                                ? SmallButtonContainer(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .primary,
                                                    height: height,
                                                    width: width,
                                                    text: UiUtils
                                                        .getTranslatedLabel(
                                                            context, rateLabel),
                                                    start: 0,
                                                    end: 0,
                                                    bottom: 0,
                                                    top: 0,
                                                    radius: 5.0,
                                                    status: false,
                                                    borderColor:
                                                        Theme.of(context)
                                                            .colorScheme
                                                            .primary,
                                                    textColor: Theme.of(context)
                                                        .colorScheme
                                                        .onPrimary,
                                                    icon: Padding(
                                                      padding:
                                                          EdgeInsetsDirectional
                                                              .only(
                                                                  start:
                                                                      width! /
                                                                          60.0),
                                                      child: Icon(
                                                          Icons.star_outline,
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .onPrimary,
                                                          size: 15.0),
                                                    ),
                                                    onTap: () {
                                                      ratingBottomModelSheet();
                                                    },
                                                  )
                                                : Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                        Text(
                                                            "${UiUtils.getTranslatedLabel(context, youRatedLabel)} :",
                                                            style: TextStyle(
                                                                color: Theme.of(
                                                                        context)
                                                                    .colorScheme
                                                                    .onPrimary,
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700)),
                                                        Container(
                                                            margin: EdgeInsetsDirectional
                                                                .only(
                                                                    start:
                                                                        width! /
                                                                            40.0),
                                                            padding:
                                                                EdgeInsetsDirectional.only(
                                                                    start:
                                                                        width! /
                                                                            60.0,
                                                                    end: width! /
                                                                        60.0,
                                                                    top: 5.0,
                                                                    bottom:
                                                                        5.0),
                                                            decoration: DesignConfig
                                                                .boxDecorationContainer(
                                                                    Theme.of(
                                                                            context)
                                                                        .colorScheme
                                                                        .primary,
                                                                    4.0),
                                                            child:
                                                                Row(children: [
                                                              Text(
                                                                  "${double.parse(orderRiderRating!).toStringAsFixed(2).replaceAll(regex, '')} ",
                                                                  style: TextStyle(
                                                                      color: Theme.of(
                                                                              context)
                                                                          .colorScheme
                                                                          .onPrimary,
                                                                      fontSize:
                                                                          12,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w700)),
                                                              Icon(Icons.star,
                                                                  color: Theme.of(
                                                                          context)
                                                                      .colorScheme
                                                                      .onPrimary,
                                                                  size: 15.0)
                                                            ])),
                                                      ]),
                                          )
                                        ]))
                                : Container(
                                    decoration:
                                        DesignConfig.boxDecorationContainer(
                                            Theme.of(context)
                                                .colorScheme
                                                .onSurface,
                                            0.0),
                                    margin: EdgeInsetsDirectional.only(
                                        top: height! / 60.0),
                                    padding:
                                        orderList[index].isSelfPickUp == "1"
                                            ? EdgeInsetsDirectional.only(
                                                top: height! / 40,
                                                start: width! / 20.0,
                                                end: width! / 20.0,
                                                bottom: height! / 40.0)
                                            : EdgeInsetsDirectional.zero,
                                    child: orderList[index].isSelfPickUp == "1"
                                        ? Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Expanded(
                                                child: SmallButtonContainer(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .primary,
                                                  height: height,
                                                  width: width,
                                                  text: UiUtils
                                                      .getTranslatedLabel(
                                                          context,
                                                          getDirectionLabel),
                                                  start: 0,
                                                  end: width! / 40.0,
                                                  bottom: 0,
                                                  top: 0,
                                                  radius: 5.0,
                                                  status: false,
                                                  borderColor: Theme.of(context)
                                                      .colorScheme
                                                      .primary,
                                                  textColor: Theme.of(context)
                                                      .colorScheme
                                                      .onPrimary,
                                                  onTap: () {
                                                    launchMap(
                                                        latitude, longitude);
                                                  },
                                                ),
                                              ),
                                              Expanded(
                                                child: SmallButtonContainer(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onSurface,
                                                  height: height,
                                                  width: width,
                                                  text: UiUtils
                                                      .getTranslatedLabel(
                                                          context,
                                                          callToRestaurantsLabel),
                                                  start: width! / 40.0,
                                                  end: 0,
                                                  bottom: 0,
                                                  top: 0,
                                                  radius: 5.0,
                                                  status: false,
                                                  borderColor: Theme.of(context)
                                                      .colorScheme
                                                      .onPrimary,
                                                  textColor: Theme.of(context)
                                                      .colorScheme
                                                      .onPrimary,
                                                  onTap: () async {
                                                    final Uri launchUri = Uri(
                                                      scheme: 'tel',
                                                      path: mobileNumber,
                                                    );
                                                    await launchUrl(launchUri);
                                                  },
                                                ),
                                              )
                                            ],
                                          )
                                        : const SizedBox(),
                                  ),
                            Container(
                                decoration: DesignConfig.boxDecorationContainer(
                                    Theme.of(context).colorScheme.onSurface,
                                    0.0),
                                margin: EdgeInsetsDirectional.only(
                                    top: height! / 60.0),
                                padding: EdgeInsetsDirectional.only(
                                    top: height! / 40,
                                    start: width! / 20.0,
                                    end: width! / 20.0,
                                    bottom: height! / 40.0),
                                child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          SvgPicture.asset(
                                              DesignConfig.setSvgPath(
                                                  "ic_invoice"),
                                              height: 14,
                                              width: 14,
                                              fit: BoxFit.scaleDown,
                                              colorFilter: ColorFilter.mode(
                                                  Theme.of(context)
                                                      .colorScheme
                                                      .onPrimary,
                                                  BlendMode.srcIn)),
                                          SizedBox(width: width! / 80.0),
                                          Text(
                                              UiUtils.getTranslatedLabel(
                                                  context, billDetailLabel),
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onPrimary,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                fontStyle: FontStyle.normal,
                                              )),
                                        ],
                                      ),
                                      Padding(
                                        padding: EdgeInsetsDirectional.only(
                                            top: height! / 99.0,
                                            bottom: height! / 99.0,
                                            start: width! / 20.0),
                                        child: DesignConfig.divider(),
                                      ),
                                      Padding(
                                        padding: EdgeInsetsDirectional.only(
                                            start: width! / 20.0,
                                            bottom: height! / 99.0),
                                        child: Row(children: [
                                          Text(
                                              UiUtils.getTranslatedLabel(
                                                  context, subTotalLabel),
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onPrimary
                                                      .withValues(alpha: 0.76),
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w700,
                                                  fontStyle: FontStyle.normal)),
                                          const Spacer(),
                                          Text(
                                              context
                                                      .read<SystemConfigCubit>()
                                                      .getCurrency() +
                                                  double.parse(orderList[index]
                                                          .total!)
                                                      .toStringAsFixed(2),
                                              textAlign: TextAlign.end,
                                              style: TextStyle(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .secondary,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w700,
                                                  fontStyle: FontStyle.normal)),
                                        ]),
                                      ),
                                      Padding(
                                        padding: EdgeInsetsDirectional.only(
                                            start: width! / 20.0),
                                        child: Row(children: [
                                          Text(
                                              "${UiUtils.getTranslatedLabel(context, chargesAndTaxesLabel)} (${orderList[index].totalTaxPercent!}${StringsRes.percentSymbol})",
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onPrimary
                                                      .withValues(alpha: 0.76),
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                  fontStyle: FontStyle.normal)),
                                          const Spacer(),
                                          Text(
                                              context
                                                      .read<SystemConfigCubit>()
                                                      .getCurrency() +
                                                  orderList[index]
                                                      .totalTaxAmount!,
                                              textAlign: TextAlign.right,
                                              style: TextStyle(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .secondary,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  fontStyle: FontStyle.normal)),
                                        ]),
                                      ),
                                      Padding(
                                        padding: EdgeInsetsDirectional.only(
                                            top: height! / 99.0,
                                            bottom: height! / 99.0,
                                            start: width! / 20.0),
                                        child: DesignConfig.divider(),
                                      ),
                                      Padding(
                                        padding: EdgeInsetsDirectional.only(
                                            start: width! / 20.0),
                                        child: Row(children: [
                                          Text(
                                              UiUtils.getTranslatedLabel(
                                                  context, totalLabel),
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onPrimary
                                                      .withValues(alpha: 0.76),
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w700,
                                                  fontStyle: FontStyle.normal)),
                                          const Spacer(),
                                          Text(
                                              "${context.read<SystemConfigCubit>().getCurrency()}${(double.parse(orderList[index].total!) + double.parse(orderList[index].totalTaxAmount!)).toStringAsFixed(2)}",
                                              textAlign: TextAlign.right,
                                              style: TextStyle(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .secondary,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w700,
                                                  fontStyle: FontStyle.normal)),
                                        ]),
                                      ),
                                      Padding(
                                        padding: EdgeInsetsDirectional.only(
                                            top: height! / 99.0,
                                            bottom: height! / 99.0,
                                            start: width! / 20.0),
                                        child: DesignConfig.divider(),
                                      ),
                                      orderList[index].promoDiscount != "0"
                                          ? Padding(
                                              padding: EdgeInsetsDirectional.only(
                                                  bottom: orderList[index]
                                                              .promoDiscount !=
                                                          "0"
                                                      ? 0.0
                                                      : height! / 99.0,
                                                  start: width! / 20.0),
                                              child: Row(children: [
                                                Text(
                                                    StringsRes.coupons +
                                                        orderList[index]
                                                            .promoCode!,
                                                    textAlign: TextAlign.left,
                                                    style: TextStyle(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .onPrimary
                                                            .withValues(
                                                                alpha: 0.76),
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontStyle:
                                                            FontStyle.normal)),
                                                const Spacer(),
                                                Text(
                                                    " - ${context.read<SystemConfigCubit>().getCurrency()}${orderList[index].promoDiscount!}",
                                                    textAlign: TextAlign.right,
                                                    style: TextStyle(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .secondary,
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontStyle:
                                                            FontStyle.normal)),
                                              ]),
                                            )
                                          : Container(),
                                      orderList[index].deliveryTip == "0"
                                          ? const SizedBox()
                                          : Padding(
                                              padding:
                                                  EdgeInsetsDirectional.only(
                                                      start: width! / 20.0,
                                                      bottom: orderList[index]
                                                                  .deliveryTip ==
                                                              "0"
                                                          ? 0.0
                                                          : height! / 99.0),
                                              child: Row(children: [
                                                Text(
                                                    UiUtils.getTranslatedLabel(
                                                        context,
                                                        deliveryTipLabel),
                                                    textAlign: TextAlign.left,
                                                    style: TextStyle(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .onPrimary
                                                            .withValues(
                                                                alpha: 0.76),
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontStyle:
                                                            FontStyle.normal)),
                                                const Spacer(),
                                                Text(
                                                    "${context.read<SystemConfigCubit>().getCurrency()}${orderList[index].deliveryTip!}",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .secondary,
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontStyle:
                                                            FontStyle.normal)),
                                              ]),
                                            ),
                                      orderList[index].walletBalance == "0"
                                          ? const SizedBox()
                                          : Padding(
                                              padding:
                                                  EdgeInsetsDirectional.only(
                                                bottom: orderList[index]
                                                            .walletBalance ==
                                                        "0"
                                                    ? 0.0
                                                    : height! / 99.0,
                                                start: width! / 20.0,
                                              ),
                                              child: Row(children: [
                                                Text(
                                                    UiUtils.getTranslatedLabel(
                                                        context,
                                                        useWalletLabel),
                                                    textAlign: TextAlign.left,
                                                    style: TextStyle(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .onPrimary
                                                            .withValues(
                                                                alpha: 0.76),
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontStyle:
                                                            FontStyle.normal)),
                                                const Spacer(),
                                                Text(
                                                    " - ${context.read<SystemConfigCubit>().getCurrency()}${double.parse(orderList[index].walletBalance!).toStringAsFixed(2)}",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .secondary,
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontStyle:
                                                            FontStyle.normal)),
                                              ]),
                                            ),
                                      orderList[index].isSelfPickUp == "1"
                                          ? const SizedBox()
                                          : Padding(
                                              padding:
                                                  EdgeInsetsDirectional.only(
                                                      bottom: height! / 99.0,
                                                      start: width! / 20.0),
                                              child: Row(children: [
                                                Text(
                                                    UiUtils.getTranslatedLabel(
                                                        context,
                                                        deliveryFeeLabel),
                                                    textAlign: TextAlign.left,
                                                    style: TextStyle(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .onPrimary
                                                            .withValues(
                                                                alpha: 0.76),
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontStyle:
                                                            FontStyle.normal)),
                                                const Spacer(),
                                                Text(
                                                    "${context.read<SystemConfigCubit>().getCurrency()}${orderList[index].deliveryCharge!}",
                                                    textAlign: TextAlign.right,
                                                    style: TextStyle(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .secondary,
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontStyle:
                                                            FontStyle.normal)),
                                              ]),
                                            ),
                                      Padding(
                                        padding: EdgeInsetsDirectional.only(
                                            start: width! / 20.0),
                                        child: Row(children: [
                                          Text(
                                              UiUtils.getTranslatedLabel(
                                                  context, paymentLabel),
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onPrimary
                                                      .withValues(alpha: 0.76),
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                  fontStyle: FontStyle.normal)),
                                          const Spacer(),
                                          Text(
                                              formatText(orderList[index]
                                                  .paymentMethod!),
                                              textAlign: TextAlign.right,
                                              style: TextStyle(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .secondary,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  fontStyle: FontStyle.normal)),
                                        ]),
                                      ),
                                      Padding(
                                        padding: EdgeInsetsDirectional.only(
                                            top: height! / 99.0,
                                            bottom: height! / 99.0,
                                            start: width! / 20.0),
                                        child: DesignConfig.divider(),
                                      ),
                                      Row(children: [
                                        SvgPicture.asset(
                                            DesignConfig.setSvgPath(
                                                "amout_icon"),
                                            height: 14,
                                            width: 14,
                                            fit: BoxFit.scaleDown,
                                            colorFilter: ColorFilter.mode(
                                                Theme.of(context)
                                                    .colorScheme
                                                    .onPrimary,
                                                BlendMode.srcIn)),
                                        SizedBox(width: width! / 80.0),
                                        Text(
                                            UiUtils.getTranslatedLabel(
                                                context, totalPayLabel),
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onPrimary
                                                    .withValues(alpha: 0.76),
                                                fontSize: 14,
                                                fontWeight: FontWeight.w700,
                                                fontStyle: FontStyle.normal)),
                                        const Spacer(),
                                        Text(
                                            "${context.read<SystemConfigCubit>().getCurrency()}${double.parse(orderList[index].totalPayable!).toStringAsFixed(2)}",
                                            textAlign: TextAlign.right,
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .secondary,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w700,
                                                fontStyle: FontStyle.normal)),
                                      ]),
                                    ])),
                            SizedBox(height: height! / 40.0),
                          ],
                        ));
                  }));
        });
  }

  Widget comment() {
    return Container(
      margin: EdgeInsetsDirectional.only(top: height! / 40.0),
      child: TextFormField(
        autovalidateMode: AutovalidateMode.onUserInteraction,
        controller: commentController,
        cursorColor:
            Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.76),
        decoration: DesignConfig.inputDecorationextField(
            UiUtils.getTranslatedLabel(context, writeCommentLabel),
            UiUtils.getTranslatedLabel(context, writeCommentLabel),
            width!,
            context),
        keyboardType: TextInputType.text,
        style: TextStyle(
          color:
              Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.76),
          fontSize: 16.0,
          fontWeight: FontWeight.w500,
        ),
        maxLines: 5,
      ),
    );
  }

  void ratingSuccessDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            contentPadding: EdgeInsetsDirectional.only(
                start: width! / 20.0,
                end: width! / 20.0,
                bottom: height! / 40.0),
            shape: DesignConfig.setRounded(25.0),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Lottie.asset(DesignConfig.setLottiePath("confirm"),
                    height: 180, width: 180),
                Text(UiUtils.getTranslatedLabel(context, ratingTitleLabel),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    style: TextStyle(
                        color: Theme.of(context)
                            .colorScheme
                            .onPrimary
                            .withValues(alpha: 0.76),
                        fontSize: 14,
                        fontWeight: FontWeight.w700)),
                SizedBox(height: height! / 65.0),
                Text(UiUtils.getTranslatedLabel(context, ratingSubTitleLabel),
                    textAlign: TextAlign.center,
                    maxLines: 5,
                    style: TextStyle(
                        color: Theme.of(context)
                            .colorScheme
                            .onPrimary
                            .withValues(alpha: 0.76),
                        fontSize: 14,
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 5.0),
              ],
            ));
      },
    );
    await Future.delayed(
      const Duration(seconds: 2),
    );
    Navigator.of(context).pop();
    Navigator.of(context).pop();
  }

  ratingBottomModelSheet() {
    showModalBottomSheet(
        useSafeArea: true,
        isDismissible: true,
        backgroundColor: Theme.of(context).colorScheme.onSurface,
        shape: DesignConfig.setRoundedBorderCard(0.0, 0.0, 16.0, 16.0),
        isScrollControlled: true,
        enableDrag: true,
        showDragHandle: true,
        context: context,
        builder: (context) {
          return StatefulBuilder(builder:
              (BuildContext context, void Function(void Function()) setStater) {
            dialogState = setStater;
            return Container(
                padding: EdgeInsetsDirectional.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                    start: width! / 20.0,
                    end: width! / 20.0),
                child: SingleChildScrollView(
                  child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                            UiUtils.getTranslatedLabel(context,
                                helpingYourDeliverPartnerByRatingLabel),
                            textAlign: TextAlign.start,
                            maxLines: 1,
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w700)),
                        Padding(
                          padding: EdgeInsetsDirectional.only(
                              bottom: height! / 40.0, top: height! / 40.0),
                          child: DesignConfig.divider(),
                        ),
                        Center(
                            child: Text(
                                UiUtils.getTranslatedLabel(
                                    context, howWasYourDeliveryPartnerLabel),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600))),
                        SizedBox(height: height! / 29.9),
                        Center(
                          child: RatingBar(
                            glowColor: Theme.of(context).colorScheme.onSurface,
                            initialRating: rating!,
                            minRating: 1,
                            direction: Axis.horizontal,
                            allowHalfRating: true,
                            itemCount: 5,
                            itemPadding:
                                const EdgeInsets.symmetric(horizontal: 4.0),
                            ratingWidget: RatingWidget(
                              full: const Icon(
                                Icons.star,
                                color: yellowColor,
                              ),
                              half: const Icon(
                                Icons.star_half_outlined,
                                color: yellowColor,
                              ),
                              empty: Icon(
                                Icons.star_border,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
                            onRatingUpdate: (ratings) {
                              print(ratings);
                              setState(() {
                                rating = ratings;
                              });
                            },
                            tapOnlyMode: true,
                          ),
                        ),
                        SizedBox(height: height! / 29.9),
                        Center(
                            child: Text(
                                UiUtils.getTranslatedLabel(context,
                                    helpUsImproveOurServicesAndYourExperienceByRatingThisLabel),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimary
                                        .withValues(alpha: 0.76),
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12))),
                        Padding(
                          padding:
                              EdgeInsetsDirectional.only(top: height! / 40.0),
                          child: DesignConfig.divider(),
                        ),
                        comment(),
                        BlocConsumer<SetRiderRatingCubit, SetRiderRatingState>(
                            bloc: context.read<SetRiderRatingCubit>(),
                            listener: (context, state) {
                              if (state is SetRiderRatingSuccess) {
                                setState(() {
                                  orderRiderRating = rating.toString();
                                });
                                ratingSuccessDialog(context);
                              } else if (state is SetRiderRatingFailure) {
                                UiUtils.setSnackBar(
                                    state.errorCode, context, false,
                                    type: "2");
                              }
                            },
                            builder: (context, state) {
                              return SizedBox(
                                width: width!,
                                child: ButtonContainer(
                                  color: Theme.of(context).colorScheme.primary,
                                  height: height,
                                  width: width,
                                  text: UiUtils.getTranslatedLabel(
                                      context, submitLabel),
                                  start: 0,
                                  end: 0,
                                  bottom: height! / 55.0,
                                  top: height! / 80.0,
                                  status: false,
                                  borderColor:
                                      Theme.of(context).colorScheme.primary,
                                  textColor:
                                      Theme.of(context).colorScheme.onPrimary,
                                  onPressed: () async {
                                    context
                                        .read<SetRiderRatingCubit>()
                                        .setRiderRating(
                                            widget.riderId,
                                            rating.toString(),
                                            commentController.text,
                                            widget.id);
                                  },
                                ),
                              );
                            })
                      ]),
                ));
          });
        });
  }

  @override
  void dispose() {
    orderController.dispose();
    _connectivitySubscription.cancel();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    super.dispose();
  }

  launchMap(lat, lng) async {
    var url = '';

    if (Platform.isAndroid) {
      url =
          "https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving&dir_action=navigate";
    } else {
      url =
          "http://maps.apple.com/?saddr=&daddr=$lat,$lng&directionsmode=driving&dir_action=navigate";
    }
    await launchUrlString(url, mode: LaunchMode.externalApplication);
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
          : PopScope(
              canPop: true,
              onPopInvokedWithResult: (value, dynamic) {
                if (value) {
                  return;
                }
                if (widget.from == "orderSuccess") {
                  Future.delayed(Duration.zero, () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  });
                } else {
                  Navigator.pop(context);
                }
              },
              child: Scaffold(
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  appBar: DesignConfig.appBar(
                      context,
                      width!,
                      widget.from == "orderDeliverd"
                          ? UiUtils.getTranslatedLabel(
                              context, orderDeliveredLabel)
                          : UiUtils.getTranslatedLabel(
                              context, orderDetailsLabel),
                      const PreferredSize(
                        preferredSize: Size.zero,
                        child: SizedBox(),
                      ),
                      status: widget.from == "orderSuccess" ? false : true),
                  body: Container(
                    width: width,
                    child: orderData(),
                  )),
            ),
    );
  }
}
