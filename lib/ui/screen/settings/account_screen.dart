import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:erestroSingleVender/app/routes.dart';
import 'package:erestroSingleVender/cubit/auth/authCubit.dart';
import 'package:erestroSingleVender/cubit/systemConfig/systemConfigCubit.dart';
import 'package:erestroSingleVender/ui/screen/settings/no_internet_screen.dart';
import 'package:erestroSingleVender/ui/screen/favourite/favourite_screen.dart';
import 'package:erestroSingleVender/ui/screen/settings/refer_and_earn_screen.dart';
import 'package:erestroSingleVender/ui/styles/dashLine.dart';
import 'package:erestroSingleVender/ui/widgets/LanguageDialog.dart';
import 'package:erestroSingleVender/ui/widgets/customDialog.dart';
import 'package:erestroSingleVender/utils/apiBodyParameterLabels.dart';
import 'package:erestroSingleVender/utils/constants.dart';
import 'package:erestroSingleVender/utils/labelKeys.dart';
import 'package:erestroSingleVender/utils/uiUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:erestroSingleVender/ui/styles/color.dart';
import 'package:erestroSingleVender/ui/styles/design.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:erestroSingleVender/utils/internetConnectivity.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:share_plus/share_plus.dart';

class AccountScreen extends StatefulWidget {
  final Function? bottomStatus;
  const AccountScreen({Key? key, this.bottomStatus}) : super(key: key);

  @override
  AccountScreenState createState() => AccountScreenState();
}

