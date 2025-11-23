import 'dart:async';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:erestroSingleVender/app/routes.dart';
import 'package:erestroSingleVender/cubit/auth/authCubit.dart';
import 'package:erestroSingleVender/cubit/cart/getCartCubit.dart';
import 'package:erestroSingleVender/data/model/sectionsModel.dart';
import 'package:erestroSingleVender/ui/styles/design.dart';
import 'package:erestroSingleVender/ui/widgets/bottomSheetContainer.dart';
import 'package:erestroSingleVender/ui/widgets/brachCloseDialog.dart';
import 'package:erestroSingleVender/ui/widgets/productUnavailableDialog.dart';
import 'package:erestroSingleVender/ui/widgets/simmer/sliderSimmer.dart';
import 'package:erestroSingleVender/utils/SqliteData.dart';
import 'package:erestroSingleVender/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../cubit/home/slider/sliderOfferCubit.dart';

class SliderScreen extends StatefulWidget {
  const SliderScreen({Key? key}) : super(key: key);

  @override
  State<SliderScreen> createState() => _SliderScreenState();
}

class _SliderScreenState extends State<SliderScreen>
    with SingleTickerProviderStateMixin {
  int _currentPage = 0;
  double? width, height;
  var db = DatabaseHelper();
  PageController _pageController = PageController(initialPage: 0);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => animateSlider());
  }

  void animateSlider() {
    Future.delayed(const Duration(seconds: 10)).then((_) {
      if (mounted) {
        int nextPage = _pageController.hasClients
            ? _pageController.page!.round() + 1
            : _pageController.initialPage;
        if (nextPage == context.read<SliderCubit>().getSliderData().length) {
          nextPage = 0;
        }
        if (_pageController.hasClients) {
          _pageController
              .animateToPage(nextPage,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.linear)
              .then((_) {
            animateSlider();
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  addToCartBottomModelSheet(ProductDetails productList) async {
    ProductDetails productDetailsModel = productList;
    Map<String, int> qtyData = {};
    int currentIndex = 0, qty = 0;
    List<bool> isChecked =
        List<bool>.filled(productDetailsModel.productAddOns!.length, false);
    String? productVariantId = productDetailsModel.variants![currentIndex].id;

    List<String> addOnIds = [];
    List<String> addOnQty = [];
    List<double> addOnPrice = [];
    List<String> productAddOnIds = [];

    if (context.read<AuthCubit>().getId().isEmpty ||
        context.read<AuthCubit>().getId() == "") {
      if (qty == 0) {
        qty = int.parse(productDetailsModel.minimumOrderQuantity!);
      } else {
        print(qty);

        qtyData[productVariantId!] = 1;
      }
    } else {
      if (productDetailsModel.variants![currentIndex].cartCount != "0") {
        qty = 1;
      } else {
        qty = int.parse(productDetailsModel.minimumOrderQuantity!);
      }
    }
    qtyData[productVariantId!] = qty;
    bool descTextShowFlag = false;

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
          return BottomSheetContainer(
              productDetailsModel: productDetailsModel,
              isChecked: isChecked,
              height: height!,
              width: width!,
              productVariantId: productVariantId,
              addOnIds: addOnIds,
              addOnPrice: addOnPrice,
              addOnQty: addOnQty,
              productAddOnIds: productAddOnIds,
              qtyData: qtyData,
              currentIndex: currentIndex,
              descTextShowFlag: descTextShowFlag,
              qty: qty,
              from: "home");
        });
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return BlocConsumer<SliderCubit, SliderState>(
        bloc: context.read<SliderCubit>(),
        listener: (context, state) {},
        builder: (context, state) {
          if (state is SliderProgress || state is SliderInitial) {
            return SliderSimmer(width: width!, height: height!);
          }
          if (state is SliderFailure) {
            return const SizedBox();
          }
          final sliderList = (state as SliderSuccess).sliderList;
          return sliderList.isEmpty
              ? const SizedBox()
              : Column(
                  children: [
                    CarouselSlider(
                        items: sliderList
                            .map((item) => GestureDetector(
                                  onTap: () {
                                    if (item.type == "default") {
                                    } else if (item.type == "categories") {
                                      Navigator.of(context).pushNamed(
                                          Routes.cuisineDetail,
                                          arguments: {
                                            'categoryId': item.data![0].id!,
                                            'name': item.data![0].text!
                                          });
                                    } else if (item.type == "products") {
                                      if (item.data![0].isBranchOpen == "1") {
                                        ProductDetails productDetails =
                                            ProductDetails(
                                                sales: item.data![0].sales,
                                                stockType:
                                                    item.data![0].stockType,
                                                calories:
                                                    item.data![0].calories,
                                                status: item.data![0].status,
                                                isPricesInclusiveTax: item
                                                    .data![0]
                                                    .isPricesInclusiveTax,
                                                taxId: item.data![0].taxId,
                                                type: item.data![0].type,
                                                attrValueIds:
                                                    item.data![0].attrValueIds,
                                                branchId:
                                                    item.data![0].branchId,
                                                ownerName:
                                                    item.data![0].ownerName,
                                                id: item.data![0].id,
                                                stock: item.data![0].stock,
                                                name: item.data![0].name,
                                                categoryId:
                                                    item.data![0].categoryId,
                                                availableTime:
                                                    item.data![0].availableTime,
                                                startTime:
                                                    item.data![0].startTime,
                                                endTime: item.data![0].endTime,
                                                shortDescription: item
                                                    .data![0].shortDescription,
                                                slug: item.data![0].slug,
                                                totalAllowedQuantity: item
                                                    .data![0]
                                                    .totalAllowedQuantity,
                                                minimumOrderQuantity: item
                                                    .data![0]
                                                    .minimumOrderQuantity,
                                                codAllowed:
                                                    item.data![0].codAllowed,
                                                rowOrder:
                                                    item.data![0].rowOrder,
                                                rating: item.data![0].rating,
                                                noOfRatings:
                                                    item.data![0].noOfRatings,
                                                image: item.data![0].image,
                                                isCancelable:
                                                    item.data![0].isCancelable,
                                                cancelableTill: item
                                                    .data![0].cancelableTill,
                                                indicator:
                                                    item.data![0].indicator,
                                                highlights:
                                                    item.data![0].highlights,
                                                availability:
                                                    item.data![0].availability,
                                                categoryName:
                                                    item.data![0].categoryName,
                                                categorySlug:
                                                    item.data![0].categorySlug,
                                                taxPercentage:
                                                    item.data![0].taxPercentage,
                                                reviewImages:
                                                    item.data![0].reviewImages,
                                                attributes:
                                                    item.data![0].attributes,
                                                productAddOns:
                                                    item.data![0].productAddOns,
                                                variants:
                                                    item.data![0].variants,
                                                minMaxPrice:
                                                    item.data![0].minMaxPrice,
                                                isPurchased:
                                                    item.data![0].isPurchased,
                                                relativePath:
                                                    item.data![0].relativePath,
                                                otherImagesRelativePath: item
                                                    .data![0]
                                                    .otherImagesRelativePath,
                                                isFavorite:
                                                    item.data![0].isFavorite,
                                                imageMd: item.data![0].imageMd,
                                                imageSm: item.data![0].imageSm,
                                                variantAttributes: item
                                                    .data![0].variantAttributes,
                                                total: item.data![0].total,
                                                bestSeller:
                                                    item.data![0].bestSeller,
                                                isSpicy: item.data![0].isSpicy);
                                        bool check = getStoreOpenStatus(
                                            productDetails.startTime!,
                                            productDetails.endTime!);
                                        if (productDetails.availableTime ==
                                            "1") {
                                          if (check == true) {
                                            addToCartBottomModelSheet(context
                                                .read<GetCartCubit>()
                                                .getProductDetailsData(
                                                    productDetails.id!,
                                                    productDetails)[0]);
                                          } else {
                                            showDialog(
                                                context: context,
                                                builder: (_) =>
                                                    ProductUnavailableDialog(
                                                        startTime:
                                                            productDetails
                                                                .startTime,
                                                        endTime: productDetails
                                                            .endTime,
                                                        width: width,
                                                        height: height));
                                          }
                                        } else {
                                          addToCartBottomModelSheet(context
                                              .read<GetCartCubit>()
                                              .getProductDetailsData(
                                                  productDetails.id!,
                                                  productDetails)[0]);
                                        }
                                      } else {
                                        showDialog(
                                            context: context,
                                            builder: (_) => BranchCloseDialog(
                                                hours: "",
                                                minute: "",
                                                status: false,
                                                width: width!,
                                                height: height!));
                                      }
                                    }
                                  },
                                  child: Container(
                                    margin: EdgeInsetsDirectional.only(
                                        start: width! / 20.0,
                                        end: width! / 20.0,
                                        top: 10.0),
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(8.0)),
                                      child: DesignConfig.imageWidgets(
                                          item.image!,
                                          height! / 5.0,
                                          width!,
                                          "2",
                                          imageScreenSet: true),
                                    ),
                                  ),
                                ))
                            .toList(),
                        options: CarouselOptions(
                          autoPlay: true,
                          enlargeCenterPage: true,
                          reverse: false,
                          viewportFraction: 1,
                          autoPlayAnimationDuration:
                              const Duration(milliseconds: 1000),
                          aspectRatio: 2.8,
                          initialPage: 0,
                          onPageChanged: (index, reason) {
                            setState(() {
                              _currentPage = index;
                            });
                          },
                        )),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: sliderList
                          .map((item) => Container(
                                width: _currentPage == sliderList.indexOf(item)
                                    ? 16.0
                                    : 8.0,
                                height: 8.0,
                                margin: const EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 2.0),
                                decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(4.0)),
                                    color:
                                        _currentPage == sliderList.indexOf(item)
                                            ? Theme.of(context)
                                                .colorScheme
                                                .onPrimary
                                            : Theme.of(context)
                                                .colorScheme
                                                .onPrimary
                                                .withValues(alpha: 0.76)),
                              ))
                          .toList(),
                    ),
                  ],
                );
        });
  }
}
