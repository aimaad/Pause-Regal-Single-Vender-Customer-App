import 'package:erestroSingleVender/data/model/attributesModel.dart';
import 'package:erestroSingleVender/data/model/minMaxPriceModel.dart';
import 'package:erestroSingleVender/data/model/productAddOnsModel.dart';
import 'package:erestroSingleVender/data/model/variantAttributesModel.dart';
import 'package:erestroSingleVender/data/model/variantsModel.dart';

class ProductDetailsModel {
  String? sales;
  String? stockType;
  String? isPricesInclusiveTax;
  String? type;
  String? attrValueIds;
  String? ownerName;
  String? id;
  String? stock;
  String? name;
  String? categoryId;
  String? shortDescription;
  String? slug;
  String? totalAllowedQuantity;
  String? minimumOrderQuantity;
  String? quantityStepSize;
  String? codAllowed;
  String? isSpicy;
  String? rowOrder;
  String? rating;
  String? noOfRatings;
  String? image;
  String? isCancelable;
  String? cancelableTill;
  String? indicator;
  List<String>? highlights;
  String? availability;
  String? categoryName;
  String? taxPercentage;
  String? bestSeller;
  String? isBranchOpen;
  List<String>? tags;

  List<AttributesModel>? attributes;
  List<ProductAddOnsModel>? productAddOns;
  List<VariantsModel>? variants;
  MinMaxPriceModel? minMaxPrice;
  bool? isPurchased;
  String? isFavorite;
  String? imageMd;
  String? imageSm;
  List<VariantAttributesModel>? variantAttributes;
  String? total;

  ProductDetailsModel(
      {this.sales,
      this.stockType,
      this.isPricesInclusiveTax,
      this.type,
      this.attrValueIds,
      this.ownerName,
      this.id,
      this.stock,
      this.name,
      this.categoryId,
      this.shortDescription,
      this.slug,
      this.totalAllowedQuantity,
      this.minimumOrderQuantity,
      this.quantityStepSize,
      this.codAllowed,
      this.isSpicy,
      this.rowOrder,
      this.rating,
      this.noOfRatings,
      this.image,
      this.isCancelable,
      this.cancelableTill,
      this.indicator,
      this.highlights,
      this.availability,
      this.categoryName,
      this.taxPercentage,
      this.bestSeller,
      this.isBranchOpen,
      this.tags,
      // this.reviewImages,
      this.attributes,
      this.productAddOns,
      this.variants,
      this.minMaxPrice,
      this.isPurchased,
      this.isFavorite,
      this.imageMd,
      this.imageSm,
      this.variantAttributes,
      this.total});

  ProductDetailsModel.fromJson(Map<String, dynamic> json) {
    sales = json['sales'] ?? "";
    stockType = json['stock_type'] ?? "";
    isPricesInclusiveTax = json['is_prices_inclusive_tax'] ?? "";
    type = json['type'] ?? "";
    attrValueIds = json['attr_value_ids'] ?? "";
    ownerName = json['owner_name'] ?? "";
    id = json['id'] ?? "";
    stock = json['stock'] ?? "";
    name = json['name'] ?? "";
    categoryId = json['category_id'] ?? "";
    shortDescription = json['short_description'] ?? "";
    slug = json['slug'] ?? "";
    totalAllowedQuantity = json['total_allowed_quantity'] ?? "";
    minimumOrderQuantity = json['minimum_order_quantity'] ?? "";
    quantityStepSize = json['quantity_step_size'] ?? "";
    codAllowed = json['cod_allowed'] ?? "";
    isSpicy = json['is_spicy'] ?? "";
    rowOrder = json['row_order'] ?? "";
    rating = json['rating'] ?? "";
    noOfRatings = json['no_of_ratings'] ?? "";
    image = json['image'] ?? "";
    isCancelable = json['is_cancelable'] ?? "";
    cancelableTill = json['cancelable_till'] ?? "";
    indicator = json['indicator'] ?? "";
    highlights = json['highlights'] == null
        ? List<String>.from([])
        : (json['highlights'] as List).map((e) => e.toString()).toList();
    tags = json['tags'] == null
        ? List<String>.from([])
        : (json['tags'] as List).map((e) => e.toString()).toList();
    availability = json['availability'].toString();
    categoryName = json['category_name'];
    taxPercentage = json['tax_percentage'];
    bestSeller = json['best_seller'] ?? "";
    isBranchOpen = json['is_branch_open'] ?? "0";

    if (json['attributes'] != null) {
      attributes = <AttributesModel>[];
      json['attributes'].forEach((v) {
        attributes!.add(AttributesModel.fromJson(v));
      });
    }
    if (json['product_add_ons'] != null) {
      productAddOns = <ProductAddOnsModel>[];
      json['product_add_ons'].forEach((v) {
        productAddOns!.add(ProductAddOnsModel.fromJson(v));
      });
    }
    if (json['variants'] != null) {
      variants = <VariantsModel>[];
      json['variants'].forEach((v) {
        variants!.add(VariantsModel.fromJson(v));
      });
    }
    minMaxPrice = json['min_max_price'] != null
        ? MinMaxPriceModel.fromJson(json['min_max_price'])
        : null;
    isPurchased = json['is_purchased'];
    isFavorite = json['is_favorite'];
    imageMd = json['image_md'];
    imageSm = json['image_sm'];
    if (json['variant_attributes'] != null) {
      variantAttributes = <VariantAttributesModel>[];
      json['variant_attributes'].forEach((v) {
        variantAttributes!.add(VariantAttributesModel.fromJson(v));
      });
    }
    total = json['total'];
  }
}
