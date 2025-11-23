import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:erestroSingleVender/cubit/auth/authCubit.dart';
import 'package:erestroSingleVender/cubit/cart/getCartCubit.dart';
import 'package:erestroSingleVender/cubit/cart/getQuantityCubit.dart';
import 'package:erestroSingleVender/cubit/home/cuisine/cuisineDetailCubit.dart';
import 'package:erestroSingleVender/cubit/systemConfig/systemConfigCubit.dart';
import 'package:erestroSingleVender/data/model/search_model.dart';
import 'package:erestroSingleVender/cubit/settings/settingsCubit.dart';
import 'package:erestroSingleVender/data/model/sectionsModel.dart';
import 'package:erestroSingleVender/ui/screen/cart/cart_screen.dart';
import 'package:erestroSingleVender/ui/screen/settings/no_internet_screen.dart';
import 'package:erestroSingleVender/ui/styles/bouncing_button.dart';
import 'package:erestroSingleVender/ui/widgets/noDataContainer.dart';
import 'package:erestroSingleVender/ui/widgets/productContainer.dart';
import 'package:erestroSingleVender/ui/widgets/simmer/bottomCartSimmer.dart';
import 'package:erestroSingleVender/ui/widgets/simmer/productSimmer.dart';
import 'package:erestroSingleVender/utils/constants.dart';
import 'package:erestroSingleVender/utils/labelKeys.dart';
import 'package:erestroSingleVender/utils/uiUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:erestroSingleVender/ui/styles/color.dart';
import 'package:erestroSingleVender/ui/styles/design.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:erestroSingleVender/utils/internetConnectivity.dart';

class CuisineDetailScreen extends StatefulWidget {
  final String? categoryId, name;
  const CuisineDetailScreen({Key? key, this.categoryId, this.name})
      : super(key: key);

  @override
  CuisineDetailScreenState createState() => CuisineDetailScreenState();
  static Route<dynamic> route(RouteSettings routeSettings) {
    Map arguments = routeSettings.arguments as Map;
    return CupertinoPageRoute(
        builder: (_) => BlocProvider<CuisineDetailCubit>(
              create: (_) => CuisineDetailCubit(),
              child: CuisineDetailScreen(
                  categoryId: arguments['categoryId'] as String,
                  name: arguments['name'] as String),
            ));
  }
}