class AccountScreenState extends State<AccountScreen>
    with TickerProviderStateMixin {
  double? width, height;
  var size;
  bool isScrollingDown = false;
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

  bottomStatusUpdate() {
    setState(() {
      widget.bottomStatus!(0);
    });
  }

  profileData(Size size, String? image, state) {
    return Container(
      width: width,
      decoration: DesignConfig.boxDecorationContainer(
          Theme.of(context).colorScheme.onSurface, 8.0),
      height: height! / 11,
      margin: EdgeInsetsDirectional.only(
          top: height! / 50, start: width! / 20.0, end: width! / 20.0),
      padding:
          EdgeInsetsDirectional.only(start: width! / 40.0, end: width! / 40.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsetsDirectional.only(end: width! / 40.0),
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(5.0)),
              child: (state is AuthInitial || state is Unauthenticated)
                  ? DesignConfig.imageWidgets(
                      context.read<AuthCubit>().getProfile(), 57, 57, "1")
                  : DesignConfig.imageWidgets(
                      state.authModel.image, 57, 57, "1"),
            ),
          ),
          Expanded(
              child: (context.read<AuthCubit>().state is AuthInitial ||
                      context.read<AuthCubit>().state is Unauthenticated)
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                          Text(
                              UiUtils.getTranslatedLabel(
                                  context, yourProfileLabel),
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onSecondary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500)),
                          const SizedBox(height: 2.0),
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text:
                                      "${UiUtils.getTranslatedLabel(context, loginLabel)} ",
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      Navigator.of(context)
                                          .pushNamed(Routes.login, arguments: {
                                        'from': 'profile'
                                      }).then((value) {
                                        appDataRefresh(context);
                                      });
                                    },
                                ),
                                TextSpan(
                                  text: UiUtils.getTranslatedLabel(context,
                                      loginOrSignUpToViewYourCompleteProfileLabel),
                                  style: const TextStyle(
                                      color: greayLightColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          )
                        ])
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(state.authModel.username!,
                            textAlign: TextAlign.start,
                            style: TextStyle(
                                color:
                                    Theme.of(context).colorScheme.onSecondary,
                                fontSize: 16,
                                fontWeight: FontWeight.w500)),
                        const SizedBox(height: 5.0),
                        Text(state.authModel.email!,
                            textAlign: TextAlign.start,
                            style: const TextStyle(
                                color: greayLightColor,
                                fontSize: 12,
                                fontWeight: FontWeight.normal)),
                      ],
                    )),
          Align(alignment: Alignment.topRight, child: editProfileButton()),
        ],
      ),
    );
  }

  Widget editProfileButton() {
    return BlocBuilder<AuthCubit, AuthState>(builder: (context, state) {
      return (context.read<AuthCubit>().state is AuthInitial ||
              context.read<AuthCubit>().state is Unauthenticated)
          ? const SizedBox.shrink()
          : InkWell(
              onTap: () {
                Navigator.of(context)
                    .pushNamed(Routes.profile, arguments: false);
              },
              child: Container(
                  height: 24,
                  width: 24,
                  margin: EdgeInsetsDirectional.only(top: height! / 80.0),
                  decoration: DesignConfig.boxDecorationContainer(
                      Theme.of(context).colorScheme.primary, 4),
                  child: SvgPicture.asset(DesignConfig.setSvgPath("pro_edit"),
                      width: 14.0,
                      height: 13.99,
                      colorFilter: ColorFilter.mode(
                          Theme.of(context).colorScheme.onPrimary,
                          BlendMode.srcIn))),
            );
    });
  }

  Widget arrowTile({String? title, VoidCallback? onPressed, String? image}) {
    return InkWell(
      onTap: onPressed,
      child: ListTile(
        dense: true,
        contentPadding: EdgeInsets.zero,
        visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
        leading: CircleAvatar(
            radius: 18.0,
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: SvgPicture.asset(DesignConfig.setSvgPath(image!),
                width: 16.0,
                height: 16.0,
                colorFilter: ColorFilter.mode(
                    Theme.of(context).colorScheme.onPrimary, BlendMode.srcIn))),
        title: Text(title!,
            textAlign: TextAlign.start,
            style: TextStyle(
                color: Theme.of(context)
                    .colorScheme
                    .onPrimary
                    .withValues(alpha: 0.76),
                fontSize: 14,
                fontWeight: FontWeight.w500)),
        trailing: IconButton(
            onPressed: onPressed,
            padding: EdgeInsetsDirectional.only(start: height! / 40.0),
            icon: Icon(Icons.arrow_forward_ios,
                size: 10, color: Theme.of(context).colorScheme.onSecondary)),
      ),
    );
  }

  Widget topTabData(AuthState state) {
    return (context.read<AuthCubit>().state is AuthInitial ||
            context.read<AuthCubit>().state is Unauthenticated)
        ? const SizedBox.shrink()
        : Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                    Navigator.of(context)
                        .pushNamed(Routes.order, arguments: false);
                  },
                  child: Container(
                      decoration: DesignConfig.boxDecorationContainer(
                          Theme.of(context).colorScheme.onSurface, 8.0),
                      padding: const EdgeInsetsDirectional.all(10.0),
                      margin: EdgeInsetsDirectional.only(
                          bottom: height! / 80.0,
                          start: width! / 20.0,
                          end: width! / 70.0),
                      child: Column(children: [
                        CircleAvatar(
                            radius: 18.0,
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            child: SvgPicture.asset(
                                DesignConfig.setSvgPath("my_order_icon"),
                                width: 16.0,
                                height: 16.0,
                                colorFilter: ColorFilter.mode(
                                    Theme.of(context).colorScheme.onPrimary,
                                    BlendMode.srcIn))),
                        SizedBox(height: height! / 99.0),
                        Text(UiUtils.getTranslatedLabel(context, myOrderLabel),
                            textAlign: TextAlign.start,
                            style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimary
                                    .withValues(alpha: 0.76),
                                fontSize: 14,
                                fontWeight: FontWeight.w500)),
                      ])),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () {
                    Navigator.of(context)
                        .pushNamed(Routes.deliveryAddress, arguments: false);
                  },
                  child: Container(
                      decoration: DesignConfig.boxDecorationContainer(
                          Theme.of(context).colorScheme.onSurface, 8.0),
                      padding: const EdgeInsetsDirectional.all(10.0),
                      margin: EdgeInsetsDirectional.only(
                          bottom: height! / 80.0,
                          start: width! / 70.0,
                          end: width! / 20.0),
                      child: Column(children: [
                        CircleAvatar(
                            radius: 18.0,
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            child: SvgPicture.asset(
                                DesignConfig.setSvgPath("address_icon"),
                                width: 16.0,
                                height: 16.0,
                                colorFilter: ColorFilter.mode(
                                    Theme.of(context).colorScheme.onPrimary,
                                    BlendMode.srcIn))),
                        SizedBox(height: height! / 99.0),
                        Text(UiUtils.getTranslatedLabel(context, addressLabel),
                            textAlign: TextAlign.start,
                            style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimary
                                    .withValues(alpha: 0.76),
                                fontSize: 14,
                                fontWeight: FontWeight.w500)),
                      ])),
                ),
              ),
            ],
          );
  }

  Widget bottomTabData() {
    return Container(
      margin: EdgeInsetsDirectional.only(
          start: width! / 20.0,
          end: width! / 20.0,
          top: height! / 60.0,
          bottom: height! / 80.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: () {
              Navigator.of(context).pushNamed(Routes.appSettings,
                  arguments: termsAndConditionsKey);
            },
            child: Row(children: [
              Text(UiUtils.getTranslatedLabel(context, termAndConditionLabel),
                  textAlign: TextAlign.start,
                  style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onPrimary
                          .withValues(alpha: 0.76),
                      fontSize: 12,
                      fontWeight: FontWeight.w500)),
              SizedBox(height: height! / 80.0),
              Icon(Icons.arrow_forward_ios,
                  size: 11,
                  color: Theme.of(context)
                      .colorScheme
                      .onPrimary
                      .withValues(alpha: 0.76))
            ]),
          ),
          InkWell(
            onTap: () {
              Navigator.of(context)
                  .pushNamed(Routes.appSettings, arguments: privacyPolicyKey);
            },
            child: Row(children: [
              Text(UiUtils.getTranslatedLabel(context, privacyPolicyLabel),
                  textAlign: TextAlign.start,
                  style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onPrimary
                          .withValues(alpha: 0.76),
                      fontSize: 12,
                      fontWeight: FontWeight.w500)),
              SizedBox(height: height! / 80.0),
              Icon(Icons.arrow_forward_ios,
                  size: 11,
                  color: Theme.of(context)
                      .colorScheme
                      .onPrimary
                      .withValues(alpha: 0.76))
            ]),
          ),
          InkWell(
            onTap: () {
              Navigator.of(context).pushNamed(Routes.faqs);
            },
            child: Row(children: [
              Text(UiUtils.getTranslatedLabel(context, faqsLabel),
                  textAlign: TextAlign.start,
                  style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onPrimary
                          .withValues(alpha: 0.76),
                      fontSize: 12,
                      fontWeight: FontWeight.w500)),
              SizedBox(height: height! / 80.0),
              Icon(Icons.arrow_forward_ios,
                  size: 11,
                  color: Theme.of(context)
                      .colorScheme
                      .onPrimary
                      .withValues(alpha: 0.76))
            ]),
          ),
        ],
      ),
    );
  }

  Widget transactionData(AuthState state) {
    return arrowTile(
        image: "pro_th",
        title: UiUtils.getTranslatedLabel(context, transactionLabel),
        onPressed: () {
          if (context.read<AuthCubit>().state is AuthInitial ||
              context.read<AuthCubit>().state is Unauthenticated) {
            Navigator.of(context).pushNamed(Routes.login,
                arguments: {'from': 'transaction'}).then((value) {
              appDataRefresh(context);
            });
            return;
          } else {
            Navigator.of(context).pushNamed(Routes.transaction);
          }
        });
  }

  Widget walletData(AuthState state) {
    return arrowTile(
        image: "pro_wh",
        title: UiUtils.getTranslatedLabel(context, walletLabel),
        onPressed: () {
          if (context.read<AuthCubit>().state is AuthInitial ||
              context.read<AuthCubit>().state is Unauthenticated) {
            Navigator.of(context).pushNamed(Routes.login,
                arguments: {'from': 'wallet'}).then((value) {
              appDataRefresh(context);
            });
            return;
          } else {
            Navigator.of(context).pushNamed(Routes.wallet);
          }
        });
  }

  Widget favouriteData(AuthState state) {
    return arrowTile(
        image: "favourite_icon",
        title: UiUtils.getTranslatedLabel(context, favouriteLabel),
        onPressed: () {
          Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => const FavouriteScreen(),
            ),
          );
        });
  }

  Widget aboutUsData() {
    return arrowTile(
        image: "pro_aboutus",
        title: UiUtils.getTranslatedLabel(context, aboutUsLabel),
        onPressed: () {
          Navigator.of(context)
              .pushNamed(Routes.appSettings, arguments: aboutUsKey);
        });
  }

  Widget contactUsData() {
    return arrowTile(
        image: "pro_contact_us",
        title: UiUtils.getTranslatedLabel(context, contactUsLabel),
        onPressed: () {
          Navigator.of(context)
              .pushNamed(Routes.appSettings, arguments: contactUsKey);
        });
  }

  Widget helpAndSupport() {
    return arrowTile(
        image: "pro_customersupport",
        title: UiUtils.getTranslatedLabel(context, helpAndSupportLabel),
        onPressed: () {
          Navigator.of(context).pushNamed(Routes.ticket);
        });
  }

  Widget referAndEarn(AuthState state) {
    return arrowTile(
        image: "pro_earn",
        title: UiUtils.getTranslatedLabel(context, referralAndEarnCodeLabel),
        onPressed: () {
          if (context.read<AuthCubit>().state is AuthInitial ||
              context.read<AuthCubit>().state is Unauthenticated) {
            Navigator.of(context).pushNamed(Routes.login,
                arguments: {'from': 'referAndEarn'}).then((value) {
              appDataRefresh(context);
            });
            return;
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => const ReferAndEarnScreen(),
              ),
            );
          }
        });
  }

  Widget deleteYourAccount(AuthState state) {
    return arrowTile(
        image: "pro_delete",
        title: UiUtils.getTranslatedLabel(context, deleteYourAccountLabel),
        onPressed: () {
          if (context.read<AuthCubit>().state is AuthInitial ||
              context.read<AuthCubit>().state is Unauthenticated) {
            Navigator.of(context).pushNamed(Routes.login,
                arguments: {'from': 'deleteYourAccount'}).then((value) {
              appDataRefresh(context);
            });
            return;
          } else {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return CustomDialog(
                      title: UiUtils.getTranslatedLabel(
                          context, deleteYourAccountLabel),
                      subtitle: UiUtils.getTranslatedLabel(
                          context, deleteYourAccountSubTitleLabel),
                      width: width!,
                      height: height!,
                      from: UiUtils.getTranslatedLabel(context, deleteLabel));
                });
          }
        });
  }

  // Widget rateUs() {
  //   return arrowTile(
  //       image: "pro_rateus",
  //       title: UiUtils.getTranslatedLabel(context, rateUsLabel),
  //       onPressed: () {
  //         LaunchReview.launch(
  //           androidAppId: extractPackageName(
  //               context.read<SystemConfigCubit>().getAppLink()),
  //           iOSAppId:
  //               extractAppId(context.read<SystemConfigCubit>().getAppLink()),
  //         );
  //       });
  // }

  Widget rateUs(BuildContext context) {
    final inAppReview = InAppReview.instance;
    return arrowTile(
      image: "pro_rateus",
      title: UiUtils.getTranslatedLabel(context, rateUsLabel),
      onPressed: () async {
        // Try the in-app review prompt first (quota-limited)
        if (await inAppReview.isAvailable()) {
          await inAppReview.requestReview();
        }
        // Always also deep-link to the store listing:
        final appLink = context.read<SystemConfigCubit>().getAppLink();
        final iosId = extractAppId(appLink);
        await inAppReview.openStoreListing(
          appStoreId: iosId, // required on iOS/macOS
          // On Android, openStoreListing() uses your app’s packageName under the hood,
          // so you don’t need to pass androidAppId explicitly.
        );
      },
    );
  }

  Widget languageChange() {
    return arrowTile(
        image: "pro_translate",
        title: UiUtils.getTranslatedLabel(context, languageChangeLabel),
        onPressed: () {
          showModalBottomSheet(
              useSafeArea: true,
              isDismissible: true,
              backgroundColor: Theme.of(context).colorScheme.onSurface,
              shape: DesignConfig.setRoundedBorderCard(0.0, 0.0, 16.0, 16.0),
              isScrollControlled: true,
              enableDrag: true,
              showDragHandle: true,
              context: context,
              builder: (context) {
                return StatefulBuilder(builder: (BuildContext context,
                    void Function(void Function()) setStater) {
                  return Container(
                      padding: EdgeInsetsDirectional.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom,
                          start: width! / 20.0,
                          end: width! / 20.0),
                      child: LanguageChangeDialog(
                          title: UiUtils.getTranslatedLabel(
                              context, languageChangeLabel),
                          subtitle: UiUtils.getTranslatedLabel(
                              context, areYouSureYouWantToLogoutLabel),
                          width: width!,
                          height: height!,
                          from: UiUtils.getTranslatedLabel(
                              context, logoutLabel)));
                });
              });
        });
  }

  Widget logInAndLogoutButton() {
    return GestureDetector(
      onTap: () {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return CustomDialog(
                  title: UiUtils.getTranslatedLabel(context, logoutLabel),
                  subtitle: UiUtils.getTranslatedLabel(
                      context, areYouSureYouWantToLogoutLabel),
                  width: width!,
                  height: height!,
                  from: UiUtils.getTranslatedLabel(context, logoutLabel));
            });
      },
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Theme.of(context)
                    .colorScheme
                    .onPrimary
                    .withValues(alpha: 0.1),
                offset: Offset(0, 2.0),
                blurRadius: 8.0,
              )
            ],
            borderRadius: BorderRadius.circular(8),
            color: Theme.of(context).colorScheme.onSurface),
        width: width! / 3.0,
        height: height! / 22,
        margin: EdgeInsetsDirectional.only(
            start: width! / 40.0,
            end: width! / 40.0,
            bottom: height! / 40.0,
            top: height! / 40.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.power_settings_new,
                color: Theme.of(context).colorScheme.error),
            SizedBox(width: width! / 80.0),
            Text(UiUtils.getTranslatedLabel(context, logoutLabel),
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.error)),
          ],
        ),
      ),
    );
  }

  Widget share() {
    return arrowTile(
        image: "pro_share",
        title: UiUtils.getTranslatedLabel(context, shareLabel),
        onPressed: () async {
          try {
            // Use screen dimensions to position the share dialog at the bottom
            final shareText =
                "$shareAndroidAppLink\n${context.read<SystemConfigCubit>().getAppLink()}\n";

            final box = context.findRenderObject() as RenderBox?;

            await SharePlus.instance.share(
              ShareParams(
                text: shareText,
                sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
              ),
            );
          } catch (e) {
            UiUtils.setSnackBar(e.toString(), context, false, type: "2");
          }
        });
  }

  Widget line() {
    return Padding(
      padding: EdgeInsetsDirectional.only(
          top: height! / 60.0, bottom: height! / 60.0),
      child: DashLineView(
        fillRate: 0.5,
        direction: Axis.horizontal,
      ),
    );
  }

  Widget listHederTitle(String? title) {
    return Padding(
      padding: EdgeInsetsDirectional.only(
          top: height! / 80.0, start: width! / 20.0, bottom: height! / 80.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
              decoration: DesignConfig.boxDecorationContainer(
                  Theme.of(context).colorScheme.primary, 2),
              height: height! / 40.0,
              width: width! / 80.0),
          SizedBox(width: width! / 80.0),
          Expanded(
            child: Text(UiUtils.getTranslatedLabel(context, title!),
                textAlign: TextAlign.start,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget profile(AuthState state) {
    return Container(
        margin: EdgeInsetsDirectional.only(top: height! / 15.0),
        width: width,
        height: height!,
        child: SingleChildScrollView(
            child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: height! / 17.0),
            topTabData(state),
            (context.read<AuthCubit>().state is AuthInitial ||
                    context.read<AuthCubit>().state is Unauthenticated)
                ? const SizedBox.shrink()
                : Container(
                    decoration: DesignConfig.boxDecorationContainer(
                        Theme.of(context).colorScheme.onSurface, 10.0),
                    padding: const EdgeInsetsDirectional.all(16.0),
                    margin: EdgeInsetsDirectional.only(
                        top: 2.0,
                        bottom: height! / 80.0,
                        start: width! / 20.0,
                        end: width! / 20.0),
                    child: Column(children: [
                      walletData(state),
                      line(),
                      transactionData(state),
                    ]),
                  ),
            listHederTitle(settingsLabel),
            Container(
                decoration: DesignConfig.boxDecorationContainer(
                    Theme.of(context).colorScheme.onSurface, 10.0),
                padding: const EdgeInsetsDirectional.all(16.0),
                margin: EdgeInsetsDirectional.only(
                    top: height! / 80.0,
                    bottom: height! / 80.0,
                    start: width! / 20.0,
                    end: width! / 20.0),
                child: Column(children: [
                  languageChange(),
                  line(),
                  aboutUsData(),
                  line(),
                  contactUsData(),
                  line(),
                  (context.read<AuthCubit>().state is AuthInitial ||
                          context.read<AuthCubit>().state is Unauthenticated)
                      ? const SizedBox.shrink()
                      : helpAndSupport(),
                  (context.read<AuthCubit>().state is AuthInitial ||
                          context.read<AuthCubit>().state is Unauthenticated)
                      ? const SizedBox.shrink()
                      : line(),
                  rateUs(context),
                  line(),
                  share(),
                  ((context.read<AuthCubit>().state is AuthInitial ||
                              context.read<AuthCubit>().state
                                  is Unauthenticated) &&
                          (context.read<SystemConfigCubit>().isReferEarnOn() ==
                              "1"))
                      ? const SizedBox.shrink()
                      : line(),
                  ((context.read<AuthCubit>().state is AuthInitial ||
                              context.read<AuthCubit>().state
                                  is Unauthenticated) &&
                          (context.read<SystemConfigCubit>().isReferEarnOn() ==
                              "1"))
                      ? const SizedBox.shrink()
                      : referAndEarn(state),
                  (context.read<AuthCubit>().state is AuthInitial ||
                              context.read<AuthCubit>().state
                                  is Unauthenticated) ||
                          (context.read<SystemConfigCubit>().getDemoMode() ==
                              "0") ||
                          context.read<AuthCubit>().getMobile() == "9876543212"
                      ? const SizedBox.shrink()
                      : line(),
                  (context.read<AuthCubit>().state is AuthInitial ||
                              context.read<AuthCubit>().state
                                  is Unauthenticated) ||
                          (context.read<SystemConfigCubit>().getDemoMode() ==
                              "0") ||
                          context.read<AuthCubit>().getMobile() == "9876543212"
                      ? const SizedBox.shrink()
                      : deleteYourAccount(state),
                ])),
            bottomTabData(),
            (context.read<AuthCubit>().state is AuthInitial ||
                    context.read<AuthCubit>().state is Unauthenticated)
                ? const SizedBox.shrink()
                : Align(
                    alignment: Alignment.center, child: logInAndLogoutButton()),
            SizedBox(height: height! / 9.0)
          ],
        )));
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
    size = MediaQuery.of(context).size;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.light,
      ),
      child: _connectionStatus == connectivityCheck
          ? const NoInternetScreen()
          : Scaffold(
              appBar: AppBar(
                leadingWidth: width! / 12.0,
                backgroundColor: Theme.of(context).colorScheme.primary,
                shadowColor: Theme.of(context).colorScheme.onSurface,
                elevation: 0,
                centerTitle: false,
                title: Text(UiUtils.getTranslatedLabel(context, myProfileLabel),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w500)),
              ),
              backgroundColor: Theme.of(context).colorScheme.surface,
              body: _connectionStatus == connectivityCheck
                  ? const NoInternetScreen()
                  : BlocBuilder<AuthCubit, AuthState>(
                      builder: (context, state) {
                      return Stack(
                        children: [
                          Container(
                              color: Theme.of(context).colorScheme.primary,
                              width: width,
                              height: height! / 14.0),
                          profile(state),
                          profileData(
                              size,
                              (state is Authenticated)
                                  ? state.authModel.image!
                                  : "",
                              state)
                        ],
                      );
                    }),
            ),
    );
  }
}
