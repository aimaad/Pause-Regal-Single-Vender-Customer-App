import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:erestroSingleVender/app/routes.dart';
import 'package:erestroSingleVender/cubit/auth/authCubit.dart';
import 'package:erestroSingleVender/cubit/helpAndSupport/ticketCubit.dart';
import 'package:erestroSingleVender/ui/screen/ticket/chat_screen.dart';
import 'package:erestroSingleVender/ui/screen/settings/no_internet_screen.dart';
import 'package:erestroSingleVender/ui/styles/color.dart';
import 'package:erestroSingleVender/ui/widgets/noDataContainer.dart';
import 'package:erestroSingleVender/ui/widgets/simmer/addressSimmer.dart';
import 'package:erestroSingleVender/ui/widgets/buttomContainer.dart';
import 'package:erestroSingleVender/ui/widgets/smallButtomContainer.dart';
import 'package:erestroSingleVender/utils/constants.dart';
import 'package:erestroSingleVender/utils/labelKeys.dart';
import 'package:erestroSingleVender/utils/uiUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:erestroSingleVender/ui/styles/design.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:erestroSingleVender/utils/internetConnectivity.dart';
import 'package:intl/intl.dart';

class TicketScreen extends StatefulWidget {
  const TicketScreen({Key? key}) : super(key: key);

  @override
  TicketScreenState createState() => TicketScreenState();
}