class CuisineDetailScreenState extends State<CuisineDetailScreen> {
  TextEditingController searchController = TextEditingController(text: "");
  double? width, height;
  ScrollController controller = ScrollController();
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  String? cuisineLength = "";
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
    controller.addListener(scrollListener);
    Future.delayed(Duration.zero, () {
      fetchCuisineDetailApi();
    });
    cartApi();
    super.initState();
  }

  cartApi() {
    if (context.read<AuthCubit>().state is AuthInitial ||
        context.read<AuthCubit>().state is Unauthenticated) {
    } else {
      context.read<GetCartCubit>().getCartUser(
          branchId: context.read<SettingsCubit>().getSettings().branchId);
    }
  }

  fetchCuisineDetailApi() {
    context.read<CuisineDetailCubit>().fetchCuisineDetail(
        perPage,
        widget.categoryId!,
        context.read<AuthCubit>().getId(),
        context.read<SettingsCubit>().getSettings().branchId);
  }

  scrollListener() {
    if (controller.position.maxScrollExtent == controller.offset) {
      if (context.read<CuisineDetailCubit>().hasMoreData()) {
        context.read<CuisineDetailCubit>().fetchMoreCuisineDetailData(
            perPage,
            widget.categoryId!,
            context.read<AuthCubit>().getId(),
            context.read<SettingsCubit>().getSettings().branchId);
      }
    }
  }

  Widget noDataSection() {
    return NoDataContainer(
        image: "no_data",
        title: UiUtils.getTranslatedLabel(context, noSectionYetLabel),
        subTitle:
            UiUtils.getTranslatedLabel(context, noSectionYetSubTitleLabel),
        width: width!,
        height: height!);
  }

  Widget cuisineDetail() {
    return BlocConsumer<CuisineDetailCubit, CuisineDetailState>(
        bloc: context.read<CuisineDetailCubit>(),
        listener: (context, state) {},
        builder: (context, state) {
          if (state is CuisineDetailProgress || state is CuisineDetailInitial) {
            return ProductSimmer(length: 5, width: width!, height: height!);
          }
          if (state is CuisineDetailFailure) {
            return Center(
              child: noDataSection(),
            );
          }
          final cuisineDetailList =
              (state as CuisineDetailSuccess).cuisineDetailList;
          cuisineLength = cuisineDetailList.length.toString();
          final hasMore = state.hasMore;
          return ListView.builder(
              shrinkWrap: true,
              controller: controller,
              physics: const BouncingScrollPhysics(),
              itemCount: cuisineDetailList.length,
              itemBuilder: (BuildContext context, index) {
                ProductDetails dataItem = cuisineDetailList[index];
                double price =
                    double.parse(dataItem.variants![0].specialPrice!);
                if (price == 0) {
                  price = double.parse(dataItem.variants![0].price!);
                }
                double off = 0;
                if (dataItem.variants![0].specialPrice! != "0") {
                  off = (double.parse(dataItem.variants![0].price!) -
                          double.parse(dataItem.variants![0].specialPrice!))
                      .toDouble();
                  off = off *
                      100 /
                      double.parse(dataItem.variants![0].price!).toDouble();
                }
                return hasMore &&
                        cuisineDetailList.isEmpty &&
                        index == (cuisineDetailList.length - 1)
                    ? Center(
                        child: CircularProgressIndicator(
                            color: Theme.of(context).colorScheme.primary))
                    : BlocProvider(
                        create: (context) => GetQuantityCubit(),
                        child: ProductContainer(
                            productDetails: cuisineDetailList[index],
                            height: height!,
                            width: width!,
                            price: price,
                            off: off,
                            productList: cuisineDetailList,
                            index: index,
                            from: "cuisine"),
                      );
              });
        });
  }

  Widget searchData() {
    return Container(
        height: height! / 25.2,
        margin: EdgeInsetsDirectional.only(
            top: height! / 40.0, bottom: height! / 40.0, start: width! / 20.0),
        child: ListView.builder(
            shrinkWrap: true,
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: searchList.length,
            scrollDirection: Axis.horizontal,
            itemBuilder: (BuildContext context, index) {
              return Container(
                  padding: EdgeInsetsDirectional.only(
                      start: width! / 20.0,
                      top: height! / 99.0,
                      end: width! / 20.0,
                      bottom: height! / 99.0),
                  margin: EdgeInsetsDirectional.only(end: width! / 20.0),
                  decoration: DesignConfig.boxDecorationContainerBorder(
                      lightFont, Theme.of(context).colorScheme.onSurface, 5.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(searchList[index].title!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.onSecondary,
                              fontSize: 10,
                              fontWeight: FontWeight.w500)),
                      const SizedBox(width: 8.0),
                      SvgPicture.asset(DesignConfig.setSvgPath("cancel_icon"),
                          width: 10, height: 10),
                    ],
                  ));
            }));
  }

  Future<void> refreshList() async {
    fetchCuisineDetailApi();
  }

  @override
  void dispose() {
    searchController.dispose();
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
              appBar: DesignConfig.appBar(
                  context,
                  width,
                  widget.name!,
                  const PreferredSize(
                      preferredSize: Size.zero, child: SizedBox())),
              bottomNavigationBar:
                  BlocBuilder<AuthCubit, AuthState>(builder: (context, state) {
                return (context.read<AuthCubit>().state is AuthInitial ||
                        context.read<AuthCubit>().state is Unauthenticated)
                    ? BlocConsumer<SettingsCubit, SettingsState>(
                        bloc: context.read<SettingsCubit>(),
                        listener: (context, state) {},
                        builder: (context, state) {
                          return (context.read<AuthCubit>().state
                                          is AuthInitial ||
                                      context.read<AuthCubit>().state
                                          is Unauthenticated) &&
                                  (state.settingsModel!.cartCount == "0" ||
                                      state.settingsModel!.cartCount == "" ||
                                      state.settingsModel!.cartCount ==
                                          "0.0") &&
                                  (state.settingsModel!.cartTotal == "0" ||
                                      state.settingsModel!.cartTotal == "" ||
                                      state.settingsModel!.cartTotal == "0.0" ||
                                      state.settingsModel!.cartTotal == "0.00")
                              ? const SizedBox.shrink()
                              : Bouncing(
                                  onPress: () {
                                    clearAll();
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            const CartScreen(
                                                from: "restaurantDetail"),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    margin: EdgeInsetsDirectional.only(
                                        start: width! / 40.0,
                                        end: width! / 40.0,
                                        bottom: height! / 40.0),
                                    width: width,
                                    padding: EdgeInsetsDirectional.only(
                                        top: height! / 55.0,
                                        bottom: height! / 55.0,
                                        start: width! / 20.0,
                                        end: width! / 20.0),
                                    decoration:
                                        DesignConfig.boxDecorationContainer(
                                            Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            100.0),
                                    child: Row(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Text(
                                                "${state.settingsModel!.cartCount} ${UiUtils.getTranslatedLabel(context, itemTagLabel)} | ",
                                                textAlign: TextAlign.center,
                                                maxLines: 1,
                                                style: TextStyle(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onPrimary,
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.w500)),
                                            Text(
                                                context
                                                                .read<
                                                                    SystemConfigCubit>()
                                                                .getCurrency() +
                                                            state.settingsModel!
                                                                .cartTotal
                                                                .toString() ==
                                                        ""
                                                    ? "0"
                                                    : double.parse(state.settingsModel!
                                                            .cartTotal
                                                            .toString())
                                                        .toStringAsFixed(2),
                                                textAlign: TextAlign.center,
                                                maxLines: 1,
                                                style:
                                                    TextStyle(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .onPrimary,
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w700)),
                                          ],
                                        ),
                                        const Spacer(),
                                        InkWell(
                                            onTap: () {},
                                            child: Text(
                                                UiUtils.getTranslatedLabel(
                                                    context, viewCartLabel),
                                                textAlign: TextAlign.center,
                                                maxLines: 1,
                                                style: TextStyle(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onPrimary,
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.w500))),
                                      ],
                                    ),
                                  ),
                                );
                        })
                    : BlocConsumer<GetCartCubit, GetCartState>(
                        bloc: context.read<GetCartCubit>(),
                        listener: (context, state) {},
                        builder: (context, state) {
                          if (state is GetCartProgress ||
                              state is GetCartInitial) {
                            return Container(
                                alignment: Alignment.center,
                                height: height! / 20.0,
                                child: BottomCartSimmer(
                                    width: width!, height: height!));
                          }
                          if (state is GetCartFailure) {
                            return const SizedBox.shrink();
                          }
                          final cartList = (state as GetCartSuccess).cartModel;
                          var sum = 0;
                          final currentCartModel =
                              context.read<GetCartCubit>().getCartModel();
                          if (currentCartModel.data != null) {
                            for (int i = 0;
                                i < currentCartModel.data!.length;
                                i++) {
                              if (currentCartModel.data![i].qty != null) {
                                sum +=
                                    int.parse(currentCartModel.data![i].qty!);
                              }
                            }
                          }

                          return cartList.data == null || cartList.data!.isEmpty
                              ? const SizedBox.shrink()
                              : Bouncing(
                                  onPress: () {
                                    clearAll();
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            const CartScreen(from: "cuision"),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    margin: EdgeInsetsDirectional.only(
                                        start: width! / 40.0,
                                        end: width! / 40.0,
                                        bottom: height! / 40.0),
                                    width: width,
                                    padding: EdgeInsetsDirectional.only(
                                        top: height! / 55.0,
                                        bottom: height! / 55.0,
                                        start: width! / 20.0,
                                        end: width! / 20.0),
                                    decoration:
                                        DesignConfig.boxDecorationContainer(
                                            Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            100.0),
                                    child: Row(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Text(
                                                "$sum ${UiUtils.getTranslatedLabel(context, itemTagLabel)} | ",
                                                textAlign: TextAlign.center,
                                                maxLines: 1,
                                                style: TextStyle(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onPrimary,
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.w500)),
                                            Text(
                                                context
                                                        .read<
                                                            SystemConfigCubit>()
                                                        .getCurrency() +
                                                    (double.parse(cartList
                                                            .subTotal
                                                            .toString()))
                                                        .toStringAsFixed(2),
                                                textAlign: TextAlign.center,
                                                maxLines: 1,
                                                style: TextStyle(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onPrimary,
                                                    fontSize: 13,
                                                    fontWeight:
                                                        FontWeight.w700)),
                                          ],
                                        ),
                                        const Spacer(),
                                        InkWell(
                                            onTap: () {},
                                            child: Text(
                                                UiUtils.getTranslatedLabel(
                                                    context, viewCartLabel),
                                                textAlign: TextAlign.center,
                                                maxLines: 1,
                                                style: TextStyle(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onPrimary,
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.w500))),
                                      ],
                                    ),
                                  ),
                                );
                        });
              }),
              body: RefreshIndicator(
                  onRefresh: refreshList,
                  color: Theme.of(context).colorScheme.primary,
                  child: cuisineDetail()),
            ),
    );
  }
}
