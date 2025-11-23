import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:erestroSingleVender/cubit/faq/faqsCubit.dart';
import 'package:erestroSingleVender/ui/screen/settings/no_internet_screen.dart';
import 'package:erestroSingleVender/ui/widgets/noDataContainer.dart';
import 'package:erestroSingleVender/utils/constants.dart';
import 'package:erestroSingleVender/utils/labelKeys.dart';
import 'package:erestroSingleVender/utils/uiUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:erestroSingleVender/ui/styles/color.dart';
import 'package:erestroSingleVender/ui/styles/design.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:erestroSingleVender/utils/internetConnectivity.dart';

class FaqsScreen extends StatefulWidget {
  const FaqsScreen({Key? key}) : super(key: key);

  @override
  FaqsScreenState createState() => FaqsScreenState();
  static Route<FaqsScreen> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
        builder: (_) => BlocProvider<FaqsCubit>(
              create: (_) => FaqsCubit(),
              child: const FaqsScreen(),
            ));
  }
}

class FaqsScreenState extends State<FaqsScreen> {
  double? width, height;
  ScrollController controller = ScrollController();
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

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
    controller.addListener(scrollListener);
    refreshList();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
  }

  scrollListener() {
    if (controller.position.maxScrollExtent == controller.offset) {
      if (context.read<FaqsCubit>().hasMoreData()) {
        context.read<FaqsCubit>().fetchMoreFaqsData(perPage);
      }
    }
  }

  Widget noFaqsData() {
    return NoDataContainer(
        image: "no_data",
        title: UiUtils.getTranslatedLabel(context, noSectionYetLabel),
        subTitle:
            UiUtils.getTranslatedLabel(context, noSectionYetSubTitleLabel),
        width: width!,
        height: height!);
  }

  Widget faqs() {
    return BlocConsumer<FaqsCubit, FaqsState>(
        bloc: context.read<FaqsCubit>(),
        listener: (context, state) {},
        builder: (context, state) {
          if (state is FaqsProgress || state is FaqsInitial) {
            return Center(
                child: CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.primary));
          }
          if (state is FaqsFailure) {
            return noFaqsData();
          }
          final faqsList = (state as FaqsSuccess).faqsList;
          final hasMore = state.hasMore;
          return faqsList.isEmpty
              ? noFaqsData()
              : ListView.builder(
                  padding: EdgeInsets.zero,
                  scrollDirection: Axis.vertical,
                  controller: controller,
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: faqsList.length,
                  itemBuilder: (context, index) {
                    return hasMore && index == (faqsList.length - 1)
                        ? Center(
                            child: CircularProgressIndicator(
                                color: Theme.of(context).colorScheme.primary))
                        : Container(
                            margin: EdgeInsetsDirectional.only(
                                top: index == 0 ? 0.0 : height! / 80.0,
                                start: width! / 20.0,
                                end: width! / 20.0),
                            decoration:
                                DesignConfig.boxDecorationContainerBorder(
                                    Theme.of(context).colorScheme.secondary,
                                    faqsList[index].isExpanded == true
                                        ? Theme.of(context)
                                            .colorScheme
                                            .secondary
                                        : Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                                    10.0),
                            child: Theme(
                              data: ThemeData().copyWith(
                                dividerColor: Colors.transparent,
                              ),
                              child: ExpansionTile(
                                childrenPadding: EdgeInsets.zero,
                                iconColor: lightFont,
                                collapsedIconColor: lightFont,
                                expandedAlignment: Alignment.topLeft,
                                onExpansionChanged: (bool isExpanded) {
                                  setState(() {
                                    faqsList[index].isExpanded = isExpanded;
                                  });
                                },
                                trailing: const SizedBox.shrink(),
                                title: Text(
                                  faqsList[index].question!,
                                  softWrap: true,
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: faqsList[index].isExpanded == true
                                          ? Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                          : Theme.of(context)
                                              .colorScheme
                                              .onPrimary,
                                      fontWeight: FontWeight.w500),
                                ),
                                expandedCrossAxisAlignment:
                                    CrossAxisAlignment.start,
                                controlAffinity:
                                    ListTileControlAffinity.trailing,
                                leading: Icon(
                                  faqsList[index].isExpanded == true
                                      ? Icons.remove_circle_sharp
                                      : Icons.add_circle_sharp,
                                  color: faqsList[index].isExpanded == true
                                      ? Theme.of(context).colorScheme.onSurface
                                      : Theme.of(context).colorScheme.secondary,
                                ),
                                children: [
                                  Padding(
                                    padding: EdgeInsetsDirectional.only(
                                        start: width! / 5.5,
                                        bottom: height! / 40.0),
                                    child: Text(faqsList[index].answer!,
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                          fontSize: 10,
                                          color:
                                              faqsList[index].isExpanded == true
                                                  ? Theme.of(context)
                                                      .colorScheme
                                                      .onSurface
                                                  : Theme.of(context)
                                                      .colorScheme
                                                      .onPrimary,
                                          fontWeight: FontWeight.normal,
                                        )),
                                  ),
                                ],
                              ),
                            ),
                          );
                  });
        });
  }

  Future<void> refreshList() async {
    context.read<FaqsCubit>().fetchFaqs(perPage);
  }

  @override
  void dispose() {
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
                  UiUtils.getTranslatedLabel(context, faqsLabel),
                  const PreferredSize(
                      preferredSize: Size.zero, child: SizedBox())),
              body: Container(
                height: height!,
                padding: EdgeInsetsDirectional.only(top: height! / 80.0),
                width: width,
                child: RefreshIndicator(
                  onRefresh: refreshList,
                  color: Theme.of(context).colorScheme.primary,
                  child: faqs(),
                ),
              )),
    );
  }
}
