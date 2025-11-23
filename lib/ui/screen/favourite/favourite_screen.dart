import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:erestroSingleVender/cubit/auth/authCubit.dart';
import 'package:erestroSingleVender/cubit/cart/getQuantityCubit.dart';
import 'package:erestroSingleVender/cubit/favourite/favouriteProductsCubit.dart';
import 'package:erestroSingleVender/cubit/settings/settingsCubit.dart';
import 'package:erestroSingleVender/ui/screen/settings/no_internet_screen.dart';
import 'package:erestroSingleVender/ui/widgets/noDataContainer.dart';
import 'package:erestroSingleVender/ui/widgets/productContainer.dart';
import 'package:erestroSingleVender/ui/widgets/simmer/productSimmer.dart';
import 'package:erestroSingleVender/utils/apiBodyParameterLabels.dart';
import 'package:erestroSingleVender/utils/constants.dart';
import 'package:erestroSingleVender/utils/labelKeys.dart';
import 'package:erestroSingleVender/utils/uiUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:erestroSingleVender/ui/styles/design.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:erestroSingleVender/utils/internetConnectivity.dart';

class FavouriteScreen extends StatefulWidget {
  const FavouriteScreen({Key? key}) : super(key: key);

  @override
  FavouriteScreenState createState() => FavouriteScreenState();
}

class FavouriteScreenState extends State<FavouriteScreen>
    with SingleTickerProviderStateMixin {
  double? width, height;
  ScrollController controllerFavouriteProduct = ScrollController();
  bool isScrollingDown = false;
  double bottomBarHeight = 75;

  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  RegExp regex = RegExp(r'([^\d]00)(?=[^\d]|$)');

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
    if (context.read<AuthCubit>().state is AuthInitial ||
        context.read<AuthCubit>().state is Unauthenticated) {
    } else {
      Future.delayed(Duration.zero, () async {
        if (mounted) {
          await context.read<FavoriteProductsCubit>().getFavoriteProducts(
              productsKey,
              context.read<SettingsCubit>().getSettings().branchId);
        }
      });
    }

    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
  }

  Widget noDataFavourite() {
    return NoDataContainer(
        image: "favourite_empty_icon",
        title: UiUtils.getTranslatedLabel(context, noFavouriteYetLabel),
        subTitle:
            UiUtils.getTranslatedLabel(context, noFavouriteYetSubTitleLabel),
        width: width!,
        height: height!);
  }

  Widget topDeal() {
    return BlocBuilder<FavoriteProductsCubit, FavoriteProductsState>(
        bloc: context.read<FavoriteProductsCubit>(),
        builder: (context, state) {
          if (state is FavoriteProductsFetchInProgress ||
              state is FavoriteProductsInitial) {
            return ProductSimmer(length: 5, width: width!, height: height!);
          }
          if (state is FavoriteProductsFetchFailure) {
            return noDataFavourite();
          }
          final favouriteProductList =
              (state as FavoriteProductsFetchSuccess).favoriteProducts;
          if (favouriteProductList.isEmpty) {
            return noDataFavourite();
          }

          return Padding(
            padding: EdgeInsetsDirectional.only(
                top: height! / 60.0, bottom: height! / 15.0),
            child: ListView.builder(
                shrinkWrap: true,
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: favouriteProductList.length,
                itemBuilder: (BuildContext context, index) {
                  double price = double.parse(
                      favouriteProductList[index].variants![0].specialPrice!);
                  if (price == 0) {
                    price = double.parse(
                        favouriteProductList[index].variants![0].price!);
                  }

                  double off = 0;
                  if (favouriteProductList[index].variants![0].specialPrice! !=
                      "0") {
                    off = (double.parse(favouriteProductList[index]
                                .variants![0]
                                .price!) -
                            double.parse(favouriteProductList[index]
                                .variants![0]
                                .specialPrice!))
                        .toDouble();
                    off = off *
                        100 /
                        double.parse(
                                favouriteProductList[index].variants![0].price!)
                            .toDouble();
                  }
                  return BlocProvider(
                    create: (context) => GetQuantityCubit(),
                    child: ProductContainer(
                        productDetails: favouriteProductList[index],
                        height: height!,
                        width: width!,
                        price: price,
                        off: off,
                        productList: favouriteProductList,
                        index: index),
                  );
                }),
          );
        });
  }

  Future<void> refreshTopDealList() async {
    if (context.read<AuthCubit>().state is AuthInitial ||
        context.read<AuthCubit>().state is Unauthenticated) {
    } else {
      await context.read<FavoriteProductsCubit>().getFavoriteProducts(
          productsKey, context.read<SettingsCubit>().getSettings().branchId);
    }
  }

  @override
  void dispose() {
    controllerFavouriteProduct.dispose();

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
          : DefaultTabController(
              length: 2,
              child: Scaffold(
                appBar: DesignConfig.appBar(
                    context,
                    width!,
                    UiUtils.getTranslatedLabel(context, favouriteLabel),
                    PreferredSize(
                        preferredSize: Size.zero,
                        child: const SizedBox.shrink()),
                    backButton: false),
                body: SafeArea(
                  bottom: false,
                  child: RefreshIndicator(
                    onRefresh: refreshTopDealList,
                    color: Theme.of(context).colorScheme.primary,
                    child: RefreshIndicator(
                        onRefresh: refreshTopDealList,
                        color: Theme.of(context).colorScheme.primary,
                        child:
                            (context.read<AuthCubit>().state is AuthInitial ||
                                    context.read<AuthCubit>().state
                                        is Unauthenticated)
                                ? noDataFavourite()
                                : topDeal()),
                  ),
                ),
              ),
            ),
    );
  }
}
