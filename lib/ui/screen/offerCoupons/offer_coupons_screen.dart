import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:erestroSingleVender/cubit/cart/getCartCubit.dart';
import 'package:erestroSingleVender/cubit/promoCode/promoCodeCubit.dart';
import 'package:erestroSingleVender/cubit/promoCode/validatePromoCodeCubit.dart';
import 'package:erestroSingleVender/cubit/settings/settingsCubit.dart';
import 'package:erestroSingleVender/data/repositories/promoCode/promoCodeRepository.dart';
import 'package:erestroSingleVender/cubit/systemConfig/systemConfigCubit.dart';
import 'package:erestroSingleVender/ui/screen/cart/cart_screen.dart';
import 'package:erestroSingleVender/ui/screen/settings/no_internet_screen.dart';
import 'package:erestroSingleVender/ui/styles/coupons_card_painter.dart';
import 'package:erestroSingleVender/ui/widgets/noDataContainer.dart';
import 'package:erestroSingleVender/ui/widgets/simmer/myOrderSimmer.dart';
import 'package:erestroSingleVender/ui/widgets/smallButtomContainer.dart';
import 'package:erestroSingleVender/utils/constants.dart';
import 'package:erestroSingleVender/utils/labelKeys.dart';
import 'package:erestroSingleVender/utils/uiUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:erestroSingleVender/ui/styles/color.dart';
import 'package:erestroSingleVender/ui/styles/design.dart';
import 'package:erestroSingleVender/utils/string.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:erestroSingleVender/utils/internetConnectivity.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

class OfferCouponsScreen extends StatefulWidget {
  const OfferCouponsScreen({Key? key}) : super(key: key);

  @override
  OfferCouponsScreenState createState() => OfferCouponsScreenState();
}

