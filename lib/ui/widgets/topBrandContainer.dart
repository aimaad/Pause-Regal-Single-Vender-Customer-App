import 'package:erestroSingleVender/app/routes.dart';
import 'package:erestroSingleVender/cubit/auth/authCubit.dart';
import 'package:erestroSingleVender/cubit/cart/getCartCubit.dart';
import 'package:erestroSingleVender/cubit/favourite/updateFavouriteProduct.dart';
import 'package:erestroSingleVender/cubit/systemConfig/systemConfigCubit.dart';
import 'package:erestroSingleVender/data/model/sectionsModel.dart';
import 'package:erestroSingleVender/ui/styles/color.dart';
import 'package:erestroSingleVender/ui/styles/design.dart';
import 'package:erestroSingleVender/ui/widgets/bottomSheetContainer.dart';
import 'package:erestroSingleVender/ui/widgets/brachCloseDialog.dart';
import 'package:erestroSingleVender/ui/widgets/favoriteContainer.dart';
import 'package:erestroSingleVender/ui/widgets/productUnavailableDialog.dart';
import 'package:erestroSingleVender/utils/SqliteData.dart';
import 'package:erestroSingleVender/utils/constants.dart';
import 'package:erestroSingleVender/utils/string.dart';
import 'package:erestroSingleVender/utils/uiUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TopBrandContainer extends StatefulWidget {
  final List<ProductDetails> topProductList;
  final double? width, height, price, off;
  final int index;
  final String? from;
  const TopBrandContainer(
      {Key? key,
      required this.topProductList,
      this.width,
      this.height,
      required this.index,
      required this.from,
      this.price,
      this.off})
      : super(key: key);

  @override
  State<TopBrandContainer> createState() => _TopBrandContainerState();
}

class _TopBrandContainerState extends State<TopBrandContainer> {
  var db = DatabaseHelper();
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

