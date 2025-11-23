// ignore_for_file: must_be_immutable

import 'package:erestroSingleVender/cubit/auth/authCubit.dart';
import 'package:erestroSingleVender/cubit/cart/getCartCubit.dart';
import 'package:erestroSingleVender/cubit/cart/manageCartCubit.dart';
import 'package:erestroSingleVender/cubit/cart/removeFromCartCubit.dart';
import 'package:erestroSingleVender/cubit/product/getOfflineCartCubit.dart';
import 'package:erestroSingleVender/cubit/product/offlineCartCubit.dart';
import 'package:erestroSingleVender/cubit/promoCode/validatePromoCodeCubit.dart';
import 'package:erestroSingleVender/cubit/settings/settingsCubit.dart';
import 'package:erestroSingleVender/cubit/systemConfig/systemConfigCubit.dart';
import 'package:erestroSingleVender/data/model/addOnsDataModel.dart';
import 'package:erestroSingleVender/data/model/cartModel.dart';
import 'package:erestroSingleVender/data/model/offlineCartModel.dart';
import 'package:erestroSingleVender/data/model/productAddOnsModel.dart';
import 'package:erestroSingleVender/data/model/sectionsModel.dart';
import 'package:erestroSingleVender/data/model/variantsModel.dart';
import 'package:erestroSingleVender/data/repositories/cart/cartRepository.dart';
import 'package:erestroSingleVender/ui/styles/design.dart';
import 'package:erestroSingleVender/ui/widgets/bottomSheetContainer.dart';
import 'package:erestroSingleVender/ui/widgets/buttomContainer.dart';
import 'package:erestroSingleVender/ui/widgets/simmer/notificationSimmer.dart';
import 'package:erestroSingleVender/utils/SqliteData.dart';
import 'package:erestroSingleVender/ui/styles/color.dart';
import 'package:erestroSingleVender/utils/labelKeys.dart';
import 'package:erestroSingleVender/ui/screen/cart/cart_screen.dart';
import 'package:erestroSingleVender/utils/string.dart';
import 'package:erestroSingleVender/utils/uiUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BottomSheetEditItemContainer extends StatefulWidget {
  final ProductDetails productDetailsModel;
  final double? width, height;

  BottomSheetEditItemContainer(
      {Key? key, required this.productDetailsModel, this.width, this.height})
      : super(key: key);

  @override
  State<BottomSheetEditItemContainer> createState() =>
      _BottomSheetEditItemContainerState();
}