class OfferCouponsScreenState extends State<OfferCouponsScreen> {
  double? width, height;
  ScrollController promoCodeController = ScrollController();
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  String? promoCodeData = "", finalTotalData = "";
  TextEditingController addCouponsController = TextEditingController(text: "");
  bool checkStatusOfMessage = true;
  var inputFormat = DateFormat('yyyy-MM-dd');
  var outputFormat = DateFormat('dd,MMMM yyyy');

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
    promoCodeController.addListener(promoCodeScrollListener);
    refreshList();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
  }

  Future<void> refreshList() async {
    Future.delayed(Duration.zero, () {
      context.read<PromoCodeCubit>().fetchPromoCode(
          perPage, context.read<SettingsCubit>().getSettings().branchId);
    });
  }

  promoCodeScrollListener() {
    if (promoCodeController.position.maxScrollExtent ==
        promoCodeController.offset) {
      if (context.read<PromoCodeCubit>().hasMoreData()) {
        context.read<PromoCodeCubit>().fetchMorePromoCodeData(
            perPage, context.read<SettingsCubit>().getSettings().branchId);
      }
    }
  }

  Widget noCoupnData() {
    return NoDataContainer(
        image: "no_data",
        title: UiUtils.getTranslatedLabel(context, noCouponYetLabel),
        subTitle: UiUtils.getTranslatedLabel(context, noCouponYetSubTitleLabel),
        width: width!,
        height: height!);
  }

  Widget offerCoupons() {
    return BlocConsumer<PromoCodeCubit, PromoCodeState>(
        bloc: context.read<PromoCodeCubit>(),
        listener: (context, state) {},
        builder: (context, state) {
          if (state is PromoCodeProgress || state is PromoCodeInitial) {
            return MyOrderSimmer(length: 5, width: width!, height: height!);
          }
          if (state is PromoCodeFailure) {
            print(state.errorMessage.toString());
            return SizedBox(height: height! / 1.3, child: noCoupnData());
          }
          final promoCodeList = (state as PromoCodeSuccess).promoCodeList;
          final hasMore = state.hasMore;
          return SizedBox(
              height: height! / 1.3,
              child: promoCodeList.isEmpty
                  ? noCoupnData()
                  : ListView.builder(
                      controller: promoCodeController,
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: promoCodeList.length,
                      itemBuilder: (BuildContext context, index) {
                        var inputDate =
                            inputFormat.parse(promoCodeList[index].endDate!);
                        var outputDate = outputFormat.format(inputDate);
                        return hasMore && index == (promoCodeList.length - 1)
                            ? Center(
                                child: CircularProgressIndicator(
                                    color:
                                        Theme.of(context).colorScheme.primary))
                            : BlocProvider<ValidatePromoCodeCubit>(
                                create: (context) => ValidatePromoCodeCubit(
                                    PromoCodeRepository()),
                                child: Builder(builder: (context) {
                                  return BlocConsumer<ValidatePromoCodeCubit,
                                          ValidatePromoCodeState>(
                                      bloc: context
                                          .read<ValidatePromoCodeCubit>(),
                                      listener: (context, state) {
                                        if (state
                                            is ValidatePromoCodeFetchFailure) {
                                          UiUtils.setSnackBar(
                                              state.errorMessage,
                                              context,
                                              false,
                                              type: "2");
                                        }
                                        if (state
                                            is ValidatePromoCodeFetchSuccess) {
                                          promoCode = state
                                              .promoCodeValidateModel!
                                              .promoCode!
                                              .toString();
                                          promoAmt = double.parse(state
                                              .promoCodeValidateModel!
                                              .finalDiscount!);

                                          coupons(
                                              context,
                                              promoCode!,
                                              promoAmt,
                                              double.parse(state
                                                  .promoCodeValidateModel!
                                                  .finalTotal!));
                                        }
                                      },
                                      builder: (context, state) {
                                        return Container(
                                          padding: EdgeInsetsDirectional.only(
                                              start: width! / 80.0,
                                              top: height! / 80.0,
                                              end: width! / 80.0,
                                              bottom: height! / 80.0),
                                          margin: EdgeInsetsDirectional.only(
                                              start: width! / 30.0,
                                              end: width! / 30.0),
                                          child: RotatedBox(
                                            quarterTurns: -1,
                                            child: CustomPaint(
                                              painter: CouponsCardPainter(
                                                borderColor: Theme.of(context)
                                                    .colorScheme
                                                    .onPrimary
                                                    .withValues(alpha: 0.3),
                                                bgColor: Theme.of(context)
                                                    .colorScheme
                                                    .primary
                                                    .withValues(alpha: 0.10),
                                              ),
                                              child: Container(
                                                padding:
                                                    EdgeInsetsDirectional.only(
                                                        start: width! / 40.0,
                                                        top: height! / 80.0,
                                                        bottom: height! / 80.0,
                                                        end: width! / 40.0),
                                                child: RotatedBox(
                                                  quarterTurns: 1,
                                                  child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Expanded(
                                                          flex: 4,
                                                          child: Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              ClipRRect(
                                                                  borderRadius:
                                                                      const BorderRadius
                                                                          .all(
                                                                          Radius.circular(
                                                                              5.0)),
                                                                  child: DesignConfig.imageWidgets(
                                                                      promoCodeList[
                                                                              index]
                                                                          .image!,
                                                                      50.0,
                                                                      50.0,
                                                                      "2")),
                                                              SizedBox(
                                                                  height:
                                                                      height! /
                                                                          80.0),
                                                              Text(
                                                                  "${promoCodeList[index].discountType == "amount" ? context.read<SystemConfigCubit>().getCurrency() : ""}${promoCodeList[index].discount!}${promoCodeList[index].discountType == "amount" ? "" : StringsRes.percentSymbol} ${StringsRes.off} ${StringsRes.upTo} ${context.read<SystemConfigCubit>().getCurrency() + promoCodeList[index].maxDiscountAmt!}",
                                                                  textAlign:
                                                                      TextAlign
                                                                          .start,
                                                                  style: TextStyle(
                                                                      color: Theme.of(
                                                                              context)
                                                                          .colorScheme
                                                                          .onSecondary,
                                                                      fontSize:
                                                                          18,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w700,
                                                                      fontStyle:
                                                                          FontStyle
                                                                              .normal)),
                                                              const SizedBox(
                                                                  height: 5.0),
                                                              SizedBox(
                                                                height:
                                                                    height! /
                                                                        22,
                                                                child: Text(
                                                                    promoCodeList[
                                                                            index]
                                                                        .message!,
                                                                    style: TextStyle(
                                                                        color: Theme.of(
                                                                                context)
                                                                            .colorScheme
                                                                            .onPrimary
                                                                            .withValues(
                                                                                alpha:
                                                                                    0.76),
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w500,
                                                                        fontStyle:
                                                                            FontStyle
                                                                                .normal,
                                                                        fontSize:
                                                                            14.0),
                                                                    maxLines: 2,
                                                                    textAlign:
                                                                        TextAlign
                                                                            .start),
                                                              ),
                                                              SizedBox(
                                                                  height:
                                                                      height! /
                                                                          60.0),
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .min,
                                                                children: [
                                                                  Text(
                                                                      "${UiUtils.getTranslatedLabel(context, expiresLabel)}: ",
                                                                      style: TextStyle(
                                                                          color: Theme.of(context)
                                                                              .colorScheme
                                                                              .onPrimary,
                                                                          fontWeight: FontWeight
                                                                              .w700,
                                                                          fontStyle: FontStyle
                                                                              .normal,
                                                                          fontSize:
                                                                              12.0),
                                                                      textAlign:
                                                                          TextAlign
                                                                              .left),
                                                                  Text(
                                                                      outputDate
                                                                          .toString(),
                                                                      style: TextStyle(
                                                                          color: Theme.of(context)
                                                                              .colorScheme
                                                                              .onPrimary,
                                                                          fontWeight: FontWeight
                                                                              .w700,
                                                                          fontStyle: FontStyle
                                                                              .normal,
                                                                          fontSize:
                                                                              12.0),
                                                                      textAlign:
                                                                          TextAlign
                                                                              .left)
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Text(
                                                                StringsRes
                                                                    .coupons,
                                                                style: TextStyle(
                                                                    color: Theme.of(
                                                                            context)
                                                                        .colorScheme
                                                                        .onPrimary
                                                                        .withValues(
                                                                            alpha:
                                                                                0.76),
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w700,
                                                                    fontStyle:
                                                                        FontStyle
                                                                            .normal,
                                                                    fontSize:
                                                                        14.0),
                                                                textAlign:
                                                                    TextAlign
                                                                        .center),
                                                            SizedBox(
                                                                height:
                                                                    height! /
                                                                        80.0),
                                                            SizedBox(
                                                              width:
                                                                  width! / 4.0,
                                                              child: Text(
                                                                  promoCodeList[
                                                                          index]
                                                                      .promoCode!,
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
                                                                      fontSize:
                                                                          18.0),
                                                                  maxLines: 2,
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center),
                                                            ),
                                                            SizedBox(
                                                                height:
                                                                    height! /
                                                                        80.0),
                                                            SmallButtonContainer(
                                                              color: Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .primary,
                                                              height: height,
                                                              width: width,
                                                              text: UiUtils
                                                                  .getTranslatedLabel(
                                                                      context,
                                                                      redeemNowLabel),
                                                              start:
                                                                  width! / 40.0,
                                                              end: 0,
                                                              bottom: 0,
                                                              top: height! /
                                                                  80.0,
                                                              radius: 5.0,
                                                              status: false,
                                                              borderColor: Theme
                                                                      .of(context)
                                                                  .colorScheme
                                                                  .primary,
                                                              textColor: Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .onPrimary,
                                                              onTap: () {
                                                                promoCodeData =
                                                                    promoCodeList[
                                                                            index]
                                                                        .promoCode!;
                                                                finalTotalData = context
                                                                    .read<
                                                                        GetCartCubit>()
                                                                    .getCartModel()
                                                                    .overallAmount
                                                                    .toString();
                                                                context.read<ValidatePromoCodeCubit>().getValidatePromoCode(
                                                                    promoCodeData,
                                                                    finalTotalData,
                                                                    context
                                                                        .read<
                                                                            SettingsCubit>()
                                                                        .getSettings()
                                                                        .branchId);
                                                              },
                                                            ),
                                                          ],
                                                        ),
                                                      ]),
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      });
                                }),
                              );
                      }));
        });
  }

  void coupons(BuildContext context, String code, double price,
      double finalAmount) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            contentPadding: EdgeInsetsDirectional.only(bottom: height! / 40.0),
            shape: DesignConfig.setRounded(25.0),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Lottie.asset(DesignConfig.setLottiePath("confirm"),
                    height: 180, width: 180),
                Text("$code ${StringsRes.applie}",
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
                Text(
                    "${StringsRes.youSaved} ${context.read<SystemConfigCubit>().getCurrency()} ${price.toString()}",
                    textAlign: TextAlign.center,
                    maxLines: 5,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 22,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 5.0),
                Text(
                    UiUtils.getTranslatedLabel(
                        context, withThisCouponCodeLabel),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    style: TextStyle(
                        color: Theme.of(context)
                            .colorScheme
                            .onPrimary
                            .withValues(alpha: 0.76),
                        fontSize: 14,
                        fontWeight: FontWeight.w700)),
              ],
            ));
      },
    );
    await Future.delayed(
      const Duration(seconds: 2),
    );
    Navigator.of(context).pop();

    Navigator.of(context)
        .pop({"code": code, "amount": price, "finalAmount": finalAmount});
  }

  Widget addCoupons() {
    return Container(
        alignment: Alignment.centerLeft,
        margin: EdgeInsetsDirectional.only(
          start: width! / 20.0,
          end: width! / 20.0,
        ),
        child: TextField(
          onChanged: (value) {
            if (value.isEmpty) {
              checkStatusOfMessage = true;
            } else {
              checkStatusOfMessage = false;
            }
            setState(() {});
          },
          controller: addCouponsController,
          cursorColor: lightFont,
          textAlignVertical: TextAlignVertical.center,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: UiUtils.getTranslatedLabel(context, enterCouponCodeLabel),
            hintStyle: TextStyle(
                color: Theme.of(context)
                    .colorScheme
                    .onPrimary
                    .withValues(alpha: 0.76),
                fontSize: 16.0,
                fontWeight: FontWeight.w500),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide(width: 1.0, color: textFieldBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide(width: 1.0, color: textFieldBorder),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide(width: 1.0, color: textFieldBorder),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide(width: 1.0, color: textFieldBorder),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide(width: 1.0, color: textFieldBorder),
            ),
            suffixIcon: checkStatusOfMessage == false
                ? BlocProvider<ValidatePromoCodeCubit>(
                    create: (context) =>
                        ValidatePromoCodeCubit(PromoCodeRepository()),
                    child: Builder(builder: (context) {
                      return BlocConsumer<ValidatePromoCodeCubit,
                              ValidatePromoCodeState>(
                          bloc: context.read<ValidatePromoCodeCubit>(),
                          listener: (context, state) {
                            if (state is ValidatePromoCodeFetchFailure) {
                              UiUtils.setSnackBar(
                                  state.errorMessage, context, false,
                                  type: "2");
                              checkStatusOfMessage = false;
                            }
                            if (state is ValidatePromoCodeFetchSuccess) {
                              promoCode = state
                                  .promoCodeValidateModel!.promoCode!
                                  .toString();
                              promoAmt = double.parse(
                                  state.promoCodeValidateModel!.finalDiscount!);
                              coupons(
                                  context,
                                  promoCode!,
                                  promoAmt,
                                  double.parse(state
                                      .promoCodeValidateModel!.finalTotal!));
                            }
                          },
                          builder: (context, state) {
                            return InkWell(
                                onTap: () {
                                  if (addCouponsController.text
                                      .trim()
                                      .isNotEmpty) {
                                    checkStatusOfMessage = true;

                                    promoCodeData =
                                        addCouponsController.text.trim();
                                    finalTotalData = context
                                        .read<GetCartCubit>()
                                        .getCartModel()
                                        .overallAmount
                                        .toString();
                                    context
                                        .read<ValidatePromoCodeCubit>()
                                        .getValidatePromoCode(
                                            promoCodeData,
                                            finalTotalData,
                                            context
                                                .read<SettingsCubit>()
                                                .getSettings()
                                                .branchId);
                                  }
                                },
                                child: Padding(
                                  padding: EdgeInsetsDirectional.only(
                                      top: height! / 60.0,
                                      bottom: height! / 80.0),
                                  child: Text(
                                      UiUtils.getTranslatedLabel(
                                          context, applyLabel),
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary)),
                                ));
                          });
                    }),
                  )
                : const SizedBox(),
          ),
          keyboardType: TextInputType.text,
          style: TextStyle(
              color: Theme.of(context)
                  .colorScheme
                  .onPrimary
                  .withValues(alpha: 0.76),
              fontSize: 16.0,
              fontWeight: FontWeight.w500),
        ));
  }

  @override
  void dispose() {
    promoCodeController.dispose();
    addCouponsController.dispose();
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
              appBar: DesignConfig.appBar(
                  context,
                  width!,
                  UiUtils.getTranslatedLabel(context, offerCouponsLabel),
                  const PreferredSize(
                      preferredSize: Size.zero, child: SizedBox())),
              body: Container(
                  height: height!,
                  margin: EdgeInsetsDirectional.only(top: height! / 80.0),
                  width: width,
                  child: SingleChildScrollView(
                    physics: const NeverScrollableScrollPhysics(),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                            decoration: DesignConfig.boxDecorationContainer(
                                Theme.of(context).colorScheme.onSurface, 10.0),
                            padding: EdgeInsetsDirectional.only(
                                top: height! / 80, bottom: height! / 80.0),
                            child: addCoupons()),
                        RefreshIndicator(
                            onRefresh: refreshList,
                            color: Theme.of(context).colorScheme.primary,
                            child: offerCoupons()),
                      ],
                    ),
                  )),
            ),
    );
  }
}
