import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:erestroSingleVender/cubit/auth/authCubit.dart';
import 'package:erestroSingleVender/cubit/cart/getCartCubit.dart';
import 'package:erestroSingleVender/cubit/settings/settingsCubit.dart';
import 'package:erestroSingleVender/cubit/systemConfig/systemConfigCubit.dart';
import 'package:erestroSingleVender/ui/screen/cart/cart_screen.dart';
import 'package:erestroSingleVender/ui/screen/favourite/favourite_screen.dart';
import 'package:erestroSingleVender/ui/screen/home/home_screen.dart';
import 'package:erestroSingleVender/ui/screen/home/menu/menu_screen.dart';
import 'package:erestroSingleVender/ui/screen/settings/account_screen.dart';
import 'package:erestroSingleVender/ui/screen/settings/maintenance_screen.dart';
import 'package:erestroSingleVender/ui/screen/settings/no_internet_screen.dart';
import 'package:erestroSingleVender/ui/styles/color.dart';
import 'package:erestroSingleVender/ui/styles/design.dart';
import 'package:erestroSingleVender/utils/SqliteData.dart';
import 'package:erestroSingleVender/utils/constants.dart';
import 'package:erestroSingleVender/utils/internetConnectivity.dart';
import 'package:erestroSingleVender/utils/labelKeys.dart';
import 'package:erestroSingleVender/utils/uiUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MainScreen extends StatefulWidget {
  static final GlobalKey<_MainScreenState> globalKey =
      GlobalKey<_MainScreenState>();
  final int? id;
  MainScreen({Key? key, this.id}) : super(key: globalKey);

  @override
  _MainScreenState createState() => _MainScreenState();
  static Route<MainScreen> route(RouteSettings routeSettings) {
    Map arguments = routeSettings.arguments as Map;
    return CupertinoPageRoute(
      builder: (_) => MainScreen(id: arguments['id'] as int),
    );
  }
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  int? selectedIndex = 0;
  late List<Widget> fragments;
  double? width, height;
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  late AnimationController navigationContainerAnimationController =
      AnimationController(
          vsync: this, duration: const Duration(milliseconds: 700));
  var db = DatabaseHelper();

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
    db.getTotalCartCount(context);

    if (widget.id != null) {
      selectedIndex = widget.id!;
    } else {
      selectedIndex = 0;
    }
    isAppMaintenance();
    fragments = [
      HomeScreen(),
      const MenuScreen(),
      const FavouriteScreen(),
      const AccountScreen(),
    ];
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  void updateTabSelection(int index, String buttonText) {
    setState(() {
      selectedIndex = index;
    });
  }

  bottomState(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  void isAppMaintenance() {
    if (context.read<SystemConfigCubit>().isAppMaintenance() == "1") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => const MaintenanceScreen(),
        ),
      );
    }
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return _connectionStatus == 'ConnectivityResult.none'
        ? const NoInternetScreen()
        : PopScope(
            canPop: selectedIndex != 0 ? false : true,
            onPopInvokedWithResult: (value, dynamic) {
              if (selectedIndex != 0) {
                setState(() {
                  selectedIndex = 0;
                });
              }
            },
            child: AnnotatedRegion<SystemUiOverlayStyle>(
              value: SystemUiOverlayStyle(
                statusBarIconBrightness:
                    Platform.isIOS ? Brightness.light : Brightness.dark,
              ),
              child: Scaffold(
                resizeToAvoidBottomInset: false,
                extendBody: true,
                backgroundColor: Colors.transparent,
                body: IndexedStack(
                  index: selectedIndex!,
                  children: fragments,
                ),
                bottomNavigationBar: BottomAppBar(
                  padding: EdgeInsetsDirectional.zero,
                  color: Theme.of(context).colorScheme.onSurface,
                  shape: CircularNotchedRectangle(), //shape of notch
                  notchMargin: 10, height: height! / 12.0,
                  clipBehavior: Clip.antiAlias,
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                        flex: 2,
                        child: DesignConfig.bottomBarTextButton(
                            context, selectedIndex!, 0, () {
                          setState(() {
                            selectedIndex = 0;
                            if (selectedIndex == 2) {
                              clearAll();
                            }
                          });
                        },
                            "home_active",
                            "home_inactive",
                            UiUtils.getTranslatedLabel(context, homeLabel),
                            EdgeInsetsDirectional.zero),
                      ),
                      Expanded(
                        flex: 3,
                        child: DesignConfig.bottomBarTextButton(
                            context, selectedIndex!, 1, () {
                          setState(() {
                            selectedIndex = 1;
                            if (selectedIndex == 2) {
                              clearAll();
                            }
                          });
                        },
                            "food_menu_active",
                            "food_menu_inactive",
                            UiUtils.getTranslatedLabel(context, menuLabel),
                            EdgeInsetsDirectional.zero),
                      ),
                      Expanded(
                        flex: 3,
                        child: DesignConfig.bottomBarTextButton(
                            context, selectedIndex!, 2, () {
                          setState(() {
                            selectedIndex = 2;
                            if (selectedIndex == 2) {
                              clearAll();
                            }
                          });
                        },
                            "wishlist_active",
                            "wishlist_inactive",
                            UiUtils.getTranslatedLabel(context, favouriteLabel),
                            EdgeInsetsDirectional.zero),
                      ),
                      Expanded(
                        flex: 2,
                        child: DesignConfig.bottomBarTextButton(
                            context, selectedIndex!, 3, () {
                          setState(() {
                            selectedIndex = 3;
                            if (selectedIndex == 2) {
                              clearAll();
                            }
                          });
                        },
                            "profile_active",
                            "profile_inactive",
                            UiUtils.getTranslatedLabel(context, profileLabel),
                            EdgeInsetsDirectional.zero),
                      ),
                    ],
                  ),
                ),
                floatingActionButton: FloatingActionButton(
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  onPressed: () {
                    clearAll();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) => const CartScreen(),
                      ),
                    );
                  },
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  elevation: 2,
                  child: Stack(
                    children: [
                      SvgPicture.asset(DesignConfig.setSvgPath("cart")),
                      (context.read<AuthCubit>().state is AuthInitial ||
                              context.read<AuthCubit>().state
                                  is Unauthenticated)
                          ? BlocConsumer<SettingsCubit, SettingsState>(
                              bloc: context.read<SettingsCubit>(),
                              listener: (context, state) {},
                              builder: (context, state) {
                                return (state.settingsModel!.cartCount
                                                    .toString() ==
                                                "0" ||
                                            state.settingsModel!.cartCount
                                                    .toString() ==
                                                "" ||
                                            state
                                                    .settingsModel!.cartCount
                                                    .toString() ==
                                                "0.0") &&
                                        (state
                                                    .settingsModel!.cartTotal
                                                    .toString() ==
                                                "0" ||
                                            state.settingsModel!.cartTotal
                                                    .toString() ==
                                                "" ||
                                            state.settingsModel!.cartTotal
                                                    .toString() ==
                                                "0.0" ||
                                            state.settingsModel!.cartTotal
                                                    .toString() ==
                                                "0.00")
                                    ? SizedBox.shrink()
                                    : Positioned.directional(
                                        textDirection:
                                            Directionality.of(context),
                                        end: 0,
                                        child: Container(
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onPrimary),
                                            child: Center(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(3),
                                                child: Text(
                                                  state.settingsModel!.cartCount
                                                      .toString(),
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                      fontSize: 8,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: white),
                                                ),
                                              ),
                                            )),
                                      );
                              },
                            )
                          : BlocConsumer<GetCartCubit, GetCartState>(
                              bloc: context.read<GetCartCubit>(),
                              listener: (context, state) {},
                              builder: (context, state) {
                                if (state is GetCartProgress ||
                                    state is GetCartInitial) {
                                  return const SizedBox();
                                }
                                if (state is GetCartFailure) {
                                  return const SizedBox.shrink();
                                }
                                if (state is GetCartSuccess) {
                                  return Positioned.directional(
                                    textDirection: Directionality.of(context),
                                    end: 0,
                                    child: Container(
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onPrimary),
                                        child: Center(
                                          child: Padding(
                                            padding: const EdgeInsets.all(3),
                                            child: Text(
                                              state.cartModel.totalQuantity
                                                  .toString(),
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                  fontSize: 8,
                                                  fontWeight: FontWeight.bold,
                                                  color: white),
                                            ),
                                          ),
                                        )),
                                  );
                                }
                                return const SizedBox.shrink();
                              })
                    ],
                  ),
                ),
                floatingActionButtonLocation:
                    FloatingActionButtonLocation.centerDocked,
              ),
            ));
  }
}