  @override
  Widget build(BuildContext context) {
    RegExp regex = RegExp(r'([^\d]00)(?=[^\d]|$)');
    return BlocProvider<UpdateProductFavoriteStatusCubit>(
      create: (context) => UpdateProductFavoriteStatusCubit(),
      child: Builder(builder: (context) {
        return GestureDetector(
          onTap: () {
            if (widget.topProductList[widget.index].isBranchOpen == "1") {
              bool check = getStoreOpenStatus(
                  widget.topProductList[widget.index].startTime!,
                  widget.topProductList[widget.index].endTime!);
              if (widget.topProductList[widget.index].availableTime == "1") {
                if (check == true) {
                  addToCartBottomModelSheet(context
                      .read<GetCartCubit>()
                      .getProductDetailsData(
                          widget.topProductList[widget.index].id!,
                          widget.topProductList[widget.index])[0]);
                } else {
                  showDialog(
                      context: context,
                      builder: (_) => ProductUnavailableDialog(
                          startTime:
                              widget.topProductList[widget.index].startTime,
                          endTime: widget.topProductList[widget.index].endTime,
                          width: widget.width,
                          height: widget.height));
                }
              } else {
                addToCartBottomModelSheet(context
                    .read<GetCartCubit>()
                    .getProductDetailsData(
                        widget.topProductList[widget.index].id!,
                        widget.topProductList[widget.index])[0]);
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
            alignment: Alignment.topLeft,
            margin: EdgeInsetsDirectional.only(
                start: widget.width! / 20.0,
                top: widget.height! / 99.0,
                bottom: widget.height! / 99.0),
            padding: EdgeInsetsDirectional.only(
                start: 8.0, top: 8.0, bottom: 8.0, end: 8.0),
            width: widget.from == "home" ? widget.width! / 2.4 : widget.width,
            height:
                widget.from == "home" ? widget.height! / 2.85 : widget.height!,
            decoration: DesignConfig.boxDecorationContainerCardShadow(
                Theme.of(context).colorScheme.onSurface,
                Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.1),
                8.0,
                0,
                0,
                8,
                0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(4.0)),
                        child: SizedBox(
                          height: double.maxFinite,
                          child: UiUtils.customColorFiltered(
                            context,
                            hideFilter: widget.topProductList[widget.index]
                                    .isBranchOpen ==
                                "1",
                            child: ShaderMask(
                                shaderCallback: (Rect bounds) {
                                  return LinearGradient(
                                    begin: Alignment.center,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      shaderColor,
                                      widget.off!.toStringAsFixed(2) == "0.00"
                                          ? shaderColor
                                          : black
                                    ],
                                  ).createShader(bounds);
                                },
                                blendMode: BlendMode.darken,
                                child: DesignConfig.imageWidgets(
                                    widget.topProductList[widget.index].image!,
                                    // widget.height! / 5.5,
                                    double.maxFinite,
                                    widget.from == "home"
                                        ? widget.width! / 2.4
                                        : widget.width,
                                    "2")),
                          ),
                        ),
                      ),
                      Positioned.directional(
                        textDirection: Directionality.of(context),
                        start: 10.0,
                        bottom: 10.0,
                        child: widget.off!.toStringAsFixed(2) == "0.00"
                            ? const SizedBox()
                            : Text(
                                "${widget.off!.toStringAsFixed(2).replaceAll(regex, '')}${StringsRes.percentSymbol} ${StringsRes.off}",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    fontStyle: FontStyle.normal)),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 8.0),
                Row(
                  children: [
                    widget.topProductList[widget.index].indicator == "1"
                        ? SvgPicture.asset(DesignConfig.setSvgPath("veg_icon"),
                            width: 15, height: 15)
                        : widget.topProductList[widget.index].indicator == "2"
                            ? SvgPicture.asset(
                                DesignConfig.setSvgPath("non_veg_icon"),
                                width: 15,
                                height: 15)
                            : Row(
                                children: [
                                  SvgPicture.asset(
                                      DesignConfig.setSvgPath("veg_icon"),
                                      width: 15,
                                      height: 15),
                                  const SizedBox(width: 2.0),
                                  SvgPicture.asset(
                                      DesignConfig.setSvgPath("non_veg_icon"),
                                      width: 15,
                                      height: 15),
                                ],
                              ),
                    widget.topProductList[widget.index].rating == "0"
                        ? const SizedBox()
                        : Padding(
                            padding:
                                const EdgeInsetsDirectional.only(start: 8.0),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.of(context).pushNamed(
                                    Routes.productRatingDetail,
                                    arguments: {
                                      'productId': widget
                                          .topProductList[widget.index].id!
                                    });
                              },
                              child: Row(
                                children: [
                                  SvgPicture.asset(
                                      DesignConfig.setSvgPath("rating"),
                                      fit: BoxFit.scaleDown,
                                      width: 7.0,
                                      height: 12.3),
                                  const SizedBox(width: 3.4),
                                  Text(
                                    double.parse(widget
                                            .topProductList[widget.index]
                                            .rating!)
                                        .toStringAsFixed(1),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                          ),
                    const Spacer(),
                    FavoriteContainer(
                        from: "product",
                        productDetails: widget.topProductList[widget.index])
                  ],
                ),
                const SizedBox(height: 6.0),
                Text(widget.topProductList[widget.index].categoryName!,
                    textAlign: TextAlign.left,
                    maxLines: 1,
                    style: TextStyle(
                        color: Theme.of(context)
                            .colorScheme
                            .onPrimary
                            .withValues(alpha: 0.76),
                        fontSize: 12,
                        fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 6.0),
                Text(widget.topProductList[widget.index].name!,
                    textAlign: TextAlign.start,
                    maxLines: 2,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700),
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 6.0),
                Row(
                  children: [
                    Text(
                        context.read<SystemConfigCubit>().getCurrency() +
                            widget.price.toString(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                            fontSize: 16,
                            fontWeight: FontWeight.w700)),
                    SizedBox(width: widget.width! / 99.0),
                    widget.off!.toStringAsFixed(2) == "0.00"
                        ? const SizedBox()
                        : Text(
                            "${context.read<SystemConfigCubit>().getCurrency()}${widget.topProductList[widget.index].variants![0].price!}",
                            style: TextStyle(
                                decoration: TextDecoration.lineThrough,
                                letterSpacing: 0,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimary
                                    .withValues(alpha: 0.76),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                overflow: TextOverflow.ellipsis),
                            maxLines: 1,
                          ),
                  ],
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
