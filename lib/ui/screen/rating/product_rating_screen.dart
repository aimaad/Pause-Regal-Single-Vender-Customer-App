import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:erestroSingleVender/cubit/auth/authCubit.dart';
import 'package:erestroSingleVender/cubit/order/historyOrderCubit.dart';
import 'package:erestroSingleVender/cubit/order/orderDetailCubit.dart';
import 'package:erestroSingleVender/cubit/rating/setOrderRatingCubit.dart';
import 'package:erestroSingleVender/cubit/rating/setProductRatingCubit.dart';
import 'package:erestroSingleVender/cubit/settings/settingsCubit.dart';
import 'package:erestroSingleVender/data/model/orderModel.dart';
import 'package:erestroSingleVender/data/model/rattingModel.dart';
import 'package:erestroSingleVender/data/repositories/rating/ratingRepository.dart';
import 'package:erestroSingleVender/ui/styles/color.dart';
import 'package:erestroSingleVender/ui/styles/design.dart';
import 'package:erestroSingleVender/ui/styles/dotted_border.dart';
import 'package:erestroSingleVender/ui/widgets/buttomContainer.dart';
import 'package:erestroSingleVender/ui/widgets/ratingConatiner.dart';
import 'package:erestroSingleVender/ui/widgets/simmer/orderDetailSimmer.dart';
import 'package:erestroSingleVender/utils/labelKeys.dart';
import 'package:erestroSingleVender/ui/screen/settings/no_internet_screen.dart';
import 'package:erestroSingleVender/utils/constants.dart';
import 'package:erestroSingleVender/utils/internetConnectivity.dart';
import 'package:erestroSingleVender/utils/uiUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';

List<Map> commentList = [];

class ProductRatingScreen extends StatefulWidget {
  final String? orderId;
  const ProductRatingScreen({Key? key, this.orderId}) : super(key: key);

  @override
  _ProductRatingScreenState createState() => _ProductRatingScreenState();
  static Route<dynamic> route(RouteSettings routeSettings) {
    Map arguments = routeSettings.arguments as Map;
    return CupertinoPageRoute(
        builder: (_) => MultiBlocProvider(
                providers: [
                  BlocProvider<SetProductRatingCubit>(
                    create: (_) => SetProductRatingCubit(
                      RatingRepository(),
                    ),
                  ),
                  BlocProvider<SetOrderRatingCubit>(
                    create: (_) => SetOrderRatingCubit(
                      RatingRepository(),
                    ),
                  )
                ],
                child: ProductRatingScreen(
                    orderId: arguments['orderId'] as String)));
  }
}

class _ProductRatingScreenState extends State<ProductRatingScreen> {
  double? width, height;
  TextEditingController commentController = TextEditingController(text: "");
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  List<File> reviewPhotos = [];
  List<RatingModel> ratingList = [];
  int? selectedIndex = 4;
  bool? status = false;

  @override
  void initState() {
    super.initState();
    commentList.clear();
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
    Future.delayed(Duration.zero, () {
      context.read<OrderDetailCubit>().fetchOrder(perPage, widget.orderId!, "");
    });
    Future.delayed(const Duration(microseconds: 1000), () {
      ratingData();
    });
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
  }

  ratingData() {
    ratingList = [
      RatingModel(
          id: 1,
          title: UiUtils.getTranslatedLabel(context, veryPoorLabel),
          image: "very_poor",
          rating: "1.0",
          status: "0"),
      RatingModel(
          id: 2,
          title: UiUtils.getTranslatedLabel(context, poorLabel),
          image: "poor",
          rating: "2.0",
          status: "0"),
      RatingModel(
          id: 3,
          title: UiUtils.getTranslatedLabel(context, averageLabel),
          image: "average",
          rating: "3.0",
          status: "0"),
      RatingModel(
          id: 4,
          title: UiUtils.getTranslatedLabel(context, goodLabel),
          image: "good",
          rating: "4.0",
          status: "0"),
      RatingModel(
          id: 5,
          title: UiUtils.getTranslatedLabel(context, excellentLabel),
          image: "excellent",
          rating: "5.0",
          status: "1"),
    ];
  }

  @override
  void dispose() {
    commentController.dispose();
    _connectivitySubscription.cancel();
    super.dispose();
  }

