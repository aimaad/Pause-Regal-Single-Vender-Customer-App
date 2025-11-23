import 'dart:async';
import 'dart:math';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:erestroSingleVender/app/routes.dart';
import 'package:erestroSingleVender/cubit/settings/settingsCubit.dart';
import 'package:erestroSingleVender/cubit/systemConfig/systemConfigCubit.dart';
import 'package:erestroSingleVender/data/repositories/auth/authRepository.dart';
import 'package:erestroSingleVender/cubit/auth/authCubit.dart';
import 'package:erestroSingleVender/cubit/auth/referAndEarnCubit.dart';
import 'package:erestroSingleVender/cubit/auth/signUpCubit.dart';
import 'package:erestroSingleVender/cubit/cart/manageCartCubit.dart';
import 'package:erestroSingleVender/ui/widgets/buttomContainer.dart';
import 'package:erestroSingleVender/utils/SqliteData.dart';
import 'package:erestroSingleVender/ui/screen/settings/no_internet_screen.dart';
import 'package:erestroSingleVender/utils/constants.dart';
import 'package:erestroSingleVender/utils/labelKeys.dart';
import 'package:erestroSingleVender/utils/uiUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:erestroSingleVender/ui/styles/color.dart';
import 'package:erestroSingleVender/ui/styles/design.dart';
import 'package:erestroSingleVender/utils/string.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_messaging/firebase_messaging.dart' as fcm;

import 'package:erestroSingleVender/utils/internetConnectivity.dart';

class RegistrationScreen extends StatefulWidget {
  final String? mobileNumber, countryCode, from;
  const RegistrationScreen(
      {Key? key, this.mobileNumber, this.countryCode, this.from})
      : super(key: key);

  @override
  RegistrationScreenState createState() => RegistrationScreenState();
  static Route<dynamic> route(RouteSettings routeSettings) {
    Map arguments = routeSettings.arguments as Map;
    return CupertinoPageRoute(
        builder: (_) => BlocProvider<SignUpCubit>(
              create: (_) => SignUpCubit(AuthRepository()),
              child: RegistrationScreen(
                mobileNumber: arguments['mobileNumber'] as String,
                countryCode: arguments['countryCode'] as String,
                from: arguments['from'] as String,
              ),
            ));
  }
}

