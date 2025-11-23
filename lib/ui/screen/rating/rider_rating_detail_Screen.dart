import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:erestroSingleVender/cubit/auth/authCubit.dart';
import 'package:erestroSingleVender/cubit/rating/deleteRatingCubit.dart';
import 'package:erestroSingleVender/cubit/rating/getRiderRatingCubit.dart';
import 'package:erestroSingleVender/data/repositories/rating/ratingRepository.dart';
import 'package:erestroSingleVender/ui/screen/settings/no_internet_screen.dart';
import 'package:erestroSingleVender/ui/widgets/simmer/productSimmer.dart';
import 'package:erestroSingleVender/ui/widgets/smallButtomContainer.dart';
import 'package:erestroSingleVender/utils/constants.dart';
import 'package:erestroSingleVender/utils/labelKeys.dart';
import 'package:erestroSingleVender/utils/string.dart';
import 'package:erestroSingleVender/utils/uiUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:erestroSingleVender/ui/styles/color.dart';
import 'package:erestroSingleVender/ui/styles/design.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';

import 'package:erestroSingleVender/utils/internetConnectivity.dart';

class RiderRatingDetailScreen extends StatefulWidget {
  final String? riderId;
  const RiderRatingDetailScreen({Key? key, this.riderId}) : super(key: key);

  @override
  RiderRatingDetailScreenState createState() => RiderRatingDetailScreenState();
  static Route<dynamic> route(RouteSettings routeSettings) {
    Map arguments = routeSettings.arguments as Map;
    return CupertinoPageRoute(
        builder: (_) => MultiBlocProvider(providers: [
              BlocProvider<GetRiderRatingCubit>(
                create: (_) => GetRiderRatingCubit(),
                child: RiderRatingDetailScreen(riderId: arguments['riderId']),
              ),
              BlocProvider<DeleteRatingCubit>(
                create: (_) => DeleteRatingCubit(RatingRepository()),
                child: RiderRatingDetailScreen(riderId: arguments['riderId']),
              )
            ], child: RiderRatingDetailScreen(riderId: arguments['riderId'])));
  }
}

class RiderRatingDetailScreenState extends State<RiderRatingDetailScreen> {
  double? width, height;
  ScrollController controller = ScrollController();
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  String? cuisineLength = "";
  RegExp regex = RegExp(r'([^\d]00)(?=[^\d]|$)');
  @override
  void initState() {
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
    print("widget.riderId:${widget.riderId}");
    controller.addListener(scrollListener);
    Future.delayed(Duration.zero, () {
      context
          .read<GetRiderRatingCubit>()
          .fetchGetRiderRating(perPage, widget.riderId!);
    });
    super.initState();
  }

  scrollListener() {
    if (controller.position.maxScrollExtent == controller.offset) {
      if (context.read<GetRiderRatingCubit>().hasMoreData()) {
        context
            .read<GetRiderRatingCubit>()
            .fetchMoreGetRiderRatingData(perPage, widget.riderId!);
      }
    }
  }