class TicketScreenState extends State<TicketScreen> {
  double? width, height;
  ScrollController controller = ScrollController();
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  final DateFormat formatter = DateFormat('dd-MM-yyyy');
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
      context
          .read<TicketCubit>()
          .fetchTicket(perPage, context.read<AuthCubit>().getId());
    });
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    super.initState();
  }

  scrollListener() {
    if (controller.position.maxScrollExtent == controller.offset) {
      if (context.read<TicketCubit>().hasMoreData()) {
        context
            .read<TicketCubit>()
            .fetchMoreTicketData(perPage, context.read<AuthCubit>().getId());
      }
    }
  }

  Widget noTransactionData() {
    return NoDataContainer(
        image: "no_data",
        title: UiUtils.getTranslatedLabel(context, noSectionYetLabel),
        subTitle:
            UiUtils.getTranslatedLabel(context, noSectionYetSubTitleLabel),
        width: width!,
        height: height!);
  }

  ticketTypeData(String? id) {
    if (id == "1") {
      return UiUtils.getTranslatedLabel(context, pendingLbLabel);
    } else if (id == "2") {
      return UiUtils.getTranslatedLabel(context, openedLabel);
    } else if (id == "3") {
      return UiUtils.getTranslatedLabel(context, resolvedLabel);
    } else if (id == "4") {
      return UiUtils.getTranslatedLabel(context, closedLabel);
    } else if (id == "5") {
      return UiUtils.getTranslatedLabel(context, reopenedLabel);
    }
  }

  Widget ticket() {
    return BlocConsumer<TicketCubit, TicketState>(
        bloc: context.read<TicketCubit>(),
        listener: (context, state) {},
        builder: (context, state) {
          if (state is TicketProgress || state is TicketInitial) {
            return AddressSimmer(width: width, height: height);
          }

          if (state is TicketFailure) {
            return noTransactionData();
          }
          final ticketList = (state as TicketSuccess).ticketList;
          final hasMore = state.hasMore;
          return SizedBox(
              height: height! / 1.1,
              child: ticketList.isEmpty
                  ? noTransactionData()
                  : ListView.builder(
                      controller: controller,
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      itemCount: ticketList.length,
                      itemBuilder: (BuildContext context, index) {
                        return hasMore && index == (ticketList.length - 1)
                            ? Center(
                                child: CircularProgressIndicator(
                                    color:
                                        Theme.of(context).colorScheme.primary))
                            : GestureDetector(
                                onTap: () {},
                                child: Container(
                                  padding: EdgeInsetsDirectional.only(
                                    start: width! / 25.0,
                                    top: height! / 40.0,
                                    end: width! / 25.0,
                                  ),
                                  width: width!,
                                  margin: EdgeInsetsDirectional.only(
                                      top: index == 0 ? 0.0 : height! / 52.0),
                                  decoration:
                                      DesignConfig.boxDecorationContainer(
                                          Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                          0.0),
                                  child: Padding(
                                    padding: EdgeInsetsDirectional.only(
                                        start: width! / 60.0),
                                    child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Text(
                                                  UiUtils.getTranslatedLabel(
                                                          context, idLabel)
                                                      .toUpperCase(),
                                                  textAlign: TextAlign.start,
                                                  style: TextStyle(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .secondary,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      fontSize: 14.0)),
                                              Text(" #${ticketList[index].id!}",
                                                  textAlign: TextAlign.start,
                                                  style: TextStyle(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .secondary,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      fontSize: 14.0)),
                                              const Spacer(),
                                              ticketList[index].status == ""
                                                  ? const SizedBox()
                                                  : Align(
                                                      alignment:
                                                          Alignment.topRight,
                                                      child: Container(
                                                        alignment:
                                                            Alignment.center,
                                                        padding:
                                                            const EdgeInsetsDirectional
                                                                .only(
                                                                top: 5.0,
                                                                bottom: 5.0,
                                                                start: 5.0,
                                                                end: 5.0),
                                                        margin:
                                                            const EdgeInsetsDirectional
                                                                .only(
                                                                start: 4.5),
                                                        decoration: DesignConfig.boxDecorationContainerBorder(
                                                            ticketList[index]
                                                                        .status !=
                                                                    "4"
                                                                ? orderDeliveredColor
                                                                : orderCancelledColor,
                                                            ticketList[index]
                                                                        .status !=
                                                                    "4"
                                                                ? orderDeliveredColor
                                                                    .withValues(
                                                                        alpha:
                                                                            0.10)
                                                                : orderCancelledColor
                                                                    .withValues(
                                                                        alpha:
                                                                            0.10),
                                                            4.0),
                                                        child: Text(
                                                          ticketTypeData(
                                                              ticketList[index]
                                                                  .status),
                                                          style: TextStyle(
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal,
                                                              color: ticketList[
                                                                              index]
                                                                          .status !=
                                                                      "4"
                                                                  ? orderDeliveredColor
                                                                  : orderCancelledColor),
                                                        ),
                                                      ),
                                                    ),
                                            ],
                                          ),
                                          Padding(
                                            padding: EdgeInsetsDirectional.only(
                                                top: height! / 80.0,
                                                bottom: height! / 80.0),
                                            child: DesignConfig.divider(),
                                          ),
                                          Text(
                                              "${UiUtils.getTranslatedLabel(context, dateLabel)} :",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onPrimary,
                                                  fontWeight: FontWeight.w700,
                                                  fontStyle: FontStyle.normal,
                                                  fontSize: 14.0)),
                                          Text(
                                              formatter.format(DateTime.parse(
                                                  ticketList[index]
                                                      .dateCreated!)),
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onPrimary
                                                      .withValues(alpha: 0.76),
                                                  fontWeight: FontWeight.w600,
                                                  fontStyle: FontStyle.normal,
                                                  fontSize: 14.0)),
                                          SizedBox(height: height! / 60.0),
                                          Text(
                                              "${UiUtils.getTranslatedLabel(context, typeLabel)} :",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onPrimary,
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 14.0)),
                                          Text(ticketList[index].ticketType!,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onPrimary
                                                      .withValues(alpha: 0.76),
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 14.0)),
                                          SizedBox(height: height! / 60.0),
                                          Text(
                                              "${UiUtils.getTranslatedLabel(context, subjectLabel)} :",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onPrimary,
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 14.0)),
                                          Text(ticketList[index].subject!,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onPrimary
                                                      .withValues(alpha: 0.76),
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 14.0)),
                                          SizedBox(height: height! / 60.0),
                                          Text(
                                              "${UiUtils.getTranslatedLabel(context, messageLabel)} :",
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onPrimary,
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 14.0)),
                                          Text(ticketList[index].description!,
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onPrimary
                                                      .withValues(alpha: 0.76),
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 14.0),
                                              maxLines: 2),
                                          SizedBox(height: height! / 80.0),
                                          DesignConfig.divider(),
                                          SizedBox(height: height! / 80.0),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              SmallButtonContainer(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurface,
                                                height: height,
                                                width: width,
                                                text:
                                                    UiUtils.getTranslatedLabel(
                                                        context, editLabel),
                                                start: 0,
                                                end: width! / 40.0,
                                                bottom: height! / 80.0,
                                                top: height! / 99.0,
                                                radius: 5.0,
                                                status: false,
                                                borderColor: Theme.of(context)
                                                    .colorScheme
                                                    .onPrimary,
                                                textColor: Theme.of(context)
                                                    .colorScheme
                                                    .onPrimary,
                                                onTap: () {
                                                  Navigator.of(context)
                                                      .pushNamed(
                                                          Routes.addTicket,
                                                          arguments: {
                                                        'id': int.parse(
                                                            ticketList[index]
                                                                .id!),
                                                        'typeId': int.parse(
                                                            ticketList[index]
                                                                .ticketTypeId!),
                                                        'email':
                                                            ticketList[index]
                                                                .email!,
                                                        'subject':
                                                            ticketList[index]
                                                                .subject!,
                                                        'message':
                                                            ticketList[index]
                                                                .description!,
                                                        'status':
                                                            ticketList[index]
                                                                .status!,
                                                        'from': 'editTicket'
                                                      });
                                                },
                                              ),
                                              SmallButtonContainer(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                                height: height,
                                                width: width,
                                                text:
                                                    UiUtils.getTranslatedLabel(
                                                        context, chatLabel),
                                                start: width! / 99.0,
                                                end: 0,
                                                bottom: height! / 80.0,
                                                top: height! / 99.0,
                                                radius: 5.0,
                                                status: false,
                                                borderColor: Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                                textColor: Theme.of(context)
                                                    .colorScheme
                                                    .onPrimary,
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            ChatScreen(
                                                                id: ticketList[
                                                                        index]
                                                                    .id!,
                                                                status: ticketList[
                                                                        index]
                                                                    .status!)),
                                                  );
                                                },
                                              )
                                            ],
                                          ),
                                          SizedBox(height: height! / 99.0),
                                        ]),
                                  ),
                                ),
                              );
                      }));
        });
  }

  Future<void> refreshList() async {
    context
        .read<TicketCubit>()
        .fetchTicket(perPage, context.read<AuthCubit>().getId());
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
                  width!,
                  UiUtils.getTranslatedLabel(context, helpAndSupportLabel),
                  const PreferredSize(
                      preferredSize: Size.zero, child: SizedBox())),
              bottomNavigationBar: ButtonContainer(
                  color: Theme.of(context).colorScheme.primary,
                  height: height,
                  width: width,
                  text: UiUtils.getTranslatedLabel(context, askQuestionLabel),
                  start: width! / 40.0,
                  end: width! / 40.0,
                  bottom: height! / 55.0,
                  top: 0,
                  status: false,
                  borderColor: Theme.of(context).colorScheme.primary,
                  textColor: Theme.of(context).colorScheme.onPrimary,
                  onPressed: () {
                    Navigator.of(context)
                        .pushNamed(Routes.addTicket, arguments: {
                      'id': 0,
                      'typeId': 0,
                      'email': "",
                      'subject': "",
                      'message': "",
                      'status': "",
                      'from': "addTicket"
                    }).then((value) {
                      if (context.read<TicketCubit>().getTicketList().isEmpty) {
                        refreshList();
                      }
                    });
                  }),
              body: RefreshIndicator(
                  onRefresh: refreshList,
                  color: Theme.of(context).colorScheme.primary,
                  child: ticket()),
            ),
    );
  }
}
