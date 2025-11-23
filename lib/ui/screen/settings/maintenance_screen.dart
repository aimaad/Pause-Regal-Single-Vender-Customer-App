import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:erestroSingleVender/ui/screen/settings/no_internet_screen.dart';
import 'package:erestroSingleVender/utils/constants.dart';
import 'package:erestroSingleVender/utils/labelKeys.dart';
import 'package:erestroSingleVender/utils/uiUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:erestroSingleVender/ui/styles/design.dart';
import 'package:flutter_svg/svg.dart';
import 'package:erestroSingleVender/utils/internetConnectivity.dart';

class MaintenanceScreen extends StatefulWidget {
  const MaintenanceScreen({Key? key}) : super(key: key);

  @override
  MaintenanceScreenState createState() => MaintenanceScreenState();
}

class MaintenanceScreenState extends State<MaintenanceScreen> {
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
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
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
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.dark,
      ),
      child: _connectionStatus == connectivityCheck
          ? const NoInternetScreen()
          : Scaffold(
              body: Container(
              margin: EdgeInsetsDirectional.only(
                  start: width / 20.0, end: width / 20.0),
              width: width,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      UiUtils.getTranslatedLabel(context, maintenanceLabel),
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                          fontSize: 30,
                          fontWeight: FontWeight.w700),
                      maxLines: 2,
                    ),
                    Padding(
                      padding: EdgeInsetsDirectional.only(
                          start: width / 20.0,
                          end: width / 20.0,
                          top: 8.0,
                          bottom: height / 14.0),
                      child: Text(
                          UiUtils.getTranslatedLabel(
                              context, maintenanceSubTitleLabel),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimary
                                  .withValues(alpha: 0.76),
                              fontSize: 16,
                              fontWeight: FontWeight.w500)),
                    ),
                    SvgPicture.asset(DesignConfig.setSvgPath("maintainance")),
                    Padding(
                      padding: EdgeInsetsDirectional.only(
                          start: width / 10.0,
                          end: width / 10.0,
                          top: height / 14.0),
                      child: Text(
                          UiUtils.getTranslatedLabel(
                              context, weAreStillWorkingOnThisLabel),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                              fontSize: 18,
                              fontWeight: FontWeight.w600)),
                    ),
                    Padding(
                      padding: EdgeInsetsDirectional.only(
                          start: width / 10.0, end: width / 10.0, top: 11.0),
                      child: Text(
                          UiUtils.getTranslatedLabel(
                              context, thankYouForYourUnderstandingLabel),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimary
                                  .withValues(alpha: 0.76),
                              fontSize: 16,
                              fontWeight: FontWeight.w500)),
                    ),
                  ]),
            )),
    );
  }
}
