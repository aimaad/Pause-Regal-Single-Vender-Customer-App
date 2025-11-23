import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:erestroSingleVender/app/routes.dart';
import 'package:erestroSingleVender/cubit/notificatiion/notificationCubit.dart';
import 'package:erestroSingleVender/ui/screen/settings/no_internet_screen.dart';
import 'package:erestroSingleVender/ui/widgets/noDataContainer.dart';
import 'package:erestroSingleVender/ui/widgets/simmer/notificationSimmer.dart';
import 'package:erestroSingleVender/utils/constants.dart';
import 'package:erestroSingleVender/utils/labelKeys.dart';
import 'package:erestroSingleVender/utils/uiUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:erestroSingleVender/ui/styles/design.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:erestroSingleVender/utils/internetConnectivity.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  NotificationScreenState createState() => NotificationScreenState();
  static Route<dynamic> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
        builder: (_) => BlocProvider<NotificationCubit>(
              create: (_) => NotificationCubit(),
              child: const NotificationScreen(),
            ));
  }
}

class NotificationScreenState extends State<NotificationScreen> {
  double? width, height;
  ScrollController controller = ScrollController();
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
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
    controller.addListener(scrollListener);
    Future.delayed(Duration.zero, () {
      context.read<NotificationCubit>().fetchNotification(perPage);
    });
    super.initState();
  }

  scrollListener() {
    if (controller.position.maxScrollExtent == controller.offset) {
      if (context.read<NotificationCubit>().hasMoreData()) {
        context.read<NotificationCubit>().fetchMoreNotificationData(perPage);
      }
    }
  }

  @override
  void dispose() {
    controller.dispose();
    _connectivitySubscription.cancel();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    super.dispose();
  }

  Widget noNotificationData() {
    return NoDataContainer(
        image: "no_notification",
        title: UiUtils.getTranslatedLabel(context, noNotificationFoundLabel),
        subTitle: UiUtils.getTranslatedLabel(
            context, noNotificationFoundSubTitleLabel),
        width: width!,
        height: height!);
  }

  Widget notificationData() {
    return BlocConsumer<NotificationCubit, NotificationState>(
        bloc: context.read<NotificationCubit>(),
        listener: (context, state) {},
        builder: (context, state) {
          if (state is NotificationProgress || state is NotificationInitial) {
            return NotificationSimmer(width: width, height: height);
          }
          if (state is NotificationFailure) {
            return noNotificationData();
          }
          final notificationList =
              (state as NotificationSuccess).notificationList;
          final hasMore = state.hasMore;
          return notificationList.isEmpty
              ? noNotificationData()
              : ListView.builder(
                  controller: controller,
                  itemCount: notificationList.length,
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    return hasMore && index == (notificationList.length - 1)
                        ? Center(
                            child: CircularProgressIndicator(
                                color: Theme.of(context).colorScheme.primary))
                        : GestureDetector(
                            onTap: () {
                              if (notificationList[index].type ==
                                  "categories") {
                                Navigator.of(context).pushNamed(
                                    Routes.cuisineDetail,
                                    arguments: {
                                      'categoryId':
                                          notificationList[index].typeId!,
                                      'name': UiUtils.getTranslatedLabel(
                                          context, deliciousCuisineLabel)
                                    });
                              }
                            },
                            child: Container(
                                margin: EdgeInsetsDirectional.only(
                                    start: width! / 20.0,
                                    end: width! / 20.0,
                                    bottom: height! / 50.0),
                                decoration: DesignConfig
                                    .boxDecorationContainerCardShadow(
                                        Theme.of(context).colorScheme.onSurface,
                                        Theme.of(context)
                                            .colorScheme
                                            .onPrimary
                                            .withValues(alpha: 0.1),
                                        8.0,
                                        0,
                                        0,
                                        8,
                                        0),
                                width: width,
                                child: Padding(
                                  padding: EdgeInsetsDirectional.only(
                                      top: width! / 32.0,
                                      bottom: width! / 32.0,
                                      start: width! / 40.0,
                                      end: width! / 40.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                          margin: EdgeInsetsDirectional.only(
                                              top: 5, end: 5),
                                          height: 10,
                                          width: 10,
                                          decoration: DesignConfig
                                              .boxDecorationContainer(
                                                  Theme.of(context)
                                                      .colorScheme
                                                      .primary,
                                                  100)),
                                      Expanded(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              notificationList[index].title!,
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onPrimary,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w700),
                                              maxLines: 2,
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                                notificationList[index]
                                                    .message!,
                                                textAlign: TextAlign.start,
                                                maxLines: 2,
                                                style: TextStyle(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onPrimary
                                                        .withValues(
                                                            alpha: 0.76),
                                                    fontSize: 12,
                                                    fontWeight:
                                                        FontWeight.w500)),
                                          ],
                                        ),
                                      ),
                                      notificationList[index].image!.isEmpty
                                          ? const SizedBox.shrink()
                                          : ClipRRect(
                                              borderRadius:
                                                  const BorderRadius.all(
                                                      Radius.circular(4.0)),
                                              child: DesignConfig.imageWidgets(
                                                  notificationList[index]
                                                      .image!,
                                                  81,
                                                  81,
                                                  "2")),
                                    ],
                                  ),
                                )),
                          );
                  },
                );
        });
  }

  Future<void> refreshList() async {
    context.read<NotificationCubit>().fetchNotification(perPage);
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
                  UiUtils.getTranslatedLabel(context, notificationLabel),
                  const PreferredSize(
                      preferredSize: Size.zero, child: SizedBox())),
              body: Container(
                  margin: EdgeInsetsDirectional.only(top: height! / 80.0),
                  width: width,
                  height: height! / 1.1,
                  child: RefreshIndicator(
                      onRefresh: refreshList,
                      color: Theme.of(context).colorScheme.primary,
                      child: notificationData())),
            ),
    );
  }
}