  Widget orderData() {
    return BlocConsumer<OrderDetailCubit, OrderDetailState>(
        bloc: context.read<OrderDetailCubit>(),
        listener: (context, state) {
          if (state is OrderDetailSuccess) {
            final orderList = state.orderList;
            for (int j = 0; j < orderList[0].orderItems!.length; j++) {
              commentList.add({
                'product_id': orderList[0].orderItems![j].productId,
                'rating': "5.0",
                'comment': "",
                'images': []
              });
            }
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

          return Container(
              padding: EdgeInsetsDirectional.only(
                  start: width! / 60.0,
                  end: width! / 60.0,
                  bottom: height! / 99.0),
              width: width!,
              margin: EdgeInsetsDirectional.only(
                top: height! / 70.0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: List.generate(orderList[0].orderItems!.length, (i) {
                  OrderItems data = orderList[0].orderItems![i];
                  if (i == 0) {}
                  return Container(
                      padding: EdgeInsetsDirectional.only(
                          bottom: height! / 80.0,
                          top: height! / 80.0,
                          start: width! / 20.0,
                          end: width! / 20.0),
                      decoration: DesignConfig.boxDecorationContainer(
                          Theme.of(context).colorScheme.onSurface, 0.0),
                      width: width!,
                      margin: EdgeInsetsDirectional.only(
                          bottom: height! / 99.0, top: height! / 99.0),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            i == 0
                                ? Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Container(
                                          decoration: DesignConfig
                                              .boxDecorationContainer(
                                                  Theme.of(context)
                                                      .colorScheme
                                                      .primary,
                                                  2),
                                          height: height! / 40.0,
                                          width: width! / 80.0),
                                      SizedBox(width: width! / 80.0),
                                      Expanded(
                                        child: Text(
                                            UiUtils.getTranslatedLabel(
                                                context, howWasYourLabel),
                                            textAlign: TextAlign.start,
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onPrimary,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700)),
                                      ),
                                    ],
                                  )
                                : const SizedBox(),
                            i == 0
                                ? Padding(
                                    padding: EdgeInsetsDirectional.only(
                                        top: height! / 80.0,
                                        bottom: height! / 80.0),
                                    child: DesignConfig.divider(),
                                  )
                                : const SizedBox(),
                            Row(
                              children: [
                                ClipRRect(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(10.0)),
                                    child: SizedBox(
                                      height: 55,
                                      width: 55,
                                      child: UiUtils.customColorFiltered(
                                        context,
                                        hideFilter: context
                                                .read<SettingsCubit>()
                                                .getSettings()
                                                .isBranchOpen ==
                                            "1",
                                        child: DesignConfig.imageWidgets(
                                            data.image!, 55.0, 55.0, "2"),
                                      ),
                                    )),
                                SizedBox(width: width! / 80.0),
                                Expanded(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      data.indicator == "1"
                                          ? SvgPicture.asset(
                                              DesignConfig.setSvgPath(
                                                  "veg_icon"),
                                              width: 15,
                                              height: 15)
                                          : data.indicator == "2"
                                              ? SvgPicture.asset(
                                                  DesignConfig.setSvgPath(
                                                      "non_veg_icon"),
                                                  width: 15,
                                                  height: 15)
                                              : const SizedBox(),
                                      const SizedBox(height: 8.0),
                                      Text(data.name!,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                              color: greayLightColor,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                              overflow: TextOverflow.ellipsis),
                                          maxLines: 1),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: height! / 80.0),
                            RatingConatiner(
                                index: i,
                                productId: data.productId,
                                height: height!,
                                width: width!),
                          ]));
                }),
              ));
        });
  }

  Widget getImageField() {
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setModalState) {
      return Container(
        padding: const EdgeInsetsDirectional.only(top: 5),
        margin: EdgeInsetsDirectional.only(top: height! / 60.0),
        height: height! / 10.0,
        child: Row(
          children: [
            InkWell(
                onTap: () {
                  _reviewImgFromGallery(setModalState);
                },
                child: Align(
                    alignment: Alignment.topLeft,
                    child: SizedBox(
                      width:
                          reviewPhotos.isEmpty ? width! / 1.12 : width! / 4.0,
                      height: height! / 10.0,
                      child: DottedBorder(
                          dashPattern: const [8, 4],
                          strokeWidth: 1,
                          strokeCap: StrokeCap.round,
                          borderType: BorderType.RRect,
                          radius: const Radius.circular(10.0),
                          child: Center(
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.camera_alt_outlined,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSecondary),
                                  Padding(
                                    padding: const EdgeInsetsDirectional.only(
                                        top: 2.9),
                                    child: Text(
                                        UiUtils.getTranslatedLabel(
                                            context, addPhotosLabel),
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          color: greayLightColor,
                                          fontSize: 12,
                                        )),
                                  )
                                ]),
                          )),
                    ))),
            Expanded(
                child: ListView.builder(
              shrinkWrap: true,
              itemCount: reviewPhotos.length,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, i) {
                return InkWell(
                  child: Stack(
                    alignment: AlignmentDirectional.topEnd,
                    children: [
                      Padding(
                        padding:
                            EdgeInsetsDirectional.only(start: width! / 40.0),
                        child: ClipRRect(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10)),
                          child: Image.file(
                            reviewPhotos[i],
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Container(
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Theme.of(context).colorScheme.secondary),
                          padding: const EdgeInsetsDirectional.all(5.0),
                          child: Icon(Icons.delete,
                              size: 15,
                              color: Theme.of(context).colorScheme.onSurface))
                    ],
                  ),
                  onTap: () {
                    if (mounted) {
                      setModalState(() {
                        reviewPhotos.removeAt(i);
                      });
                    }
                  },
                );
              },
            )),
          ],
        ),
      );
    });
  }

  void _reviewImgFromGallery(StateSetter setModalState) async {
    var result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png'],
      allowMultiple: true,
    );
    if (result != null) {
      reviewPhotos = result.paths.map((path) => File(path!)).toList();
      if (mounted) setModalState(() {});
    } else {
      // User canceled the picker
    }
  }

  Widget rating() {
    return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: List.generate(ratingList.length, (m) {
          return Padding(
            padding: const EdgeInsetsDirectional.only(start: 10.0),
            child: InkWell(
                splashFactory: NoSplash.splashFactory,
                onTap: () {
                  if (selectedIndex == m) {
                    setState(() {
                      ratingList[m].status = "0";
                      selectedIndex = 4;
                    });
                  } else {
                    setState(() {
                      ratingList[m].status = "1";
                      selectedIndex = m;
                    });
                  }
                },
                child: Image.asset(
                    DesignConfig.setPngPath(ratingList[m].image!),
                    height: selectedIndex == m ? 60.0 : 40)),
          );
        }));
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

  navigationPage() async {
    await Future.delayed(const Duration(seconds: 2),
        () => Navigator.of(context).popUntil((route) => route.isFirst));
  }

  Widget comment() {
    return Container(
      padding:
          EdgeInsetsDirectional.only(start: width! / 40.0, end: width! / 99.0),
      decoration: DesignConfig.boxDecorationContainerBorder(
          commentBoxBorderColor, textFieldBackground, 10.0),
      margin: EdgeInsetsDirectional.only(top: height! / 40.0),
      child: TextField(
        controller: commentController,
        cursorColor: Theme.of(context).colorScheme.onSecondary,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText:
              UiUtils.getTranslatedLabel(context, doYouHaveAnyCommentsLabel),
          labelStyle: TextStyle(
            color: Theme.of(context).colorScheme.onSecondary,
            fontSize: 12.0,
            fontWeight: FontWeight.w500,
          ),
          hintStyle: TextStyle(
            color: Theme.of(context).colorScheme.onSecondary,
            fontSize: 12.0,
            fontWeight: FontWeight.w500,
          ),
        ),
        keyboardType: TextInputType.text,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSecondary,
          fontSize: 12.0,
          fontWeight: FontWeight.w500,
        ),
        maxLines: 5,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return _connectionStatus == connectivityCheck
        ? const NoInternetScreen()
        : Scaffold(
            appBar: DesignConfig.appBar(
                context,
                width,
                UiUtils.getTranslatedLabel(context, giveFeedbackLabel),
                const PreferredSize(
                    preferredSize: Size.zero, child: SizedBox())),
            bottomNavigationBar: BlocConsumer<SetProductRatingCubit,
                    SetProductRatingState>(
                bloc: context.read<SetProductRatingCubit>(),
                listener: (context, state) {
                  status = false;
                  if (state is SetProductRatingFailure) {}
                  if (state is SetProductRatingSuccess) {
                    context
                        .read<HistoryOrderCubit>()
                        .updateOrderRateData(state.orderModel);
                    status = false;

                    ratingSuccessDialog(context);
                  } else if (state is SetProductRatingFailure) {}
                },
                builder: (context, state) {
                  return ButtonContainer(
                    color: Theme.of(context).colorScheme.primary,
                    height: height,
                    width: width,
                    text:
                        UiUtils.getTranslatedLabel(context, submitReviewLabel),
                    start: width! / 40.0,
                    end: width! / 40.0,
                    bottom: height! / 55.0,
                    top: 0,
                    status: (state is SetProductRatingProgress) ? true : false,
                    borderColor: Theme.of(context).colorScheme.primary,
                    textColor: Theme.of(context).colorScheme.onPrimary,
                    onPressed: () {
                      setState(() {
                        status = true;
                      });
                      if (state is SetProductRatingProgress) {
                      } else {
                        context.read<SetProductRatingCubit>().setProductRating(
                            context.read<AuthCubit>().getId(),
                            commentList,
                            widget.orderId);
                      }
                    },
                  );
                }),
            body: Container(
                alignment: Alignment.topCenter,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      orderData(),
                    ],
                  ),
                )));
  }
}