class _BottomSheetEditItemContainerState
    extends State<BottomSheetEditItemContainer> {
  var db = DatabaseHelper();
  bool status = false;
  List<Data> cartList = [];
  @override
  void initState() {
    if (context.read<AuthCubit>().state is AuthInitial ||
        context.read<AuthCubit>().state is Unauthenticated) {
      context
          .read<GetOfflineCartCubit>()
          .getOfflineCart(widget.productDetailsModel, context);
    } else {
      cartList = context
          .read<GetCartCubit>()
          .getCartProductList(widget.productDetailsModel.id!);
    }
    Future.delayed(Duration.zero, () {
      context
          .read<GetOfflineCartCubit>()
          .getOfflineCart(widget.productDetailsModel, context);
    });
    super.initState();
  }

  Future<void> getOffLineCart(String variantId) async {
    if (mounted) {
      if (context.read<AuthCubit>().getId().isEmpty ||
          context.read<AuthCubit>().getId() == "") {
        productVariant = (await db.getCart());
        productVariantData = (await db.getCartData());
        if (productVariant!.isEmpty) {
        } else {
          List<Map> data = (await db.getOfflineCartData());
          offlineCartDataList =
              (data as List).map((e) => OfflineCartModel.fromJson(e)).toList();
          productVariantId = productVariant!['VID'];
          productAddOnId = productVariant!['ADDONID']
              .toString()
              .replaceAll("[", "")
              .replaceAll("]", "")
              .split(",");
          if (productVariantId!.isNotEmpty) {
            if (mounted) {
              await context.read<OfflineCartCubit>().getOfflineCart(
                  productVariantIds: productVariantId!.join(','),
                  branchId:
                      context.read<SettingsCubit>().getSettings().branchId);
            }
          } else {}
        }
      }
    }
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
              qty: qty,
              from: "home");
        });
  }

  //Clear OfflineCart Data
  clearOffLineCart(BuildContext context) {
    context.read<SettingsCubit>().setCartCount("0");
    context.read<SettingsCubit>().setCartTotal("0");
  }

  Widget offlineCartWidget() {
    return BlocConsumer<GetOfflineCartCubit, GetOfflineCartState>(
      listener: (context, state) {},
      builder: (context, state) {
        if (state is GetOfflineCartProgress || state is GetOfflineCartInitial) {
          return NotificationSimmer(width: widget.width, height: widget.height);
        }
        if (state is GetOfflineCartFailure) {
          return const SizedBox.shrink();
        }
        final offlineCartList =
            (state as GetOfflineCartSuccess).offlineCartList;
        return offlineCartList.isEmpty
            ? const SizedBox.shrink()
            : ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: offlineCartList.length,
                itemBuilder: (BuildContext context, i) {
                  return BlocBuilder<GetOfflineCartCubit, GetOfflineCartState>(
                    builder: (context, state) {
                      return Builder(builder: (context) {
                        return Container(
                          margin: EdgeInsetsDirectional.only(
                              start: widget.width! / 20.0,
                              end: widget.width! / 20.0),
                          padding: EdgeInsetsDirectional.only(
                              bottom: widget.height! / 99.0),
                          width: widget.width!,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsetsDirectional.only(
                                    start: widget.width! / 50.0,
                                    bottom: widget.height! / 99.0),
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Column(
                                        children: List.generate(
                                            widget.productDetailsModel.variants!
                                                .length, (l) {
                                          VariantsModel variantData = widget
                                              .productDetailsModel.variants![l];
                                          double price = double.parse(
                                              variantData.specialPrice!);
                                          if (price == 0) {
                                            price = double.parse(
                                                variantData.price!);
                                          }
                                          double off = 0;
                                          if (widget.productDetailsModel
                                                  .variants![l].specialPrice! !=
                                              "0") {
                                            off = (double.parse(
                                                        variantData.price!) -
                                                    double.parse(variantData
                                                        .specialPrice!))
                                                .toDouble();
                                            off = off *
                                                100 /
                                                double.parse(variantData.price!)
                                                    .toDouble();
                                          }
                                          var sum = 0.0;
                                          for (var h = 0;
                                              h <
                                                  widget.productDetailsModel
                                                      .productAddOns!.length;
                                              h++) {
                                            if (offlineCartList[i]
                                                .addOnId!
                                                .contains(widget
                                                    .productDetailsModel
                                                    .productAddOns![h]
                                                    .id!)) {
                                              sum += double.parse(widget
                                                      .productDetailsModel
                                                      .productAddOns![h]
                                                      .price!) *
                                                  int.parse(
                                                      offlineCartList[i].qty!);
                                            }
                                          }
                                          double overAllTotal = ((price *
                                                  int.parse(offlineCartList[i]
                                                      .qty!)) +
                                              sum);
                                          return (offlineCartList[i].vId ==
                                                  widget.productDetailsModel
                                                      .variants![l].id!)
                                              ? Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                      Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            widget.productDetailsModel
                                                                        .indicator ==
                                                                    "1"
                                                                ? SvgPicture.asset(
                                                                    DesignConfig
                                                                        .setSvgPath(
                                                                            "veg_icon"),
                                                                    width: 15,
                                                                    height: 15)
                                                                : widget.productDetailsModel
                                                                            .indicator ==
                                                                        "2"
                                                                    ? SvgPicture.asset(
                                                                        DesignConfig.setSvgPath(
                                                                            "non_veg_icon"),
                                                                        width:
                                                                            15,
                                                                        height:
                                                                            15)
                                                                    : const SizedBox(
                                                                        height:
                                                                            15,
                                                                        width:
                                                                            15.0),
                                                            const SizedBox(
                                                                width: 5.0),
                                                            Expanded(
                                                              flex: 2,
                                                              child: SizedBox(
                                                                height: widget
                                                                        .height! /
                                                                    22.0,
                                                                child: Text(
                                                                  widget
                                                                      .productDetailsModel
                                                                      .name!,
                                                                  textAlign: Directionality.of(
                                                                              context) ==
                                                                          TextDirection
                                                                              .rtl
                                                                      ? TextAlign
                                                                          .right
                                                                      : TextAlign
                                                                          .left,
                                                                  style: TextStyle(
                                                                      color: Theme.of(
                                                                              context)
                                                                          .colorScheme
                                                                          .onPrimary
                                                                          .withValues(
                                                                              alpha:
                                                                                  0.76),
                                                                      fontSize:
                                                                          14,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                      fontStyle:
                                                                          FontStyle
                                                                              .normal,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis),
                                                                  maxLines: 2,
                                                                ),
                                                              ),
                                                            ),
                                                            Container(
                                                              padding: EdgeInsetsDirectional
                                                                  .only(
                                                                      top: 3.0,
                                                                      bottom:
                                                                          3.0,
                                                                      start:
                                                                          5.0,
                                                                      end: 5.0),
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              height: 28.0,
                                                              width: widget
                                                                      .width! /
                                                                  4.8,
                                                              decoration: DesignConfig.boxDecorationContainerBorder(
                                                                  Theme.of(
                                                                          context)
                                                                      .colorScheme
                                                                      .primary,
                                                                  Theme.of(
                                                                          context)
                                                                      .colorScheme
                                                                      .primary
                                                                      .withValues(
                                                                          alpha:
                                                                              0.12),
                                                                  5.0),
                                                              child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    InkWell(
                                                                      overlayColor: WidgetStateProperty.all(Theme.of(
                                                                              context)
                                                                          .colorScheme
                                                                          .onPrimary
                                                                          .withValues(
                                                                              alpha: 0.10)),
                                                                      onTap:
                                                                          () async {
                                                                        List<ProductAddOnsModel>
                                                                            addOnsDataModel =
                                                                            widget.productDetailsModel.productAddOns!;
                                                                        List<String>
                                                                            addOnIds =
                                                                            [];
                                                                        List<String>
                                                                            addOnQty =
                                                                            [];
                                                                        var totalSum =
                                                                            0.0;
                                                                        List<
                                                                            String> productAddons = offlineCartList[
                                                                                i]
                                                                            .addOnId!
                                                                            .split(
                                                                                ',')
                                                                            .map((str) =>
                                                                                str.trim())
                                                                            .toList();

                                                                        for (int qt =
                                                                                0;
                                                                            qt <
                                                                                addOnsDataModel.length;
                                                                            qt++) {
                                                                          if (productAddons
                                                                              .contains(addOnsDataModel[qt].id)) {
                                                                            addOnIds.add(addOnsDataModel[qt].id.toString());
                                                                            addOnQty.add((int.parse(offlineCartList[i].qty.toString()) - 1).toString());
                                                                            totalSum +=
                                                                                (double.parse(addOnsDataModel[qt].price!.toString()) * (int.parse(offlineCartList[i].qty.toString()) - 1));
                                                                          }
                                                                        }
                                                                        double
                                                                            overAllTotalPrice =
                                                                            (price * (int.parse(offlineCartList[i].qty.toString()) - 1) +
                                                                                totalSum);

                                                                        if (int.parse(offlineCartList[i].qty.toString()) ==
                                                                            1) {
                                                                          db.removeCart(
                                                                              variantData.id!,
                                                                              widget.productDetailsModel.id!,
                                                                              context,
                                                                              int.parse(offlineCartList[i].id!));

                                                                          context.read<OfflineCartCubit>().updateQuntity(
                                                                              widget.productDetailsModel,
                                                                              ((int.parse(offlineCartList[i].qty.toString()) - 1)).toString(),
                                                                              variantData.id);
                                                                          offlineCartList
                                                                              .removeAt(i);
                                                                          productVariant =
                                                                              (await db.getCart());
                                                                          productVariantData =
                                                                              (await db.getCartData());

                                                                          if (offlineCartList
                                                                              .isEmpty) {
                                                                            db.clearCart();
                                                                            offlineCartList.clear();
                                                                            getOffLineCart(offlineCartList[i].vId!);
                                                                            clearOffLineCart(context);
                                                                            context.read<OfflineCartCubit>().clearOfflineCartModel();
                                                                            setState(() {});
                                                                          }
                                                                        } else {
                                                                          db.insertCart(widget.productDetailsModel.id!, variantData.id!, (int.parse(offlineCartList[i].qty.toString()) - 1).toString(), addOnIds.isNotEmpty ? addOnIds.join(",").toString() : "", addOnQty.isNotEmpty ? addOnQty.join(",").toString() : "", overAllTotalPrice.toString(), context.read<SettingsCubit>().getSettings().branchId, context, edit: true, id: int.parse(offlineCartList[i].id!)).whenComplete(
                                                                              () async {
                                                                            context.read<OfflineCartCubit>().updateQuntity(
                                                                                widget.productDetailsModel,
                                                                                ((int.parse(offlineCartList[i].qty.toString()) - 1)).toString(),
                                                                                variantData.id);
                                                                            offlineCartList[i].qty =
                                                                                (int.parse(offlineCartList[i].qty!) - 1).toString();

                                                                            setState(() {});
                                                                          });
                                                                        }
                                                                        setState(
                                                                            () {});
                                                                      },
                                                                      child: Icon(
                                                                          Icons
                                                                              .remove,
                                                                          color: Theme.of(context)
                                                                              .colorScheme
                                                                              .onPrimary,
                                                                          size:
                                                                              15.0),
                                                                    ),
                                                                    const Spacer(),
                                                                    offlineCartList
                                                                            .isNotEmpty
                                                                        ? Text(
                                                                            offlineCartList[i].qty!,
                                                                            textAlign:
                                                                                TextAlign.center,
                                                                            style:
                                                                                TextStyle(
                                                                              color: Theme.of(context).colorScheme.onPrimary,
                                                                              fontSize: 10,
                                                                              fontWeight: FontWeight.w700,
                                                                              fontStyle: FontStyle.normal,
                                                                            ),
                                                                          )
                                                                        : const SizedBox
                                                                            .shrink(),
                                                                    const Spacer(),
                                                                    InkWell(
                                                                      overlayColor: WidgetStateProperty.all(Theme.of(
                                                                              context)
                                                                          .colorScheme
                                                                          .onPrimary
                                                                          .withValues(
                                                                              alpha: 0.10)),
                                                                      onTap:
                                                                          () {
                                                                        List<ProductAddOnsModel>
                                                                            addOnsDataModel =
                                                                            widget.productDetailsModel.productAddOns!;
                                                                        List<String>
                                                                            addOnIds =
                                                                            [];
                                                                        List<String>
                                                                            addOnQty =
                                                                            [];
                                                                        var totalSum =
                                                                            0.0;
                                                                        List<
                                                                            String> productAddons = offlineCartList[
                                                                                i]
                                                                            .addOnId!
                                                                            .split(
                                                                                ',')
                                                                            .map((str) =>
                                                                                str.trim())
                                                                            .toList();

                                                                        for (int qt =
                                                                                0;
                                                                            qt <
                                                                                addOnsDataModel.length;
                                                                            qt++) {
                                                                          if (productAddons
                                                                              .contains(addOnsDataModel[qt].id)) {
                                                                            addOnIds.add(addOnsDataModel[qt].id.toString());
                                                                            addOnQty.add((int.parse(offlineCartList[i].qty.toString()) + 1).toString());
                                                                            totalSum +=
                                                                                (double.parse(addOnsDataModel[qt].price!.toString()) * (int.parse(offlineCartList[i].qty.toString()) + 1));
                                                                          }
                                                                        }
                                                                        double
                                                                            overAllTotalPrice =
                                                                            (price * (int.parse(offlineCartList[i].qty.toString()) + 1) +
                                                                                totalSum);
                                                                        setState(
                                                                            () {
                                                                          if (int.parse(offlineCartList[i].qty.toString()) <
                                                                              int.parse(widget
                                                                                  .productDetailsModel.minimumOrderQuantity!)) {
                                                                            UiUtils.setSnackBar(
                                                                                "${StringsRes.minimumQuantityAllowed} ${widget.productDetailsModel.minimumOrderQuantity!}",
                                                                                context,
                                                                                false,
                                                                                type: "2");
                                                                          } else if (widget.productDetailsModel.totalAllowedQuantity != "" &&
                                                                              int.parse(offlineCartList[i].qty.toString()) >= int.parse(widget.productDetailsModel.totalAllowedQuantity!)) {
                                                                            UiUtils.setSnackBar(
                                                                                "${StringsRes.minimumQuantityAllowed} ${widget.productDetailsModel.totalAllowedQuantity!}",
                                                                                context,
                                                                                false,
                                                                                type: "2");
                                                                          } else {
                                                                            db.insertCart(widget.productDetailsModel.id!, variantData.id!, (int.parse(offlineCartList[i].qty.toString()) + 1).toString(), addOnIds.isNotEmpty ? addOnIds.join(",").toString() : "", addOnQty.isNotEmpty ? addOnQty.join(",").toString() : "", overAllTotalPrice.toString(), context.read<SettingsCubit>().getSettings().branchId, context, edit: true, id: int.parse(offlineCartList[i].id!)).whenComplete(() async {
                                                                              context.read<OfflineCartCubit>().updateQuntity(widget.productDetailsModel, ((int.parse(offlineCartList[i].qty.toString()) + 1)).toString(), variantData.id);
                                                                              offlineCartList[i].qty = (int.parse(offlineCartList[i].qty!) + 1).toString();

                                                                              setState(() {});
                                                                            });
                                                                          }
                                                                          setState(
                                                                              () {});
                                                                        });
                                                                      },
                                                                      child: Icon(
                                                                          Icons
                                                                              .add,
                                                                          color: Theme.of(context)
                                                                              .colorScheme
                                                                              .onPrimary,
                                                                          size:
                                                                              15.0),
                                                                    ),
                                                                  ]),
                                                            ),
                                                          ]),
                                                      SingleChildScrollView(
                                                        physics:
                                                            const NeverScrollableScrollPhysics(),
                                                        scrollDirection:
                                                            Axis.horizontal,
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            variantData.variantValues !=
                                                                    ""
                                                                ? Text(
                                                                    "${variantData.variantValues!}: ",
                                                                    textAlign:
                                                                        TextAlign
                                                                            .left,
                                                                    style: TextStyle(
                                                                        color: Theme.of(context)
                                                                            .colorScheme
                                                                            .secondary,
                                                                        fontSize:
                                                                            10,
                                                                        fontWeight:
                                                                            FontWeight.w600),
                                                                  )
                                                                : Container(
                                                                    height:
                                                                        10.0),
                                                            Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              children: List.generate(
                                                                  widget
                                                                      .productDetailsModel
                                                                      .productAddOns!
                                                                      .length,
                                                                  (m) {
                                                                ProductAddOnsModel
                                                                    addOnData =
                                                                    widget
                                                                        .productDetailsModel
                                                                        .productAddOns![m];
                                                                return offlineCartList
                                                                            .isNotEmpty &&
                                                                        offlineCartList[i]
                                                                            .addOnId!
                                                                            .contains(addOnData.id!)
                                                                    ? Text(
                                                                        "${addOnData.title!}, ",
                                                                        textAlign:
                                                                            TextAlign.center,
                                                                        style: TextStyle(
                                                                            color: Theme.of(context)
                                                                                .colorScheme
                                                                                .secondary,
                                                                            fontSize:
                                                                                10,
                                                                            fontWeight:
                                                                                FontWeight.w600,
                                                                            overflow: TextOverflow.ellipsis),
                                                                        maxLines:
                                                                            1,
                                                                      )
                                                                    : Container();
                                                              }),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                          height: 5.0),
                                                      Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          InkWell(
                                                            onTap: () {
                                                              setState(() {
                                                                addToCartBottomModelSheet(
                                                                    widget
                                                                        .productDetailsModel);
                                                              });
                                                            },
                                                            child: Container(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(2.0),
                                                              decoration: DesignConfig
                                                                  .boxDecorationContainer(
                                                                      textFieldBackground,
                                                                      4.0),
                                                              child: Row(
                                                                children: [
                                                                  Text(
                                                                    UiUtils.getTranslatedLabel(
                                                                        context,
                                                                        editLabel),
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            12,
                                                                        color: Theme.of(context)
                                                                            .colorScheme
                                                                            .secondary,
                                                                        fontWeight:
                                                                            FontWeight.w500),
                                                                  ),
                                                                  Icon(
                                                                      Icons
                                                                          .edit_outlined,
                                                                      color: Theme.of(
                                                                              context)
                                                                          .colorScheme
                                                                          .secondary,
                                                                      size:
                                                                          12.0),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                          const Spacer(),
                                                          Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .end,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .end,
                                                              children: [
                                                                Text(
                                                                  context
                                                                          .read<
                                                                              SystemConfigCubit>()
                                                                          .getCurrency() +
                                                                      (overAllTotal)
                                                                          .toStringAsFixed(
                                                                              2),
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  style: TextStyle(
                                                                      color: Theme.of(
                                                                              context)
                                                                          .colorScheme
                                                                          .secondary,
                                                                      fontSize:
                                                                          14,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w700),
                                                                ),
                                                              ]),
                                                        ],
                                                      ),
                                                      const SizedBox(
                                                          height: 5.0),
                                                    ])
                                              : Container();
                                        }),
                                      ),
                                    ]),
                              ),
                              Padding(
                                padding: EdgeInsetsDirectional.only(
                                  top: widget.height! / 99.0,
                                  bottom: widget.height! / 99.0,
                                ),
                                child: DesignConfig.divider(),
                              ),
                            ],
                          ),
                        );
                      });
                    },
                  );
                });
      },
    );
  }

  Widget onlineCartWidget() {
    return ListView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: cartList.length,
        itemBuilder: (BuildContext context, i) {
          return BlocProvider<RemoveFromCartCubit>(
            create: (_) => RemoveFromCartCubit(CartRepository()),
            child: Builder(builder: (context) {
              return Container(
                margin: EdgeInsetsDirectional.only(
                    start: widget.width! / 20.0, end: widget.width! / 20.0),
                padding:
                    EdgeInsetsDirectional.only(bottom: widget.height! / 99.0),
                width: widget.width!,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsetsDirectional.only(
                          start: widget.width! / 50.0,
                          bottom: widget.height! / 99.0),
                      child: Column(
                        children: List.generate(
                            cartList[i].productDetails!.length, (j) {
                          return Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  children: List.generate(
                                      cartList[i]
                                          .productDetails![j]
                                          .variants!
                                          .length, (l) {
                                    VariantsModel variantData = cartList[i]
                                        .productDetails![j]
                                        .variants![l];
                                    double price =
                                        double.parse(variantData.specialPrice!);
                                    if (price == 0) {
                                      price = double.parse(variantData.price!);
                                    }
                                    double off = 0;
                                    if (cartList[i].specialPrice! != "0") {
                                      off = (double.parse(variantData.price!) -
                                              double.parse(
                                                  variantData.specialPrice!))
                                          .toDouble();
                                      off = off *
                                          100 /
                                          double.parse(variantData.price!)
                                              .toDouble();
                                    }
                                    var sum = 0.0;
                                    if (cartList[i]
                                        .productDetails![j]
                                        .variants![l]
                                        .addOnsData!
                                        .isNotEmpty) {
                                      for (var k = 0;
                                          k <
                                              cartList[i]
                                                  .productDetails![j]
                                                  .variants![l]
                                                  .addOnsData!
                                                  .length;
                                          k++) {
                                        sum += double.parse(cartList[i]
                                            .productDetails![j]
                                            .variants![l]
                                            .addOnsData![k]
                                            .price!
                                            .toString());
                                      }
                                    }
                                    return (cartList[i].productVariantId ==
                                            cartList[i]
                                                .productDetails![j]
                                                .variants![l]
                                                .id!)
                                        ? Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                                Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      cartList[i]
                                                                  .productDetails![
                                                                      j]
                                                                  .indicator ==
                                                              "1"
                                                          ? SvgPicture.asset(
                                                              DesignConfig
                                                                  .setSvgPath(
                                                                      "veg_icon"),
                                                              width: 15,
                                                              height: 15)
                                                          : cartList[i]
                                                                      .productDetails![
                                                                          j]
                                                                      .indicator ==
                                                                  "2"
                                                              ? SvgPicture.asset(
                                                                  DesignConfig
                                                                      .setSvgPath(
                                                                          "non_veg_icon"),
                                                                  width: 15,
                                                                  height: 15)
                                                              : const SizedBox(
                                                                  height: 15,
                                                                  width: 15.0),
                                                      const SizedBox(
                                                          width: 5.0),
                                                      Expanded(
                                                        flex: 2,
                                                        child: SizedBox(
                                                          height:
                                                              widget.height! /
                                                                  22.0,
                                                          child: Text(
                                                            cartList[i].name!,
                                                            textAlign: Directionality.of(
                                                                        context) ==
                                                                    TextDirection
                                                                        .rtl
                                                                ? TextAlign
                                                                    .right
                                                                : TextAlign
                                                                    .left,
                                                            style: TextStyle(
                                                                color: Theme.of(
                                                                        context)
                                                                    .colorScheme
                                                                    .onPrimary
                                                                    .withValues(
                                                                        alpha:
                                                                            0.76),
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                fontStyle:
                                                                    FontStyle
                                                                        .normal,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis),
                                                            maxLines: 2,
                                                          ),
                                                        ),
                                                      ),
                                                      BlocConsumer<
                                                              ManageCartCubit,
                                                              ManageCartState>(
                                                          bloc: context.read<
                                                              ManageCartCubit>(),
                                                          listener:
                                                              (context, state) {
                                                            print(state
                                                                .toString());
                                                            if (state
                                                                is ManageCartSuccess) {
                                                              if (context
                                                                          .read<
                                                                              AuthCubit>()
                                                                          .state
                                                                      is AuthInitial ||
                                                                  context
                                                                          .read<
                                                                              AuthCubit>()
                                                                          .state
                                                                      is Unauthenticated) {
                                                                return;
                                                              } else {
                                                                final currentCartModel = context
                                                                    .read<
                                                                        GetCartCubit>()
                                                                    .getCartModel();
                                                                context.read<GetCartCubit>().updateCartList(currentCartModel.updateCart(
                                                                    state.data,
                                                                    (int.parse(state
                                                                            .totalQuantity!))
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
                                                                      ..addAll(currentCartModel
                                                                              .variantId ??
                                                                          [])));
                                                                print(currentCartModel
                                                                    .variantId);
                                                                if (promoCode !=
                                                                    "") {
                                                                  context.read<ValidatePromoCodeCubit>().getValidatePromoCode(
                                                                      promoCode,
                                                                      state
                                                                          .overallAmount!
                                                                          .toStringAsFixed(
                                                                              2),
                                                                      context
                                                                          .read<
                                                                              SettingsCubit>()
                                                                          .getSettings()
                                                                          .branchId);
                                                                }
                                                              }
                                                            } else if (state
                                                                is ManageCartFailure) {
                                                              if (context
                                                                          .read<
                                                                              AuthCubit>()
                                                                          .state
                                                                      is AuthInitial ||
                                                                  context
                                                                          .read<
                                                                              AuthCubit>()
                                                                          .state
                                                                      is Unauthenticated) {
                                                                return;
                                                              } else {
                                                                UiUtils.setSnackBar(
                                                                    state
                                                                        .errorMessage,
                                                                    context,
                                                                    false,
                                                                    type: "2");
                                                              }
                                                            }
                                                          },
                                                          builder:
                                                              (context, state) {
                                                            return Container(
                                                              padding: EdgeInsetsDirectional
                                                                  .only(
                                                                      top: 3.0,
                                                                      bottom:
                                                                          3.0,
                                                                      start:
                                                                          5.0,
                                                                      end: 5.0),
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              height: 28.0,
                                                              width: widget
                                                                      .width! /
                                                                  4.8,
                                                              decoration: DesignConfig.boxDecorationContainerBorder(
                                                                  Theme.of(
                                                                          context)
                                                                      .colorScheme
                                                                      .primary,
                                                                  Theme.of(
                                                                          context)
                                                                      .colorScheme
                                                                      .primary
                                                                      .withValues(
                                                                          alpha:
                                                                              0.12),
                                                                  5.0),
                                                              child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    BlocConsumer<
                                                                            RemoveFromCartCubit,
                                                                            RemoveFromCartState>(
                                                                        bloc: context.read<
                                                                            RemoveFromCartCubit>(),
                                                                        listener:
                                                                            (context,
                                                                                state) {
                                                                          if (state
                                                                              is RemoveFromCartSuccess) {
                                                                            UiUtils.setSnackBar(
                                                                                StringsRes.deleteSuccessFully,
                                                                                context,
                                                                                false,
                                                                                type: "1");
                                                                            cartList.removeAt(i);
                                                                            context.read<GetCartCubit>().getCartUser(branchId: context.read<SettingsCubit>().getSettings().branchId);
                                                                          } else if (state
                                                                              is RemoveFromCartFailure) {
                                                                            UiUtils.setSnackBar(
                                                                                state.errorMessage,
                                                                                context,
                                                                                false,
                                                                                type: "2");
                                                                          }
                                                                        },
                                                                        builder:
                                                                            (context,
                                                                                state) {
                                                                          return InkWell(
                                                                            overlayColor:
                                                                                WidgetStateProperty.all(Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.10)),
                                                                            onTap:
                                                                                () {
                                                                              setState(() {
                                                                                if (int.parse(cartList[i].qty!) <= int.parse(cartList[i].minimumOrderQuantity!)) {
                                                                                  context.read<RemoveFromCartCubit>().removeFromCart(cartId: cartList[i].productVariantId, branchId: context.read<SettingsCubit>().getSettings().branchId);
                                                                                } else if (int.parse(cartList[i].qty!) == 1) {
                                                                                  context.read<RemoveFromCartCubit>().removeFromCart(cartId: cartList[i].productVariantId, branchId: context.read<SettingsCubit>().getSettings().branchId);
                                                                                } else {
                                                                                  List<AddOnsDataModel> addOnsDataModel = variantData.addOnsData!;
                                                                                  List<String> addOnIds = [];
                                                                                  List<String> addOnQty = [];
                                                                                  for (int qt = 0; qt < addOnsDataModel.length; qt++) {
                                                                                    addOnIds.add(addOnsDataModel[qt].id.toString());
                                                                                    addOnQty.add((int.parse(cartList[i].qty.toString()) - 1).toString());
                                                                                  }
                                                                                  context.read<ManageCartCubit>().manageCartUser(productVariantId: cartList[i].productVariantId, isSavedForLater: "0", qty: (int.parse(cartList[i].qty!) - 1).toString(), addOnId: addOnIds.isNotEmpty ? addOnIds.join(",").toString() : "", addOnQty: addOnQty.isNotEmpty ? addOnQty.join(",").toString() : "", branchId: context.read<SettingsCubit>().getSettings().branchId, cartId: cartList[i].cartId);
                                                                                  cartList[i].qty = (int.parse(cartList[i].qty!) - 1).toString();
                                                                                }
                                                                              });
                                                                            },
                                                                            child: Icon(Icons.remove,
                                                                                color: Theme.of(context).colorScheme.onPrimary,
                                                                                size: 15.0),
                                                                          );
                                                                        }),
                                                                    Spacer(),
                                                                    Text(
                                                                        cartList[i]
                                                                            .qty
                                                                            .toString(),
                                                                        textAlign:
                                                                            TextAlign
                                                                                .center,
                                                                        style:
                                                                            TextStyle(
                                                                          color: Theme.of(context)
                                                                              .colorScheme
                                                                              .onPrimary,
                                                                          fontSize:
                                                                              10,
                                                                          fontWeight:
                                                                              FontWeight.w700,
                                                                          fontStyle:
                                                                              FontStyle.normal,
                                                                        )),
                                                                    const Spacer(),
                                                                    InkWell(
                                                                      overlayColor: WidgetStateProperty.all(Theme.of(
                                                                              context)
                                                                          .colorScheme
                                                                          .onPrimary
                                                                          .withValues(
                                                                              alpha: 0.10)),
                                                                      onTap:
                                                                          () {
                                                                        setState(
                                                                            () {
                                                                          if (int.parse(cartList[i].qty!) <
                                                                              int.parse(cartList[i].productDetails![j].minimumOrderQuantity!)) {
                                                                            Navigator.pop(context);
                                                                            UiUtils.setSnackBar(
                                                                                "${StringsRes.minimumQuantityAllowed} ${cartList[i].productDetails![j].minimumOrderQuantity!}",
                                                                                context,
                                                                                false,
                                                                                type: "2");
                                                                          } else if (cartList[i].productDetails![j].totalAllowedQuantity != "" && int.parse(cartList[i].qty!) >= int.parse(cartList[i].productDetails![j].totalAllowedQuantity!)) {
                                                                            cartList[i].qty =
                                                                                cartList[i].productDetails![j].totalAllowedQuantity!;
                                                                            UiUtils.setSnackBar(
                                                                                "${StringsRes.minimumQuantityAllowed} ${cartList[i].productDetails![j].totalAllowedQuantity!}",
                                                                                context,
                                                                                false,
                                                                                type: "2");
                                                                          } else {
                                                                            List<AddOnsDataModel>
                                                                                addOnsDataModel =
                                                                                variantData.addOnsData!;
                                                                            List<String>
                                                                                addOnIds =
                                                                                [];
                                                                            List<String>
                                                                                addOnQty =
                                                                                [];
                                                                            for (int qt = 0;
                                                                                qt < addOnsDataModel.length;
                                                                                qt++) {
                                                                              addOnIds.add(addOnsDataModel[qt].id.toString());
                                                                              addOnQty.add((int.parse(addOnsDataModel[qt].qty.toString()) + 1).toString());
                                                                            }
                                                                            context.read<ManageCartCubit>().manageCartUser(
                                                                                productVariantId: cartList[i].productVariantId,
                                                                                isSavedForLater: "0",
                                                                                qty: (int.parse(cartList[i].qty!) + 1).toString(),
                                                                                addOnId: addOnIds.isNotEmpty ? addOnIds.join(",").toString() : "",
                                                                                addOnQty: addOnQty.isNotEmpty ? addOnQty.join(",").toString() : "",
                                                                                branchId: context.read<SettingsCubit>().getSettings().branchId,
                                                                                cartId: cartList[i].cartId);
                                                                            cartList[i].qty =
                                                                                (int.parse(cartList[i].qty!) + 1).toString();
                                                                          }
                                                                        });
                                                                      },
                                                                      child: Icon(
                                                                          Icons
                                                                              .add,
                                                                          color: Theme.of(context)
                                                                              .colorScheme
                                                                              .onPrimary,
                                                                          size:
                                                                              15.0),
                                                                    ),
                                                                  ]),
                                                            );
                                                          }),
                                                    ]),
                                                SingleChildScrollView(
                                                  physics:
                                                      const NeverScrollableScrollPhysics(),
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      variantData.variantValues !=
                                                              ""
                                                          ? Text(
                                                              "${variantData.variantValues!}: ",
                                                              textAlign:
                                                                  TextAlign
                                                                      .left,
                                                              style: TextStyle(
                                                                  color: Theme.of(
                                                                          context)
                                                                      .colorScheme
                                                                      .secondary,
                                                                  fontSize: 10,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600),
                                                            )
                                                          : Container(
                                                              height: 10.0),
                                                      cartList[i]
                                                              .productDetails![
                                                                  j]
                                                              .variants![l]
                                                              .addOnsData!
                                                              .isNotEmpty
                                                          ? Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              children: List.generate(
                                                                  cartList[i]
                                                                      .productDetails![
                                                                          j]
                                                                      .variants![
                                                                          l]
                                                                      .addOnsData!
                                                                      .length,
                                                                  (m) {
                                                                AddOnsDataModel
                                                                    addOnData =
                                                                    variantData
                                                                        .addOnsData![m];
                                                                return Text(
                                                                  "${addOnData.title!}, ",
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  style: TextStyle(
                                                                      color: Theme.of(
                                                                              context)
                                                                          .colorScheme
                                                                          .secondary,
                                                                      fontSize:
                                                                          10,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis),
                                                                  maxLines: 1,
                                                                );
                                                              }),
                                                            )
                                                          : Container(
                                                              height: 10.0),
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(height: 5.0),
                                                Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    InkWell(
                                                      onTap: () {
                                                        setState(() {
                                                          addToCartBottomModelSheet(
                                                              widget
                                                                  .productDetailsModel);
                                                        });
                                                      },
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(2.0),
                                                        decoration: DesignConfig
                                                            .boxDecorationContainer(
                                                                textFieldBackground,
                                                                4.0),
                                                        child: Row(
                                                          children: [
                                                            Text(
                                                              UiUtils
                                                                  .getTranslatedLabel(
                                                                      context,
                                                                      editLabel),
                                                              style: TextStyle(
                                                                  fontSize: 12,
                                                                  color: Theme.of(
                                                                          context)
                                                                      .colorScheme
                                                                      .secondary,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500),
                                                            ),
                                                            Icon(
                                                                Icons
                                                                    .edit_outlined,
                                                                color: Theme.of(
                                                                        context)
                                                                    .colorScheme
                                                                    .secondary,
                                                                size: 12.0),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    const Spacer(),
                                                    Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .end,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .end,
                                                        children: [
                                                          Text(
                                                            context
                                                                    .read<
                                                                        SystemConfigCubit>()
                                                                    .getCurrency() +
                                                                (double.parse(price.toString()) *
                                                                            int.parse(cartList[i]
                                                                                .qty!) +
                                                                        (sum *
                                                                            int.parse(cartList[i]
                                                                                .qty!)))
                                                                    .toStringAsFixed(
                                                                        2),
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                                color: Theme.of(
                                                                        context)
                                                                    .colorScheme
                                                                    .secondary,
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700),
                                                          ),
                                                        ]),
                                                  ],
                                                ),
                                                const SizedBox(height: 5.0),
                                              ])
                                        : Container();
                                  }),
                                ),
                              ]);
                        }),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsetsDirectional.only(
                        top: widget.height! / 99.0,
                        bottom: widget.height! / 99.0,
                      ),
                      child: DesignConfig.divider(),
                    ),
                  ],
                ),
              );
            }),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (BuildContext context) {
      return Builder(builder: (context) {
        return LayoutBuilder(builder: (context, BoxConstraints boxConstraints) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                  fit: FlexFit.loose,
                  child: (context.read<AuthCubit>().state is AuthInitial ||
                          context.read<AuthCubit>().state is Unauthenticated)
                      ? offlineCartWidget()
                      : onlineCartWidget()),
              SizedBox(
                width: widget.width!,
                child: ButtonContainer(
                  color: Theme.of(context).colorScheme.onPrimary,
                  height: widget.height,
                  width: widget.width,
                  text:
                      "${UiUtils.getTranslatedLabel(context, addNewItemLabel)}",
                  top: 0,
                  bottom: widget.height! / 60.0,
                  start: widget.width! / 20.0,
                  end: widget.width! / 20.0,
                  status: status,
                  borderColor: Theme.of(context).colorScheme.onPrimary,
                  textColor: white,
                  onPressed: () {
                    Navigator.pop(context);
                    addToCartBottomModelSheet(widget.productDetailsModel);
                  },
                ),
              ),
            ],
          );
        });
      });
    });
  }
}
