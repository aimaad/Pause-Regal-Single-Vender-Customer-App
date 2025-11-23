import 'package:erestroSingleVender/app/app.dart';
import 'package:erestroSingleVender/app/routes.dart';
import 'package:erestroSingleVender/cubit/auth/authCubit.dart';
import 'package:erestroSingleVender/cubit/cart/getCartCubit.dart';
import 'package:erestroSingleVender/cubit/cart/getQuantityCubit.dart';
import 'package:erestroSingleVender/cubit/cart/manageCartCubit.dart';
import 'package:erestroSingleVender/cubit/cart/removeFromCartCubit.dart';
import 'package:erestroSingleVender/cubit/favourite/updateFavouriteProduct.dart';
import 'package:erestroSingleVender/cubit/product/productCubit.dart';
import 'package:erestroSingleVender/cubit/promoCode/validatePromoCodeCubit.dart';
import 'package:erestroSingleVender/cubit/settings/settingsCubit.dart';
import 'package:erestroSingleVender/data/model/sectionsModel.dart';
import 'package:erestroSingleVender/cubit/systemConfig/systemConfigCubit.dart';
import 'package:erestroSingleVender/ui/screen/cart/cart_screen.dart';
import 'package:erestroSingleVender/ui/styles/color.dart';
import 'package:erestroSingleVender/ui/styles/design.dart';
import 'package:erestroSingleVender/ui/widgets/bottomSheetEditItemContainer.dart';
import 'package:erestroSingleVender/ui/widgets/brachCloseDialog.dart';
import 'package:erestroSingleVender/ui/widgets/favoriteContainer.dart';
import 'package:erestroSingleVender/ui/widgets/productUnavailableDialog.dart';
import 'package:erestroSingleVender/utils/SqliteData.dart';
import 'package:erestroSingleVender/utils/labelKeys.dart';
import 'package:erestroSingleVender/utils/string.dart';
import 'package:erestroSingleVender/ui/widgets/bottomSheetContainer.dart';
import 'package:erestroSingleVender/utils/constants.dart';
import 'package:erestroSingleVender/utils/uiUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:ui' as ui;

class ProductItemContainer extends StatefulWidget {
  final ProductDetails dataItem;
  final List<ProductDetails> dataMainList;
  final int? i;
  final double? width, height, price, off;
  final String? from;
  final ProductCubit? productCubit;
  const ProductItemContainer(
      {Key? key,
      required this.dataItem,
      this.i,
      this.width,
      this.height,
      this.price,
      this.off,
      required this.dataMainList,
      this.from,
      this.productCubit})
      : super(key: key);

  @override
  State<ProductItemContainer> createState() => _ProductItemContainerState();
}

