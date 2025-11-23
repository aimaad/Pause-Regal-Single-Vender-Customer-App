import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:erestroSingleVender/app/routes.dart';
import 'package:erestroSingleVender/data/model/introduction_slider_model.dart';
import 'package:erestroSingleVender/cubit/settings/settingsCubit.dart';
import 'package:erestroSingleVender/ui/widgets/buttomContainer.dart';
import 'package:erestroSingleVender/ui/styles/design.dart';
import 'package:erestroSingleVender/utils/constants.dart';
import 'package:erestroSingleVender/utils/labelKeys.dart';
import 'package:erestroSingleVender/ui/screen/settings/no_internet_screen.dart';
import 'package:erestroSingleVender/utils/uiUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

import 'package:erestroSingleVender/utils/internetConnectivity.dart';

class IntroductionSliderScreen extends StatefulWidget {
  const IntroductionSliderScreen({Key? key}) : super(key: key);

  @override
  IntroductionSliderScreenState createState() =>
      IntroductionSliderScreenState();
}

class IntroductionSliderScreenState extends State<IntroductionSliderScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController(initialPage: 0);
  int currentIndex = 0;
  double? height, width;
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  double endProgress = 0.05;
  List<IntroductionSliderModel> introductionSliderList = [];

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
    Future.delayed(const Duration(microseconds: 1000), () {
      introductionData();
    });
    super.initState();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _connectivitySubscription.cancel();
    super.dispose();
  }

  _onPageChanged(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  List<T?> map<T>(List list, Function handler) {
    List<T?> result = [];
    for (var i = 0; i < list.length; i++) {
      result.add(handler(i, list[i]));
    }

    return result;
  }

  void onNext(int index) {
    setState(() {
      if (currentIndex < 2) {
        currentIndex++;
      } else {
        currentIndex = 0;
      }
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  introductionData() {
    introductionSliderList = [
      IntroductionSliderModel(
        id: 1,
        title: UiUtils.getTranslatedLabel(context, introTitle1Label),
        subTitle: UiUtils.getTranslatedLabel(context, introSubTitle1Label),
        image: "intro_1",
      ),
      IntroductionSliderModel(
        id: 2,
        title: UiUtils.getTranslatedLabel(context, introTitle2Label),
        subTitle: UiUtils.getTranslatedLabel(context, introSubTitle2Label),
        image: "intro_2",
      ),
      IntroductionSliderModel(
        id: 1,
        title: UiUtils.getTranslatedLabel(context, introTitle3Label),
        subTitle: UiUtils.getTranslatedLabel(context, introSubTitle3Label),
        image: "intro_3",
      ),
    ];
  }

  Widget _slider() {
    return PageView.builder(
      itemCount: introductionSliderList.length,
      scrollDirection: Axis.horizontal,
      controller: _pageController,
      onPageChanged: _onPageChanged,
      itemBuilder: (BuildContext context, int index) {
        return Padding(
          padding: EdgeInsetsDirectional.only(top: height! / 10.9),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsetsDirectional.only(
                    start: width! / 20.0, bottom: height! / 12.0),
                child: Text(
                  introductionSliderList[currentIndex].title!,
                  style: TextStyle(
                      fontSize: 32,
                      color: Theme.of(context).colorScheme.onSecondary,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.start,
                ),
              ),
              Padding(
                padding: EdgeInsetsDirectional.only(top: height! / 28.0),
                child: SvgPicture.asset(DesignConfig.setSvgPath(
                    introductionSliderList[index].image!)),
              ),
              Padding(
                padding: EdgeInsetsDirectional.only(
                    top: height! / 20.0,
                    bottom: height! / 40.0,
                    start: width! / 20.0,
                    end: width! / 20.0),
                child: Text(
                  introductionSliderList[currentIndex].subTitle!,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontWeight: FontWeight.w500,
                      height: 1.5),
                ),
              ),
            ],
          ),
        );
      },
    );
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
          : SafeArea(
              bottom: Platform.isIOS ? true : false,
              top: false,
              child: Scaffold(
                backgroundColor: Theme.of(context).colorScheme.onSurface,
                bottomNavigationBar: Padding(
                  padding: EdgeInsetsDirectional.only(bottom: height! / 50.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      currentIndex == 2
                          ? const SizedBox.shrink()
                          : ButtonContainer(
                              color: Theme.of(context).colorScheme.onSurface,
                              height: height,
                              width: width,
                              text: UiUtils.getTranslatedLabel(
                                  context, skipLabel),
                              top: 0,
                              bottom: 0,
                              start: width! / 40.0,
                              end: width! / 40.0,
                              status: false,
                              borderColor:
                                  Theme.of(context).colorScheme.onSurface,
                              textColor:
                                  Theme.of(context).colorScheme.onPrimary,
                              onPressed: () {
                                _pageController.jumpToPage(2);
                              },
                            ),
                      const Spacer(),
                      SizedBox(
                        width: width! / 2.2,
                        child: ButtonContainer(
                          color: Theme.of(context).colorScheme.primary,
                          height: height,
                          width: width,
                          text: currentIndex == 2
                              ? UiUtils.getTranslatedLabel(
                                  context, getStartedLabel)
                              : UiUtils.getTranslatedLabel(context, nextLabel),
                          top: 0,
                          bottom: 0,
                          start: width! / 40.0,
                          end: width! / 40.0,
                          status: false,
                          borderColor: Theme.of(context).colorScheme.surface,
                          textColor: Theme.of(context).colorScheme.onPrimary,
                          onPressed: () {
                            if (currentIndex == 2) {
                              context
                                  .read<SettingsCubit>()
                                  .changeShowIntroSlider();
                              Navigator.of(context).pushReplacementNamed(
                                  Routes.login,
                                  arguments: {'from': 'splash'});
                            } else {
                              if (currentIndex == 0) {
                                _pageController.jumpToPage(1);
                              } else {
                                _pageController.jumpToPage(2);
                              }
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                body: SizedBox(
                  width: width,
                  height: height,
                  child: Stack(
                    children: <Widget>[
                      Container(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withValues(alpha: 0.12),
                          height: height! / 1.6),
                      _slider(),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
