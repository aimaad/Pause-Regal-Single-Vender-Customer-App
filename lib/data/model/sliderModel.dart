import 'package:erestroSingleVender/data/model/attributesModel.dart';
import 'package:erestroSingleVender/data/model/minMaxPriceModel.dart';
import 'package:erestroSingleVender/data/model/productAddOnsModel.dart';
import 'package:erestroSingleVender/data/model/reviewImagesModel.dart';
import 'package:erestroSingleVender/data/model/variantAttributesModel.dart';
import 'package:erestroSingleVender/data/model/variantsModel.dart';

class SliderModel {
  String? id;
  String? type;
  String? typeId;
  String? branchId;
  String? image;
  String? dateAdded;
  List<Data>? data;

  SliderModel(
      {this.id,
      this.type,
      this.typeId,
      this.branchId,
      this.image,
      this.dateAdded,
      this.data});

  SliderModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    type = json['type'];
    typeId = json['type_id'];
    branchId = json['branch_id'];
    image = json['image'];
    dateAdded = json['date_added'];

    data = json['data'] == null
        ? []
        : (json['data'] as List).map((e) => Data.fromJson(e ?? {})).toList();
  }
}

class Data {
  String? id;
  String? name;
  String? parentId;
  String? slug;
  String? image;
  String? banner;
  String? rowOrder;
  String? status;
  String? clicks;

  String? text;
  State? state;
  String? icon;
  String? level;
  String? total;
  String? sales;
  String? stockType;
  String? calories;
  String? isPricesInclusiveTax;
  String? taxId;
  String? type;
  String? attrValueIds;
  String? branchId;
  String? ownerName;
  String? stock;
  String? categoryId;
  String? shortDescription;
  String? totalAllowedQuantity;
  String? minimumOrderQuantity;
  String? quantityStepSize;
  String? codAllowed;
  String? isSpicy;
  String? rating;
  String? noOfRatings;
  String? isCancelable;
  String? cancelableTill;
  String? indicator;
  List<String>? highlights;
  String? availability;
  String? categoryName;
  String? categorySlug;
  String? availableTime;
  String? startTime;
  String? endTime;
  String? taxPercentage;
  String? bestSeller;
  String? isBranchOpen;
  List<ReviewImagesModel>? reviewImages;
  List<AttributesModel>? attributes;
  List<ProductAddOnsModel>? productAddOns;
  List<VariantsModel>? variants;
  MinMaxPriceModel? minMaxPrice;
  bool? isPurchased;
  String? relativePath;
  List<String>? otherImagesRelativePath;
  String? isFavorite;
  String? imageMd;
  String? imageSm;
  List<VariantAttributesModel>? variantAttributes;

  Data({
    this.id,
    this.name,
    this.parentId,
    this.slug,
    this.image,
    this.banner,
    this.rowOrder,
    this.status,
    this.clicks,
    this.text,
    this.state,
    this.icon,
    this.level,
    this.total,
    this.sales,
    this.stockType,
    this.calories,
    this.isPricesInclusiveTax,
    this.taxId,
    this.type,
    this.attrValueIds,
    this.branchId,
    this.ownerName,
    this.stock,
    this.categoryId,
    this.shortDescription,
    this.totalAllowedQuantity,
    this.minimumOrderQuantity,
    this.quantityStepSize,
    this.codAllowed,
    this.isSpicy,
    this.rating,
    this.noOfRatings,
    this.isCancelable,
    this.cancelableTill,
    this.indicator,
    this.highlights,
    this.availability,
    this.categoryName,
    this.categorySlug,
    this.availableTime,
    this.startTime,
    this.endTime,
    this.taxPercentage,
    this.bestSeller,
    this.isBranchOpen,
    this.reviewImages,
    this.attributes,
    this.productAddOns,
    this.variants,
    this.minMaxPrice,
    this.isPurchased,
    this.relativePath,
    this.otherImagesRelativePath,
    this.isFavorite,
    this.imageMd,
    this.imageSm,
    //  this.variantAttributes
  });

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? "";
    name = json['name'] ?? "";
    parentId = json['parent_id'] ?? "";
    slug = json['slug'] ?? "";
    image = json['image'] ?? "";
    banner = json['banner'] ?? "";
    rowOrder = json['row_order'] ?? "";
    status = json['status'] ?? "";
    clicks = json['clicks'] ?? "";

    text = json['text'] ?? "";
    state = State.fromJson(json['state'] ?? {});
    icon = json['icon'] ?? "";
    level = json['level'] == null ? "" : json['level'].toString();
    total = json['total'] == null ? "" : json['total'].toString();
    sales = json['sales'] ?? "";
    calories = json['calories'] ?? "";
    stockType = json['stock_type'] ?? "";
    isPricesInclusiveTax = json['is_prices_inclusive_tax'] ?? "";
    taxId = json['tax_id'] ?? "";
    type = json['type'] ?? "";
    attrValueIds = json['attr_value_ids'] ?? "";
    branchId = json['branch_id'] ?? "";
    ownerName = json['owner_name'] ?? "";
    stock = json['stock'] ?? "";
    categoryId = json['category_id'] ?? "";
    shortDescription = json['short_description'] ?? "";
    totalAllowedQuantity = json['total_allowed_quantity'] ?? "";
    minimumOrderQuantity = json['minimum_order_quantity'] ?? "";
    quantityStepSize = json['quantity_step_size'] ?? "";
    codAllowed = json['cod_allowed'] ?? "";
    isSpicy = json['is_spicy'] ?? "";
    rating = json['rating'] ?? "";
    noOfRatings = json['no_of_ratings'] ?? "";
    isCancelable = json['is_cancelable'] ?? "";
    cancelableTill = json['cancelable_till'] ?? "";
    indicator = json['indicator'] ?? "";
    highlights = json['highlights'] == null
        ? List<String>.from([])
        : (json['highlights'] as List).map((e) => e.toString()).toList();
    availability = json['availability'].toString();
    categoryName = json['category_name'] ?? "";
    categorySlug = json[''] ?? "category_slug";
    availableTime = json['available_time'] ?? "";
    startTime = json['start_time'] ?? "";
    endTime = json['end_time'] ?? "";
    taxPercentage = json['tax_percentage'] ?? "";
    bestSeller = json['best_seller'] ?? "";
    isBranchOpen = json['is_branch_open'] ?? "0";
    if (json['review_images'] != null) {
      reviewImages = <ReviewImagesModel>[];
      json['review_images'].forEach((v) {
        reviewImages!.add(ReviewImagesModel.fromJson(v));
      });
    }
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
    } else {
      variants = [];
    }
    minMaxPrice = json['min_max_price'] != null
        ? MinMaxPriceModel.fromJson(json['min_max_price'])
        : null;
    isPurchased = json['is_purchased'] ?? false;
    relativePath = json['relative_path'] ?? "";
    otherImagesRelativePath = json['other_images_relative_path'] == null
        ? List<String>.from([])
        : (json['other_images_relative_path'] as List)
            .map((e) => e.toString())
            .toList();
    isFavorite = json['is_favorite'] ?? "";
    imageMd = json['image_md'] ?? "";
    imageSm = json['image_sm'] ?? "";
  }
}

class State {
  bool? opened;

  State({this.opened});

  State.fromJson(Map<String, dynamic> json) {
    opened = json['opened'] ?? false;
  }
}
