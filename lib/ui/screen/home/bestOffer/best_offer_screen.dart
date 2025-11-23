import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:erestroSingleVender/cubit/home/bestOffer/bestOfferCubit.dart';
import 'package:erestroSingleVender/cubit/settings/settingsCubit.dart';
import 'package:erestroSingleVender/data/repositories/home/bestOffer/bestOfferRepository.dart';
import 'package:erestroSingleVender/ui/screen/settings/no_internet_screen.dart';
import 'package:erestroSingleVender/ui/widgets/offerImageContainer.dart';
import 'package:erestroSingleVender/ui/widgets/simmer/bestOfferSimmer.dart';
import 'package:erestroSingleVender/utils/constants.dart';
import 'package:erestroSingleVender/utils/labelKeys.dart';
import 'package:erestroSingleVender/utils/uiUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:erestroSingleVender/ui/styles/design.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:erestroSingleVender/utils/internetConnectivity.dart';

class BestOfferScreen extends StatefulWidget {
  const BestOfferScreen({Key? key}) : super(key: key);

  @override
  BestOfferScreenState createState() => BestOfferScreenState();
  static Route<dynamic> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
        builder: (_) => BlocProvider<BestOfferCubit>(
              create: (_) => BestOfferCubit(BestOfferRepository()),
              child: const BestOfferScreen(),
            ));
  }
}

class BestOfferScreenState extends State<BestOfferScreen> {
  double? width, height;
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
    bestOfferApi();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
  }

  bestOfferApi() {
    context
        .read<BestOfferCubit>()
        .fetchBestOffer(context.read<SettingsCubit>().getSettings().branchId);
  }

  Widget bestOffer() {
    return BlocConsumer<BestOfferCubit, BestOfferState>(
        bloc: context.read<BestOfferCubit>(),
        listener: (context, state) {},
        builder: (context, state) {
          if (state is BestOfferProgress || state is BestOfferInitial) {
            return BestOfferSimmer(length: 4, width: width!, height: height!);
          }
          if (state is BestOfferFailure) {
            return Center(
                child: Text(
              state.errorCode.toString(),
              textAlign: TextAlign.center,
            ));
          }
          final bestOfferList = (state as BestOfferSuccess).bestOfferList;
          return Padding(
            padding: EdgeInsetsDirectional.only(
                start: width! / 20.0, end: width! / 20.0, top: height! / 60.0),
            child: GridView.count(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                crossAxisCount: 2,
                childAspectRatio: 0.86,
                mainAxisSpacing: height! / 80.0,
                crossAxisSpacing: width! / 40.0,
                children: List.generate(
                  bestOfferList.length,
                  (index) {
                    return OfferImageContainer(
                        index: index,
                        bestOfferList: bestOfferList,
                        height: height!,
                        width: width!);
                  },
                )),
          );
        });
  }

  Future<void> refreshList() async {
    bestOfferApi();
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
                  width,
                  UiUtils.getTranslatedLabel(context, hotDealLabel),
                  const PreferredSize(
                      preferredSize: Size.zero, child: SizedBox())),
              body: Container(
                  height: height!,
                  margin: EdgeInsetsDirectional.only(top: height! / 80.0),
                  width: width,
                  child: RefreshIndicator(
                      onRefresh: refreshList,
                      color: Theme.of(context).colorScheme.primary,
                      child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: bestOffer()))),
            ),
    );
  }
}
