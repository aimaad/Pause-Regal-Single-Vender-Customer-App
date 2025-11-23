import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:erestroSingleVender/ui/widgets/smallButtomContainer.dart';
import 'package:erestroSingleVender/utils/constants.dart';
import 'package:erestroSingleVender/utils/labelKeys.dart';
import 'package:erestroSingleVender/utils/uiUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:erestroSingleVender/ui/styles/design.dart';
import 'package:flutter_svg/svg.dart';
import 'package:erestroSingleVender/utils/internetConnectivity.dart';

class NoInternetScreen extends StatefulWidget {
  final Function? onTapRetry;
  const NoInternetScreen({Key? key, this.onTapRetry}) : super(key: key);

  @override
  NoInternetScreenState createState() => NoInternetScreenState();
}

class NoInternetScreenState extends State<NoInternetScreen> {
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
                  start: width / 10.0, end: width / 10.0, top: height / 5.0),
              width: width,
              child: Column(children: [
                SvgPicture.asset(DesignConfig.setSvgPath("connection_lost")),
                SizedBox(height: height / 20.0),
                Text(
                  UiUtils.getTranslatedLabel(context, noInternetLabel),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontSize: 26,
                      fontWeight: FontWeight.w700),
                  maxLines: 2,
                ),
                SizedBox(height: height / 80.0),
                Text(
                    UiUtils.getTranslatedLabel(
                        context, noInternetSubTitleLabel),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    style: TextStyle(
                        color: Theme.of(context)
                            .colorScheme
                            .onPrimary
                            .withValues(alpha: 0.76),
                        fontSize: 14,
                        fontWeight: FontWeight.w500)),
                SizedBox(height: height / 60.0),
                SmallButtonContainer(
                  color: Theme.of(context).colorScheme.primary,
                  height: height,
                  width: width,
                  text: UiUtils.getTranslatedLabel(context, tryAgainLabel),
                  start: width / 80.0,
                  end: 0,
                  bottom: 0,
                  top: 0,
                  radius: 5.0,
                  status: false,
                  borderColor: Theme.of(context).colorScheme.primary,
                  textColor: Theme.of(context).colorScheme.onPrimary,
                  onTap: () {
                    setState(() {});
                    Future.delayed(const Duration(seconds: 3), () {
                      CheckInternet.initConnectivity();
                      setState(() {});
                    });
                  },
                )
              ]),
            )),
    );
  }
}