class _ProductItemContainerState extends State<ProductItemContainer> {
  var db = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      context
          .read<GetQuantityCubit>()
          .getQuantity(widget.dataItem.id!, widget.dataItem, context);
    });
  }

  addToCartBottomModelSheet(ProductDetails productList) async {
    ProductDetails productDetailsModel = productList;
    Map<String, int> qtyData = {};
    int currentIndex = 0, qty = 0;
    List<bool> isChecked =
        List<bool>.filled(productDetailsModel.productAddOns!.length, false);
    String? productVariantId = productDetailsModel.variants![0].id;
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
              height: widget.height!,
              width: widget.width!,
              productVariantId: productVariantId,
              addOnIds: addOnIds,
              addOnPrice: addOnPrice,
              addOnQty: addOnQty,
              productAddOnIds: productAddOnIds,
              qtyData: qtyData,
              currentIndex: currentIndex,
              descTextShowFlag: descTextShowFlag,
              qty: qty);
        }).then((value) {
      if (mounted)
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            context.read<GetQuantityCubit>().getQuantity(
                productList.id!, productList, navigatorKey.currentContext!);
          }
        });
    });
  }

  editToCartBottomModelSheet(ProductDetails productList) async {
    ProductDetails productDetailsModel = productList;
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
          return BottomSheetEditItemContainer(
            productDetailsModel: productDetailsModel,
            height: widget.height!,
            width: widget.width!,
          );
        }).then((value) {
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          context.read<GetQuantityCubit>().getQuantity(
              productList.id!, productList, navigatorKey.currentContext!);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    RegExp regex = RegExp(r'([^\d]00)(?=[^\d]|$)');
    return BlocProvider<UpdateProductFavoriteStatusCubit>(
        create: (context) => UpdateProductFavoriteStatusCubit(),
        child: BlocBuilder<GetQuantityCubit, GetQuantityState>(
          builder: (context, state) {
            return Builder(builder: (context) {
              return InkWell(
                onTap: () {
                  if (widget.dataItem.isBranchOpen == "1") {
                    bool check = getStoreOpenStatus(
                        widget.dataItem.startTime!, widget.dataItem.endTime!);

                    if (widget.dataItem.availableTime == "1") {
                      if (check == true) {
                        addToCartBottomModelSheet(context
                            .read<GetCartCubit>()
                            .getProductDetailsData(
                                widget.dataItem.id!, widget.dataItem)[0]);
                      } else {
                        showDialog(
                            context: context,
                            builder: (_) => ProductUnavailableDialog(
                                startTime: widget.dataItem.startTime,
                                endTime: widget.dataItem.endTime,
                                width: widget.width,
                                height: widget.height));
                      }
                    } else {
                      addToCartBottomModelSheet(context
                          .read<GetCartCubit>()
                          .getProductDetailsData(
                              widget.dataItem.id!, widget.dataItem)[0]);
                    }
                  } else {
                    showDialog(
                        context: context,
                        builder: (_) => BranchCloseDialog(
                            hours: "",
                            minute: "",
                            status: false,
                            width: widget.width!,
                            height: widget.height!));
                  }
                },
                child: Container(
                    width: widget.width!,
                    margin: EdgeInsetsDirectional.only(
                      start: widget.width! / 60.0,
                      end: widget.width! / 60.0,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                                flex: 3,
                                child: Stack(
                                  children: [
                                    ClipRRect(
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(10.0)),
                                        child: SizedBox(
                                          height: widget.height! / 6.5,
                                          width: widget.width!,
                                          child: UiUtils.customColorFiltered(
                                            context,
                                            hideFilter:
                                                widget.dataItem.isBranchOpen ==
                                                    "1",
                                            child: ShaderMask(
                                                shaderCallback: (Rect bounds) {
                                                  return LinearGradient(
                                                    begin: Alignment.center,
                                                    end: Alignment.bottomCenter,
                                                    colors: [
                                                      shaderColor,
                                                      widget.off!.toStringAsFixed(
                                                                  2) ==
                                                              "0.00"
                                                          ? shaderColor
                                                          : black
                                                    ],
                                                  ).createShader(bounds);
                                                },
                                                blendMode: BlendMode.darken,
                                                child:
                                                    DesignConfig.imageWidgets(
                                                        widget.dataItem.image!,
                                                        widget.height! / 6.5,
                                                        widget.width!,
                                                        "2")),
                                          ),
                                        )),
                                    Positioned.directional(
                                      textDirection: Directionality.of(context),
                                      start: 10.0,
                                      bottom: 10.0,
                                      child: widget.off!.toStringAsFixed(2) ==
                                              "0.00"
                                          ? const SizedBox()
                                          : Text(
                                              "${widget.off!.toStringAsFixed(2).replaceAll(regex, '')}${StringsRes.percentSymbol} ${StringsRes.off}",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onSurface,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                  fontStyle: FontStyle.normal)),
                                    ),
                                  ],
                                )),
                            Expanded(
                              flex: 6,
                              child: Padding(
                                padding: EdgeInsetsDirectional.only(
                                    start: widget.width! / 50.0,
                                    bottom: widget.height! / 99.0),
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          widget.dataItem.indicator == "1"
                                              ? Container(
                                                  child: SvgPicture.asset(
                                                      DesignConfig.setSvgPath(
                                                          "veg_icon"),
                                                      width: 15,
                                                      height: 15))
                                              : widget.dataItem.indicator == "2"
                                                  ? SvgPicture.asset(
                                                      DesignConfig.setSvgPath(
                                                          "non_veg_icon"),
                                                      width: 15,
                                                      height: 15)
                                                  : const SizedBox(),
                                          widget.dataItem.isSpicy == "1"
                                              ? DesignConfig()
                                                  .spicyWidget(widget.width)
                                              : const SizedBox.shrink(),
                                          widget.dataItem.bestSeller == "1"
                                              ? DesignConfig().bestSellerWidget(
                                                  widget.width, context)
                                              : const SizedBox.shrink(),
                                          const Spacer(),
                                          (widget.dataItem.rating == "0" ||
                                                  widget.dataItem.rating ==
                                                      "0.0" ||
                                                  widget.dataItem.rating ==
                                                      "0.00")
                                              ? const SizedBox()
                                              : Padding(
                                                  padding:
                                                      const EdgeInsetsDirectional
                                                          .only(
                                                          start: 8.0, end: 5.0),
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      Navigator.of(context)
                                                          .pushNamed(
                                                              Routes
                                                                  .productRatingDetail,
                                                              arguments: {
                                                            'productId': widget
                                                                .dataItem.id!
                                                          });
                                                    },
                                                    child: Row(
                                                      children: [
                                                        SvgPicture.asset(
                                                            DesignConfig
                                                                .setSvgPath(
                                                                    "rating"),
                                                            fit: BoxFit
                                                                .scaleDown,
                                                            width: 7.0,
                                                            height: 12.3),
                                                        const SizedBox(
                                                            width: 3.4),
                                                        Text(
                                                          double.parse(widget
                                                                  .dataItem
                                                                  .rating!)
                                                              .toStringAsFixed(
                                                                  1),
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                              color: Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .onPrimary,
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                          FavoriteContainer(
                                              from: "product",
                                              productDetails: widget.dataItem),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Flexible(
                                            child: SizedBox(
                                              height: widget.height! / 19.0,
                                              child: Text(widget.dataItem.name!,
                                                  textAlign: Directionality.of(
                                                              context) ==
                                                          ui.TextDirection.rtl
                                                      ? TextAlign.right
                                                      : TextAlign.left,
                                                  style: TextStyle(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .onPrimary,
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      overflow: TextOverflow
                                                          .ellipsis),
                                                  maxLines: 2),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                  context
                                                          .read<
                                                              SystemConfigCubit>()
                                                          .getCurrency() +
                                                      widget.price.toString(),
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .secondary,
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w700)),
                                              SizedBox(
                                                  width: widget.width! / 99.0),
                                              widget.off!.toStringAsFixed(2) ==
                                                      "0.00"
                                                  ? const SizedBox()
                                                  : Text(
                                                      "${context.read<SystemConfigCubit>().getCurrency()}${widget.dataItem.variants![0].price!}",
                                                      style: TextStyle(
                                                          decoration:
                                                              TextDecoration
                                                                  .lineThrough,
                                                          letterSpacing: 0,
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .onPrimary
                                                                  .withValues(
                                                                      alpha:
                                                                          0.76),
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          overflow: TextOverflow
                                                              .ellipsis),
                                                      maxLines: 1,
                                                    ),
                                            ],
                                          ),
                                          const Spacer(),
                                          Padding(
                                              padding: EdgeInsetsDirectional.only(
                                                  top: widget.height! / 60.0),
                                              child: InkWell(
                                                  onTap: () {
                                                    if (widget.dataItem
                                                            .isBranchOpen ==
                                                        "1") {
                                                      bool check =
                                                          getStoreOpenStatus(
                                                              widget.dataItem
                                                                  .startTime!,
                                                              widget.dataItem
                                                                  .endTime!);
                                                      if (widget.dataItem
                                                              .availableTime ==
                                                          "1") {
                                                        if (check == true) {
                                                          addToCartBottomModelSheet(context
                                                              .read<
                                                                  GetCartCubit>()
                                                              .getProductDetailsData(
                                                                  widget
                                                                      .dataItem
                                                                      .id!,
                                                                  widget
                                                                      .dataItem)[0]);
                                                        } else {
                                                          showDialog(
                                                              context: context,
                                                              builder: (_) => ProductUnavailableDialog(
                                                                  startTime: widget
                                                                      .dataItem
                                                                      .startTime,
                                                                  endTime: widget
                                                                      .dataItem
                                                                      .endTime,
                                                                  width: widget
                                                                      .width,
                                                                  height: widget
                                                                      .height));
                                                        }
                                                      } else {
                                                        addToCartBottomModelSheet(context
                                                            .read<
                                                                GetCartCubit>()
                                                            .getProductDetailsData(
                                                                widget.dataItem
                                                                    .id!,
                                                                widget
                                                                    .dataItem)[0]);
                                                      }
                                                    } else {
                                                      showDialog(
                                                          context: context,
                                                          builder: (_) =>
                                                              BranchCloseDialog(
                                                                  hours: "",
                                                                  minute: "",
                                                                  status: false,
                                                                  width: widget
                                                                      .width!,
                                                                  height: widget
                                                                      .height!));
                                                    }
                                                  },
                                                  child:
                                                      (context.read<GetQuantityCubit>().fetchQty() == "0" ||
                                                              context.read<GetQuantityCubit>().fetchQty() ==
                                                                  "")
                                                          ? Container(
                                                              alignment: Alignment
                                                                  .center,
                                                              width: widget.width! /
                                                                  3.8,
                                                              height:
                                                                  widget.height! /
                                                                      20,
                                                              decoration: DesignConfig.boxDecorationContainerBorder(
                                                                  widget.dataItem.isBranchOpen == "1"
                                                                      ? Theme.of(context)
                                                                          .colorScheme
                                                                          .primary
                                                                      : textFieldBorder,
                                                                  widget.dataItem.isBranchOpen == "1"
                                                                      ? Theme.of(context)
                                                                          .colorScheme
                                                                          .primary
                                                                          .withValues(
                                                                              alpha:
                                                                                  0.08)
                                                                      : textFieldBackground,
                                                                  5.0),
                                                              child: Text(UiUtils.getTranslatedLabel(context, addLabel).toUpperCase(),
                                                                  style: TextStyle(
                                                                      color: widget.dataItem.isBranchOpen == "1" ? Theme.of(context).colorScheme.primary : textFieldBorder,
                                                                      fontWeight: FontWeight.w700,
                                                                      fontStyle: FontStyle.normal,
                                                                      fontSize: 16.0),
                                                                  textAlign: TextAlign.left))
                                                          : BlocConsumer<ManageCartCubit, ManageCartState>(
                                                              bloc: context.read<ManageCartCubit>(),
                                                              listener: (context, state) {
                                                                print(state
                                                                    .toString());
                                                                if (state
                                                                    is ManageCartSuccess) {
                                                                  if (context.read<AuthCubit>().state
                                                                          is AuthInitial ||
                                                                      context
                                                                          .read<
                                                                              AuthCubit>()
                                                                          .state is Unauthenticated) {
                                                                    return;
                                                                  } else {
                                                                    final currentCartModel = context
                                                                        .read<
                                                                            GetCartCubit>()
                                                                        .getCartModel();
                                                                    context.read<GetCartCubit>().updateCartList(currentCartModel.updateCart(
                                                                        state
                                                                            .data,
                                                                        (int.parse(state.totalQuantity!))
                                                                            .toString(),
                                                                        state
                                                                            .subTotal,
                                                                        state
                                                                            .taxPercentage,
                                                                        state
                                                                            .taxAmount,
                                                                        state
                                                                            .overallAmount,
                                                                        List.from(
                                                                            state.variantId ??
                                                                                [])
                                                                          ..addAll(currentCartModel.variantId ??
                                                                              [])));
                                                                    print(currentCartModel
                                                                        .variantId);
                                                                    if (context
                                                                            .read<
                                                                                AuthCubit>()
                                                                            .getId()
                                                                            .isEmpty ||
                                                                        context.read<AuthCubit>().getId() ==
                                                                            "") {
                                                                    } else {
                                                                      if (promoCode !=
                                                                          "") {
                                                                        context.read<ValidatePromoCodeCubit>().getValidatePromoCode(
                                                                            promoCode,
                                                                            state.overallAmount!.toStringAsFixed(2),
                                                                            context.read<SettingsCubit>().getSettings().branchId);
                                                                      }
                                                                    }
                                                                    Future.delayed(
                                                                        const Duration(
                                                                            seconds:
                                                                                1),
                                                                        () {
                                                                      if (mounted) {
                                                                        context.read<GetQuantityCubit>().getQuantity(
                                                                            widget.dataItem.id!,
                                                                            widget.dataItem,
                                                                            context);
                                                                      }
                                                                    });
                                                                  }
                                                                } else if (state
                                                                    is ManageCartFailure) {
                                                                  if (context.read<AuthCubit>().state
                                                                          is AuthInitial ||
                                                                      context
                                                                          .read<
                                                                              AuthCubit>()
                                                                          .state is Unauthenticated) {
                                                                    return;
                                                                  } else {
                                                                    UiUtils.setSnackBar(
                                                                        state
                                                                            .errorMessage,
                                                                        context,
                                                                        false,
                                                                        type:
                                                                            "2");
                                                                  }
                                                                }
                                                              },
                                                              builder: (context, state) {
                                                                return Container(
                                                                  padding:
                                                                      EdgeInsetsDirectional
                                                                          .all(
                                                                              8.0),
                                                                  alignment:
                                                                      Alignment
                                                                          .center,
                                                                  width: widget
                                                                          .width! /
                                                                      3.8,
                                                                  height: widget
                                                                          .height! /
                                                                      20,
                                                                  decoration: DesignConfig.boxDecorationContainer(
                                                                      Theme.of(
                                                                              context)
                                                                          .colorScheme
                                                                          .primary,
                                                                      5.0),
                                                                  child: Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .spaceBetween,
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .center,
                                                                      children: [
                                                                        BlocConsumer<RemoveFromCartCubit,
                                                                                RemoveFromCartState>(
                                                                            bloc: context.read<
                                                                                RemoveFromCartCubit>(),
                                                                            listener: (context,
                                                                                state) {
                                                                              if (state is RemoveFromCartSuccess) {
                                                                                context.read<GetCartCubit>().getCartUser(branchId: context.read<SettingsCubit>().getSettings().branchId);
                                                                              }
                                                                            },
                                                                            builder:
                                                                                (context, state) {
                                                                              return InkWell(
                                                                                onTap: () async {
                                                                                  if (widget.dataItem.isBranchOpen == "1") {
                                                                                    bool check = getStoreOpenStatus(widget.dataItem.startTime!, widget.dataItem.endTime!);
                                                                                    if ((widget.dataItem.availableTime == "1" && check == true) || (widget.dataItem.availableTime == "0")) {
                                                                                      if (widget.dataItem.variants!.length >= 1 && widget.dataItem.productAddOns!.isNotEmpty) {
                                                                                        editToCartBottomModelSheet(widget.dataItem);
                                                                                      } else {
                                                                                        int offlineCartItemId = int.parse((await db.checkItemExists(widget.dataItem.id!, widget.dataItem.variants![0].id!))!);
                                                                                        double priceCurrent = double.parse(widget.dataItem.variants![0].specialPrice!);
                                                                                        if (priceCurrent == 0) {
                                                                                          priceCurrent = double.parse(widget.dataItem.variants![0].price!);
                                                                                        }
                                                                                        double overAllTotal = (priceCurrent * int.parse(context.read<GetQuantityCubit>().fetchQty()!));
                                                                                        if (int.parse(context.read<GetQuantityCubit>().fetchQty()) == 1) {
                                                                                          if (context.read<AuthCubit>().getId().isEmpty || context.read<AuthCubit>().getId() == "") {
                                                                                            db.removeCart(widget.dataItem.variants![0].id!, widget.dataItem.id!, context, offlineCartItemId);
                                                                                          } else {
                                                                                            context.read<RemoveFromCartCubit>().removeFromCart(cartId: widget.dataItem.cartId, branchId: context.read<SettingsCubit>().getSettings().branchId);
                                                                                          }
                                                                                        } else {
                                                                                          if (context.read<AuthCubit>().getId().isEmpty || context.read<AuthCubit>().getId() == "") {
                                                                                            db.insertCart(widget.dataItem.id!, widget.dataItem.variants![0].id!, (int.parse(context.read<GetQuantityCubit>().fetchQty()) - 1).toString(), "", "", overAllTotal.toString(), context.read<SettingsCubit>().getSettings().branchId, context, id: offlineCartItemId).then((value) {
                                                                                              Future.delayed(const Duration(seconds: 1), () {
                                                                                                if (mounted) {
                                                                                                  context.read<GetQuantityCubit>().getQuantity(widget.dataItem.id!, widget.dataItem, context);
                                                                                                }
                                                                                              });
                                                                                            });
                                                                                          } else {
                                                                                            context.read<ManageCartCubit>().manageCartUser(productVariantId: widget.dataItem.variants![0].id, isSavedForLater: "0", qty: (int.parse(context.read<GetQuantityCubit>().fetchQty()) - 1).toString(), addOnId: "", addOnQty: "", branchId: context.read<SettingsCubit>().getSettings().branchId, cartId: widget.dataItem.cartId);
                                                                                          }
                                                                                        }
                                                                                        Future.delayed(const Duration(seconds: 1), () {
                                                                                          context.read<GetQuantityCubit>().getQuantity(widget.dataItem.id!, widget.dataItem, context);
                                                                                        });
                                                                                        if (context.read<AuthCubit>().getId().isEmpty || context.read<AuthCubit>().getId() == "") {
                                                                                        } else {
                                                                                          if (promoCode != "") {
                                                                                            context.read<ValidatePromoCodeCubit>().getValidatePromoCode(promoCode, overAllAmount.toStringAsFixed(2), context.read<SettingsCubit>().getSettings().branchId);
                                                                                          }
                                                                                        }
                                                                                      }
                                                                                    } else {
                                                                                      showDialog(context: context, builder: (_) => ProductUnavailableDialog(startTime: widget.dataItem.startTime, endTime: widget.dataItem.endTime, width: widget.width, height: widget.height));
                                                                                    }
                                                                                  } else {
                                                                                    showDialog(context: context, builder: (_) => BranchCloseDialog(hours: "", minute: "", status: false, width: widget.width!, height: widget.height!));
                                                                                  }
                                                                                },
                                                                                child: Container(decoration: DesignConfig.boxDecorationContainer(Theme.of(context).colorScheme.onSurface, 2.0), child: Icon(Icons.remove, color: Theme.of(context).colorScheme.onSecondary)),
                                                                              );
                                                                            }),
                                                                        const Spacer(),
                                                                        Text(context.read<GetQuantityCubit>().fetchQty(),
                                                                            textAlign: TextAlign
                                                                                .center,
                                                                            style: TextStyle(
                                                                                color: Theme.of(context).colorScheme.onPrimary,
                                                                                fontWeight: FontWeight.w700,
                                                                                fontStyle: FontStyle.normal,
                                                                                fontSize: 16.0)),
                                                                        const Spacer(),
                                                                        InkWell(
                                                                            onTap:
                                                                                () async {
                                                                              if (widget.dataItem.isBranchOpen == "1") {
                                                                                bool check = getStoreOpenStatus(widget.dataItem.startTime!, widget.dataItem.endTime!);
                                                                                if ((widget.dataItem.availableTime == "1" && check == true) || (widget.dataItem.availableTime == "0")) {
                                                                                  if (widget.dataItem.variants!.length >= 1 && widget.dataItem.productAddOns!.isNotEmpty) {
                                                                                    editToCartBottomModelSheet(widget.dataItem);
                                                                                  } else {
                                                                                    int offlineCartItemId = int.parse((await db.checkItemExists(widget.dataItem.id!, widget.dataItem.variants![0].id!))!);
                                                                                    double priceCurrent = double.parse(widget.dataItem.variants![0].specialPrice!);
                                                                                    if (priceCurrent == 0) {
                                                                                      priceCurrent = double.parse(widget.dataItem.variants![0].price!);
                                                                                    }
                                                                                    double overAllTotal = (priceCurrent * int.parse(context.read<GetQuantityCubit>().fetchQty()!));
                                                                                    setState(() {
                                                                                      if (int.parse(context.read<GetQuantityCubit>().fetchQty()) < int.parse(widget.dataItem.minimumOrderQuantity!)) {
                                                                                        UiUtils.setSnackBar("${StringsRes.minimumQuantityAllowed} ${widget.dataItem.minimumOrderQuantity!}", context, false, type: "2");
                                                                                      } else if (widget.dataItem.totalAllowedQuantity != "" && int.parse(context.read<GetQuantityCubit>().fetchQty()) >= int.parse(widget.dataItem.totalAllowedQuantity!)) {
                                                                                        UiUtils.setSnackBar("${StringsRes.minimumQuantityAllowed} ${widget.dataItem.totalAllowedQuantity!}", context, false, type: "2");
                                                                                      } else {
                                                                                        if (context.read<AuthCubit>().getId().isEmpty || context.read<AuthCubit>().getId() == "") {
                                                                                          db.insertCart(widget.dataItem.id!, widget.dataItem.variants![0].id!, (int.parse(context.read<GetQuantityCubit>().fetchQty()) + 1).toString(), "", "", overAllTotal.toString(), context.read<SettingsCubit>().getSettings().branchId, context, id: offlineCartItemId).then((value) {
                                                                                            Future.delayed(const Duration(seconds: 1), () {
                                                                                              context.read<GetQuantityCubit>().getQuantity(widget.dataItem.id!, widget.dataItem, context);
                                                                                            });
                                                                                          });
                                                                                        } else {
                                                                                          context.read<ManageCartCubit>().manageCartUser(productVariantId: widget.dataItem.variants![0].id, isSavedForLater: "0", qty: (int.parse(context.read<GetQuantityCubit>().fetchQty()) + 1).toString(), addOnId: "", addOnQty: "", branchId: context.read<SettingsCubit>().getSettings().branchId, cartId: widget.dataItem.cartId);
                                                                                        }
                                                                                        Future.delayed(const Duration(seconds: 1), () {
                                                                                          context.read<GetQuantityCubit>().getQuantity(widget.dataItem.id!, widget.dataItem, context);
                                                                                        });
                                                                                        if (context.read<AuthCubit>().getId().isEmpty || context.read<AuthCubit>().getId() == "") {
                                                                                        } else {
                                                                                          if (promoCode != "") {
                                                                                            context.read<ValidatePromoCodeCubit>().getValidatePromoCode(promoCode, overAllAmount.toStringAsFixed(2), context.read<SettingsCubit>().getSettings().branchId);
                                                                                          }
                                                                                        }
                                                                                      }
                                                                                    });
                                                                                  }
                                                                                } else {
                                                                                  showDialog(context: context, builder: (_) => ProductUnavailableDialog(startTime: widget.dataItem.startTime, endTime: widget.dataItem.endTime, width: widget.width, height: widget.height));
                                                                                }
                                                                              } else {
                                                                                showDialog(context: context, builder: (_) => BranchCloseDialog(hours: "", minute: "", status: false, width: widget.width!, height: widget.height!));
                                                                              }
                                                                            },
                                                                            child:
                                                                                Container(decoration: DesignConfig.boxDecorationContainer(Theme.of(context).colorScheme.onSurface, 2.0), child: Icon(Icons.add, color: Theme.of(context).colorScheme.onSecondary))),
                                                                      ]),
                                                                );
                                                              }))),
                                        ],
                                      ),
                                      const SizedBox(height: 5.0),
                                      widget.dataItem.noOfRatings == "0"
                                          ? const SizedBox()
                                          : const SizedBox(width: 5.0),
                                    ]),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: EdgeInsetsDirectional.only(
                              top: widget.height! / 50.0,
                              bottom: widget.height! / 50.0),
                          child: DesignConfig.divider(),
                        ),
                      ],
                    )),
              );
            });
          },
        ));
  }
}