  Widget getRiderRating() {
    return BlocConsumer<GetRiderRatingCubit, GetRiderRatingState>(
        bloc: context.read<GetRiderRatingCubit>(),
        listener: (context, state) {},
        builder: (context, state) {
          if (state is GetRiderRatingProgress ||
              state is GetRiderRatingInitial) {
            return ProductSimmer(length: 5, width: width!, height: height!);
          }
          if (state is GetRiderRatingFailure) {
            return Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: height! / 20.0),
                    Text(
                        UiUtils.getTranslatedLabel(context, noReviewFoundLabel),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onSecondary,
                            fontSize: 28)),
                    const SizedBox(height: 5.0),
                    Text(
                        UiUtils.getTranslatedLabel(
                            context, noReviewSubTitleLabel),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        style: const TextStyle(color: lightFont, fontSize: 14)),
                  ]),
            );
          }
          final riderRatingList =
              (state as GetRiderRatingSuccess).riderRatingList;
          final hasMore = state.hasMore;
          return SizedBox(
              height: height! / 1.2,
              child: ListView.builder(
                  shrinkWrap: true,
                  controller: controller,
                  physics: const BouncingScrollPhysics(),
                  itemCount: riderRatingList.length,
                  itemBuilder: (BuildContext context, index) {
                    var inputFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
                    var inputDate = inputFormat
                        .parse(riderRatingList[index].dataAdded!.toString());

                    var outputFormat = DateFormat('dd,MMM yyyy hh:mm a');
                    var outputDate = outputFormat.format(inputDate);
                    return hasMore &&
                            riderRatingList.isEmpty &&
                            index == (riderRatingList.length - 1)
                        ? Center(
                            child: CircularProgressIndicator(
                                color: Theme.of(context).colorScheme.primary))
                        : Container(
                            padding: EdgeInsetsDirectional.only(
                                start: width! / 20.0,
                                top: height! / 40.0,
                                end: width! / 20.0,
                                bottom: height! / 40.0),
                            width: width!,
                            margin: EdgeInsetsDirectional.only(
                                top: index == 0 ? 0.0 : height! / 80.0),
                            decoration: DesignConfig.boxDecorationContainer(
                                Theme.of(context).colorScheme.onSurface, 0.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipOval(
                                        child: DesignConfig.imageWidgets(
                                            riderRatingList[index].userProfile!,
                                            36,
                                            36,
                                            "2")),
                                    Expanded(
                                      child: Padding(
                                        padding: EdgeInsetsDirectional.only(
                                            start: width! / 60.0),
                                        child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                  riderRatingList[index]
                                                      .userName!,
                                                  textAlign: TextAlign.start,
                                                  style: TextStyle(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onPrimary,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                  )),
                                              const SizedBox(height: 2.0),
                                              Text(outputDate,
                                                  textAlign: TextAlign.start,
                                                  style: TextStyle(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .onPrimary
                                                          .withValues(
                                                              alpha: 0.76),
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      overflow: TextOverflow
                                                          .ellipsis),
                                                  maxLines: 1),
                                            ]),
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: EdgeInsetsDirectional.only(
                                      top: height! / 80.0,
                                      bottom: height! / 80.0,
                                      start: width! / 10.0),
                                  child: DesignConfig.divider(),
                                ),
                                Padding(
                                  padding: EdgeInsetsDirectional.only(
                                      bottom: height! / 99.0,
                                      start: width! / 10.0),
                                  child: RatingBar(
                                    itemSize: 24.0,
                                    glowColor:
                                        Theme.of(context).colorScheme.onSurface,
                                    initialRating: double.parse(
                                        riderRatingList[index].rating!),
                                    minRating: 1,
                                    direction: Axis.horizontal,
                                    unratedColor:
                                        Theme.of(context).colorScheme.onPrimary,
                                    allowHalfRating: true,
                                    itemCount: 5,
                                    ignoreGestures: true,
                                    itemPadding:
                                        const EdgeInsetsDirectional.only(
                                            end: 2.0),
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
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary,
                                      ),
                                    ),
                                    onRatingUpdate: (ratings) {
                                      print(ratings);
                                    },
                                  ),
                                ),
                                riderRatingList[index].comment!.isNotEmpty
                                    ? Padding(
                                        padding: EdgeInsetsDirectional.only(
                                            start: width! / 10.0),
                                        child: Text(
                                            UiUtils.getTranslatedLabel(
                                                context, overallReviewLabel),
                                            textAlign: TextAlign.start,
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .secondary,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w700,
                                                fontStyle: FontStyle.normal,
                                                overflow:
                                                    TextOverflow.ellipsis),
                                            maxLines: 1),
                                      )
                                    : const SizedBox(),
                                Padding(
                                  padding: EdgeInsetsDirectional.only(
                                      top: height! / 99.0,
                                      bottom: height! / 99.0,
                                      start: width! / 10.0),
                                  child: Text(riderRatingList[index].comment!,
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onPrimary,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          overflow: TextOverflow.ellipsis),
                                      maxLines: 1),
                                ),
                                context.read<AuthCubit>().getId() ==
                                        riderRatingList[index].userId!
                                    ? Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                            BlocConsumer<DeleteRatingCubit,
                                                    DeleteRatingState>(
                                                bloc: context
                                                    .read<DeleteRatingCubit>(),
                                                listener: (context, state) {
                                                  if (state
                                                      is DeleteRatingSuccess) {
                                                    UiUtils.setSnackBar(
                                                        StringsRes
                                                            .deleteSuccessFully,
                                                        context,
                                                        false,
                                                        type: "1");
                                                  }
                                                },
                                                builder: (context, state) {
                                                  return SmallButtonContainer(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .primary,
                                                    height: height,
                                                    width: width,
                                                    text: UiUtils
                                                        .getTranslatedLabel(
                                                            context,
                                                            deleteLabel),
                                                    start: 0,
                                                    end: width! / 99.0,
                                                    bottom: 0,
                                                    top: height! / 99.0,
                                                    radius: 5.0,
                                                    status: false,
                                                    borderColor:
                                                        Theme.of(context)
                                                            .colorScheme
                                                            .primary,
                                                    textColor: Theme.of(context)
                                                        .colorScheme
                                                        .onPrimary,
                                                    onTap: () {
                                                      context
                                                          .read<
                                                              DeleteRatingCubit>()
                                                          .deleteRiderRating(
                                                              riderRatingList[
                                                                      index]
                                                                  .id!);
                                                      riderRatingList.removeWhere(
                                                          (element) =>
                                                              element.id ==
                                                              riderRatingList[
                                                                      index]
                                                                  .id!);
                                                    },
                                                  );
                                                })
                                          ])
                                    : const SizedBox(),
                              ],
                            ));
                  }));
        });
  }

  Future<void> refreshList() async {
    context.read<GetRiderRatingCubit>().fetchGetRiderRating(
          perPage,
          widget.riderId!,
        );
  }

  @override
  void dispose() {
    controller.dispose();
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
                  width,
                  UiUtils.getTranslatedLabel(context, reviewsLabel),
                  const PreferredSize(
                      preferredSize: Size.zero, child: SizedBox())),
              body: Container(
                width: width,
                child: RefreshIndicator(
                    onRefresh: refreshList,
                    color: Theme.of(context).colorScheme.primary,
                    child: getRiderRating()),
              ),
            ),
    );
  }
}
