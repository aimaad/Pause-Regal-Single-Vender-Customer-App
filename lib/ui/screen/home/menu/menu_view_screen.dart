import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:erestroSingleVender/cubit/auth/authCubit.dart';
import 'package:erestroSingleVender/cubit/cart/getCartCubit.dart';
import 'package:erestroSingleVender/cubit/cart/getQuantityCubit.dart';
import 'package:erestroSingleVender/cubit/product/productCubit.dart';
import 'package:erestroSingleVender/data/model/sectionsModel.dart';
import 'package:erestroSingleVender/cubit/settings/settingsCubit.dart';
import 'package:erestroSingleVender/ui/widgets/simmer/productSimmer.dart';
import 'package:erestroSingleVender/utils/SqliteData.dart';
import 'package:erestroSingleVender/ui/screen/settings/no_internet_screen.dart';
import 'package:erestroSingleVender/ui/widgets/productItemContainer.dart';
import 'package:erestroSingleVender/utils/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:erestroSingleVender/utils/internetConnectivity.dart';

List<GlobalKey<MenuViewScreenState>>? globalKey;

// ignore: must_be_immutable
class MenuViewScreen extends StatefulWidget {
  String categoryId, statusFoodType, costStatus, sort;
  ProductCubit? productCubit;
  MenuViewScreen(
      {Key? key,
      required this.categoryId,
      required this.statusFoodType,
      required this.costStatus,
      required this.sort,
      this.productCubit})
      : super(key: key);

  @override
  MenuViewScreenState createState() => MenuViewScreenState();
  static Route<dynamic> route(RouteSettings routeSettings) {
    Map arguments = routeSettings.arguments as Map;
    return CupertinoPageRoute(
        builder: (_) => MenuViewScreen(
              categoryId: arguments['categoryId'] as String,
              statusFoodType: arguments['statusFoodType'] as String,
              costStatus: arguments['costStatus'],
              sort: arguments['sort'] as String,
              productCubit: arguments['productCubit'] as ProductCubit,
            ));
  }
}

class MenuViewScreenState extends State<MenuViewScreen>
    with AutomaticKeepAliveClientMixin {
  double? width, height;
  TabController? tabController;
  int selectedIndex = 0;
  ScrollController controllerProduct = ScrollController();
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  var db = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    print('==key==${widget.key}');
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

    refreshList();
    controllerProduct.addListener(scrollListener);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    controllerProduct.dispose();
    super.dispose();
  }

  scrollListener() {
    if (controllerProduct.position.maxScrollExtent ==
        controllerProduct.offset) {
      if (context.read<ProductCubit>().hasMoreData()) {
        context.read<ProductCubit>().fetchMoreProductData(
            perPage,
            context.read<AuthCubit>().getId(),
            context.read<SettingsCubit>().getSettings().branchId,
            widget.categoryId,
            widget.statusFoodType,
            widget.costStatus,
            widget.sort);
      }
    }
  }

  cartApi() {
    if (context.read<AuthCubit>().state is AuthInitial ||
        context.read<AuthCubit>().state is Unauthenticated) {
    } else {
      context.read<GetCartCubit>().getCartUser(
          branchId: context.read<SettingsCubit>().getSettings().branchId);
    }
  }

  productApi() {
    context.read<ProductCubit>().fetchProduct(
        perPage,
        context.read<AuthCubit>().getId(),
        context.read<SettingsCubit>().getSettings().branchId,
        widget.categoryId,
        widget.statusFoodType,
        widget.costStatus,
        widget.sort);
  }

  Future<void> refreshList() async {
    productApi();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarIconBrightness: Brightness.light,
        ),
        child: _connectionStatus == connectivityCheck
            ? const NoInternetScreen()
            : RefreshIndicator(
                onRefresh: refreshList,
                color: Theme.of(context).colorScheme.primary,
                child: BlocConsumer<ProductCubit, ProductState>(
                    bloc: context.read<ProductCubit>(),
                    listener: (context, state) {
                      if (state is ProductFailure) {
                        print(state.errorMessage);
                      }
                    },
                    builder: (context, state) {
                      if (state is ProductProgress || state is ProductInitial) {
                        return ProductSimmer(
                            length: 5, width: width!, height: height!);
                      }
                      if (state is ProductFailure) {
                        return Center(child: Text(state.errorMessage));
                      }

                      final productList = (state as ProductSuccess).productList;
                      final hasMore = state.hasMore;

                      return Padding(
                        padding: EdgeInsetsDirectional.only(
                            start: width! / 40.0,
                            end: width! / 40.0,
                            top: height! / 40.0,
                            bottom: height! / 15.0),
                        child: ListView.builder(
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            itemCount: productList.length,
                            controller: controllerProduct,
                            physics: AlwaysScrollableScrollPhysics(),
                            itemBuilder: ((context, index) {
                              ProductDetails dataItem = productList[index];

                              double price = double.parse(
                                  dataItem.variants![0].specialPrice!);
                              if (price == 0) {
                                price =
                                    double.parse(dataItem.variants![0].price!);
                              }
                              double off = 0;
                              if (dataItem.variants![0].specialPrice! != "0") {
                                off = (double.parse(
                                            dataItem.variants![0].price!) -
                                        double.parse(dataItem
                                            .variants![0].specialPrice!))
                                    .toDouble();
                                off = off *
                                    100 /
                                    double.parse(dataItem.variants![0].price!)
                                        .toDouble();
                              }
                              return hasMore &&
                                      productList.isEmpty &&
                                      index == (productList.length - 1)
                                  ? Center(
                                      child: CircularProgressIndicator(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary))
                                  : BlocProvider(
                                      create: (context) => GetQuantityCubit(),
                                      child: ProductItemContainer(
                                        dataItem: dataItem,
                                        i: index,
                                        width: width!,
                                        height: height!,
                                        price: price,
                                        off: off,
                                        dataMainList: productList,
                                        from: "restaurant",
                                        productCubit:
                                            context.read<ProductCubit>(),
                                      ),
                                    );
                            })),
                      );
                    })));
  }

  @override
  bool get wantKeepAlive => true;
}
