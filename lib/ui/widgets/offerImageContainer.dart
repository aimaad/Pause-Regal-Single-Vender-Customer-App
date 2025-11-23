import 'package:erestroSingleVender/app/routes.dart';
import 'package:erestroSingleVender/cubit/auth/authCubit.dart';
import 'package:erestroSingleVender/cubit/cart/getCartCubit.dart';
import 'package:erestroSingleVender/data/model/bestOfferModel.dart';
import 'package:erestroSingleVender/data/model/sectionsModel.dart';
import 'package:erestroSingleVender/ui/styles/design.dart';
import 'package:erestroSingleVender/ui/widgets/bottomSheetContainer.dart';
import 'package:erestroSingleVender/ui/widgets/brachCloseDialog.dart';
import 'package:erestroSingleVender/ui/widgets/productUnavailableDialog.dart';
import 'package:erestroSingleVender/utils/SqliteData.dart';
import 'package:erestroSingleVender/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OfferImageContainer extends StatefulWidget {
  final List<BestOfferModel> bestOfferList;
  final double? width, height;
  final int index;
  const OfferImageContainer(
      {Key? key,
      required this.bestOfferList,
      this.width,
      this.height,
      required this.index})
      : super(key: key);

  @override
  State<OfferImageContainer> createState() => _OfferImageContainerState();
}

class _OfferImageContainerState extends State<OfferImageContainer> {
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
    return GestureDetector(
      onTap: () {
        if (widget.bestOfferList[widget.index].type == "default") {
        } else if (widget.bestOfferList[widget.index].type == "categories") {
          Navigator.of(context).pushNamed(Routes.cuisineDetail, arguments: {
            'categoryId': widget.bestOfferList[widget.index].data![0].id!,
            'name': widget.bestOfferList[widget.index].data![0].text!
          });
        } else if (widget.bestOfferList[widget.index].type == "products") {
          if (widget.bestOfferList[widget.index].data![0].isBranchOpen == "1") {
            ProductDetails productDetails = ProductDetails(
                sales: widget.bestOfferList[widget.index].data![0].sales,
                stockType:
                    widget.bestOfferList[widget.index].data![0].stockType,
                calories: widget.bestOfferList[widget.index].data![0].calories,
                status: widget.bestOfferList[widget.index].data![0].status,
                isPricesInclusiveTax: widget
                    .bestOfferList[widget.index].data![0].isPricesInclusiveTax,
                taxId: widget.bestOfferList[widget.index].data![0].taxId,
                type: widget.bestOfferList[widget.index].data![0].type,
                attrValueIds:
                    widget.bestOfferList[widget.index].data![0].attrValueIds,
                branchId: widget.bestOfferList[widget.index].data![0].branchId,
                ownerName:
                    widget.bestOfferList[widget.index].data![0].ownerName,
                id: widget.bestOfferList[widget.index].data![0].id,
                stock: widget.bestOfferList[widget.index].data![0].stock,
                name: widget.bestOfferList[widget.index].data![0].name,
                categoryId:
                    widget.bestOfferList[widget.index].data![0].categoryId,
                availableTime:
                    widget.bestOfferList[widget.index].data![0].availableTime,
                startTime:
                    widget.bestOfferList[widget.index].data![0].startTime,
                endTime: widget.bestOfferList[widget.index].data![0].endTime,
                shortDescription: widget
                    .bestOfferList[widget.index].data![0].shortDescription,
                slug: widget.bestOfferList[widget.index].data![0].slug,
                totalAllowedQuantity: widget
                    .bestOfferList[widget.index].data![0].totalAllowedQuantity,
                minimumOrderQuantity: widget
                    .bestOfferList[widget.index].data![0].minimumOrderQuantity,
                codAllowed:
                    widget.bestOfferList[widget.index].data![0].codAllowed,
                rowOrder: widget.bestOfferList[widget.index].data![0].rowOrder,
                rating: widget.bestOfferList[widget.index].data![0].rating,
                noOfRatings:
                    widget.bestOfferList[widget.index].data![0].noOfRatings,
                image: widget.bestOfferList[widget.index].data![0].image,
                isCancelable:
                    widget.bestOfferList[widget.index].data![0].isCancelable,
                cancelableTill:
                    widget.bestOfferList[widget.index].data![0].cancelableTill,
                indicator:
                    widget.bestOfferList[widget.index].data![0].indicator,
                highlights:
                    widget.bestOfferList[widget.index].data![0].highlights,
                availability:
                    widget.bestOfferList[widget.index].data![0].availability,
                categoryName:
                    widget.bestOfferList[widget.index].data![0].categoryName,
                categorySlug:
                    widget.bestOfferList[widget.index].data![0].categorySlug,
                taxPercentage:
                    widget.bestOfferList[widget.index].data![0].taxPercentage,
                reviewImages:
                    widget.bestOfferList[widget.index].data![0].reviewImages,
                attributes:
                    widget.bestOfferList[widget.index].data![0].attributes,
                productAddOns:
                    widget.bestOfferList[widget.index].data![0].productAddOns,
                variants: widget.bestOfferList[widget.index].data![0].variants,
                minMaxPrice:
                    widget.bestOfferList[widget.index].data![0].minMaxPrice,
                isPurchased:
                    widget.bestOfferList[widget.index].data![0].isPurchased,
                relativePath:
                    widget.bestOfferList[widget.index].data![0].relativePath,
                otherImagesRelativePath: widget.bestOfferList[widget.index]
                    .data![0].otherImagesRelativePath,
                isFavorite:
                    widget.bestOfferList[widget.index].data![0].isFavorite,
                imageMd: widget.bestOfferList[widget.index].data![0].imageMd,
                imageSm: widget.bestOfferList[widget.index].data![0].imageSm,
                variantAttributes: widget
                    .bestOfferList[widget.index].data![0].variantAttributes,
                total: widget.bestOfferList[widget.index].data![0].total,
                isBranchOpen:
                    widget.bestOfferList[widget.index].data![0].isBranchOpen,
                isSpicy: widget.bestOfferList[widget.index].data![0].isSpicy);
            bool check = getStoreOpenStatus(
                productDetails.startTime!, productDetails.endTime!);
            if (productDetails.availableTime == "1") {
              if (check == true) {
                addToCartBottomModelSheet(context
                    .read<GetCartCubit>()
                    .getProductDetailsData(
                        productDetails.id!, productDetails)[0]);
              } else {
                showDialog(
                    context: context,
                    builder: (_) => ProductUnavailableDialog(
                        startTime: productDetails.startTime,
                        endTime: productDetails.endTime,
                        width: widget.width,
                        height: widget.height));
              }
            } else {
              addToCartBottomModelSheet(context
                  .read<GetCartCubit>()
                  .getProductDetailsData(
                      productDetails.id!, productDetails)[0]);
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
        }
      },
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(8.0)),
        child: DesignConfig.imageWidgets(
            widget.bestOfferList[widget.index].image!,
            widget.height! / 4.7,
            widget.width! / 2.75,
            "2"),
      ),
    );
  }
}