class RegistrationScreenState extends State<RegistrationScreen> {
  TextEditingController nameController = TextEditingController(text: "");
  TextEditingController emailController = TextEditingController(text: "");
  late TextEditingController phoneNumberController;
  TextEditingController friendsCodeController = TextEditingController(text: "");
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  double? width, height;
  bool obscurePassword = true, obscureConfirmPassword = true, status = false;
  var db = DatabaseHelper();
  Random rnd = Random();
  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));
  String referCode = "";

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
    phoneNumberController = TextEditingController(text: widget.mobileNumber);
    referCode = getRandomString(8);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
  }

  static Future<String> getFCMToken() async {
    try {
      return await fcm.FirebaseMessaging.instance.getToken() ?? "";
    } catch (e) {
      return "";
    }
  }

  nameField() {
    return Container(
        padding: EdgeInsetsDirectional.only(bottom: height! / 30.0),
        margin: EdgeInsets.zero,
        child: TextField(
          controller: nameController,
          cursorColor: lightFont,
          decoration: DesignConfig.inputDecorationextField(
              UiUtils.getTranslatedLabel(context, nameLabel),
              UiUtils.getTranslatedLabel(context, enterNameLabel),
              width!,
              context),
          keyboardType: TextInputType.text,
          style: const TextStyle(
            color: greayLightColor,
            fontSize: 14.0,
            fontWeight: FontWeight.w500,
          ),
        ));
  }

  emailField() {
    return Container(
        padding: EdgeInsetsDirectional.only(bottom: height! / 30.0),
        margin: EdgeInsets.zero,
        child: TextField(
          controller: emailController,
          cursorColor: lightFont,
          decoration: DesignConfig.inputDecorationextField(
              UiUtils.getTranslatedLabel(context, emailLabel),
              StringsRes.enterEmail,
              width!,
              context),
          keyboardType: TextInputType.text,
          style: const TextStyle(
            color: greayLightColor,
            fontSize: 14.0,
            fontWeight: FontWeight.w500,
          ),
        ));
  }

  phoneNumberField() {
    return Container(
        padding: EdgeInsetsDirectional.only(bottom: height! / 30.0),
        margin: EdgeInsets.zero,
        child: TextField(
          controller: phoneNumberController,
          cursorColor: lightFont,
          enabled: false,
          textInputAction: TextInputAction.done,
          decoration: DesignConfig.inputDecorationextField(
              UiUtils.getTranslatedLabel(context, phoneNumberLabel),
              UiUtils.getTranslatedLabel(context, enterPhoneNumberLabel),
              width!,
              context),
          keyboardType: TextInputType.number,
          style: const TextStyle(
            color: greayLightColor,
            fontSize: 14.0,
            fontWeight: FontWeight.w500,
          ),
        ));
  }

  friendCodeField() {
    return Container(
        padding: EdgeInsetsDirectional.only(bottom: height! / 30.0),
        margin: EdgeInsets.zero,
        child: TextField(
          controller: friendsCodeController,
          cursorColor: lightFont,
          decoration: DesignConfig.inputDecorationextField(
              UiUtils.getTranslatedLabel(context, friendsCodeLabel),
              UiUtils.getTranslatedLabel(context, enterFriendsCodeLabel),
              width!,
              context),
          keyboardType: TextInputType.text,
          style: const TextStyle(
            color: greayLightColor,
            fontSize: 14.0,
            fontWeight: FontWeight.w500,
          ),
        ));
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneNumberController.dispose();
    friendsCodeController.dispose();
    _connectivitySubscription.cancel();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    super.dispose();
  }

  Future<void> offCartAdd() async {
    List cartOffList = await db.getOffCart();

    if (cartOffList.isNotEmpty) {
      for (int i = 0; i < cartOffList.length; i++) {
        if (!mounted) return;
        context.read<ManageCartCubit>().manageCartUser(
            productVariantId: cartOffList[i]["VID"],
            isSavedForLater: "0",
            qty: cartOffList[i]["QTY"],
            addOnId: cartOffList[i]["ADDONID"].isNotEmpty
                ? cartOffList[i]["ADDONID"]
                : "",
            addOnQty: cartOffList[i]["ADDONQTY"].isNotEmpty
                ? cartOffList[i]["ADDONQTY"]
                : "",
            branchId: context.read<SettingsCubit>().getSettings().branchId);
      }
    }
  }

  navigationPageHome() async {
    await Future.delayed(
        Duration.zero,
        () => Navigator.of(context).pushNamedAndRemoveUntil(
            Routes.home, (Route<dynamic> route) => false,
            arguments: {'id': 0}));
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return BlocProvider<SignUpCubit>(
        create: (_) => SignUpCubit(AuthRepository()),
        child: Builder(
          builder: (context) => AnnotatedRegion<SystemUiOverlayStyle>(
            value: const SystemUiOverlayStyle(
              statusBarIconBrightness: Brightness.dark,
            ),
            child: _connectionStatus == connectivityCheck
                ? const NoInternetScreen()
                : Scaffold(
                    appBar: DesignConfig.appBarWihoutBackbutton(
                        context,
                        width!,
                        UiUtils.getTranslatedLabel(context, signUpLabel),
                        const PreferredSize(
                            preferredSize: Size.zero, child: SizedBox())),
                    bottomNavigationBar: BlocConsumer<ReferAndEarnCubit,
                            ReferAndEarnState>(
                        bloc: context.read<ReferAndEarnCubit>(),
                        listener: (context, state) async {
                          if (state is ReferAndEarnFailure) {
                            print(state.errorCode);

                            status = false;
                          }
                          if (state is ReferAndEarnSuccess) {
                            context.read<SignUpCubit>().signUpUser(
                                name: nameController.text.trim(),
                                email: emailController.text.trim(),
                                countryCode: widget.countryCode,
                                mobile: phoneNumberController.text.trim(),
                                friendCode: friendsCodeController.text.trim(),
                                referCode: referCode);
                            status = false;
                          }
                        },
                        builder: (context, state) {
                          return BlocConsumer<SignUpCubit, SignUpState>(
                              bloc: context.read<SignUpCubit>(),
                              listener: (context, state) async {
                                if (state is SignUpFailure) {
                                  UiUtils.setSnackBar(
                                      state.errorMessage, context, false,
                                      type: "2");
                                  status = false;
                                }
                                if (state is SignUpSuccess) {
                                  context
                                      .read<AuthCubit>()
                                      .statusUpdateAuth(state.authModel);

                                  offCartAdd().then((value) {
                                    db.clearCart();
                                    navigationPageHome();
                                  });
                                  status = false;
                                }
                              },
                              builder: (context, state) {
                                return SizedBox(
                                  width: width!,
                                  child: ButtonContainer(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    height: height,
                                    width: width,
                                    text: UiUtils.getTranslatedLabel(
                                        context, signUpLabel),
                                    top: height! / 55.0,
                                    bottom: height! / 55.0,
                                    start: width! / 20.0,
                                    end: width! / 20.0,
                                    status: status,
                                    borderColor:
                                        Theme.of(context).colorScheme.primary,
                                    textColor:
                                        Theme.of(context).colorScheme.onPrimary,
                                    onPressed: () {
                                      status = true;
                                      context
                                          .read<ReferAndEarnCubit>()
                                          .fetchReferAndEarn(referCode);
                                    },
                                  ),
                                );
                              });
                        }),
                    body: Container(
                        height: height!,
                        margin: EdgeInsetsDirectional.only(top: height! / 80.0),
                        padding: EdgeInsetsDirectional.only(
                            start: width! / 20.0,
                            end: width! / 20.0,
                            top: height! / 20.0),
                        decoration: DesignConfig.boxDecorationContainerHalf(
                            Theme.of(context).colorScheme.onSurface),
                        width: width,
                        child: Container(
                          margin: EdgeInsetsDirectional.only(
                              start: width! / 20.0,
                              end: width! / 20.0,
                              top: height! / 20.0),
                          child: SingleChildScrollView(
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  nameField(),
                                  emailField(),
                                  phoneNumberField(),
                                  (context
                                              .read<SystemConfigCubit>()
                                              .isReferEarnOn() ==
                                          "1")
                                      ? friendCodeField()
                                      : const SizedBox.shrink(),
                                ]),
                          ),
                        )),
                  ),
          ),
        ));
  }
}
