import 'package:erestroSingleVender/data/model/attributesModel.dart';
import 'package:erestroSingleVender/data/model/filtersModel.dart';
import 'package:erestroSingleVender/data/model/minMaxPriceModel.dart';
import 'package:erestroSingleVender/data/model/productAddOnsModel.dart';
import 'package:erestroSingleVender/data/model/reviewImagesModel.dart';
import 'package:erestroSingleVender/data/model/variantAttributesModel.dart';
import 'package:erestroSingleVender/data/model/variantsModel.dart';

class SectionsModel {
  String? id;
  String? title;
  String? shortDescription;
  String? style;
  String? productIds;
  String? branchId;
  String? rowOrder;
  String? categories;
  String? productType;
  String? dateAdded;
  String? total;
  List<FiltersModel>? filters;
  List<String>? productTags;
  List<String>? partnerTags;
  List<ProductDetails>? productDetails;

  SectionsModel(
      {this.id,
      this.title,
      this.shortDescription,
      this.style,
      this.productIds,
      this.branchId,
      this.rowOrder,
      this.categories,
      this.productType,
      this.dateAdded,
      this.total,
      this.filters,
      this.productTags,
      this.partnerTags,
      this.productDetails});

  SectionsModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    shortDescription = json['short_description'];
    style = json['style'];
    productIds = json['product_ids'];
    branchId = json['branch_id'];
    rowOrder = json['row_order'];
    categories = json['categories'];
    productType = json['product_type'];
    dateAdded = json['date_added'];
    total = json['total'];
    if (json['filters'] != null) {
      filters = <FiltersModel>[];
      json['filters'].forEach((v) {
        filters!.add(FiltersModel.fromJson(v));
      });
    }
    productTags = json['product_tags'] == null
        ? List<String>.from([])
        : (json['product_tags'] as List).map((e) => e.toString()).toList();
    partnerTags = json['partner_tags'] == null
        ? List<String>.from([])
        : (json['partner_tags'] as List).map((e) => e.toString()).toList();
    if (json['product_details'] != null) {
      productDetails = <ProductDetails>[];
      json['product_details'].forEach((v) {
        productDetails!.add(ProductDetails.fromJson(v));
      });
    }
  }
}

class ProductDetails {
  String? sales;
  String? stockType;
  String? calories;
  String? status;
  String? isPricesInclusiveTax;
  String? taxId;
  String? type;
  String? attrValueIds;
  String? branchId;
  String? ownerName;
  String? id;
  String? stock;
  String? name;
  String? categoryId;
  String? availableTime;
  String? startTime;
  String? endTime;
  String? shortDescription;
  String? slug;
  String? totalAllowedQuantity;
  String? minimumOrderQuantity;
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
  String? categorySlug;
  String? taxPercentage;
  String? bestSeller;
  String? isBranchOpen;
  List<String>? tags;
  List<ReviewImagesModel>? reviewImages;
  List<AttributesModel>? attributes;
  List<ProductAddOnsModel>? productAddOns;
  List<VariantsModel>? variants;
  MinMaxPriceModel? minMaxPrice;
  String? relativePath;
  List<String>? otherImagesRelativePath;
  bool? isPurchased;
  String? isFavorite;
  String? imageMd;
  String? imageSm;
  List<VariantAttributesModel>? variantAttributes;
  String? total;
  String? cartId;

  ProductDetails(
      {this.sales,
      this.stockType,
      this.calories,
      this.status,
      this.isPricesInclusiveTax,
      this.taxId,
      this.type,
      this.attrValueIds,
      this.branchId,
      this.ownerName,
      this.id,
      this.stock,
      this.name,
      this.categoryId,
      this.availableTime,
      this.startTime,
      this.endTime,
      this.shortDescription,
      this.slug,
      this.totalAllowedQuantity,
      this.minimumOrderQuantity,
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
      this.categorySlug,
      this.taxPercentage,
      this.bestSeller,
      this.isBranchOpen,
      this.tags,
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
      this.variantAttributes,
      this.total,
      this.cartId});

  ProductDetails copyWith(
      String? sales,
      String? stockType,
      String? calories,
      String? status,
      String? isPricesInclusiveTax,
      String? taxId,
      String? type,
      String? attrValueIds,
      String? branchId,
      String? ownerName,
      String? id,
      String? stock,
      String? name,
      String? categoryId,
      String? availableTime,
      String? startTime,
      String? endTime,
      String? shortDescription,
      String? slug,
      String? totalAllowedQuantity,
      String? minimumOrderQuantity,
      String? codAllowed,
      String? isSpicy,
      String? rowOrder,
      String? rating,
      String? noOfRatings,
      String? image,
      String? isCancelable,
      String? cancelableTill,
      String? indicator,
      List<String>? highlights,
      String? availability,
      String? categoryName,
      String? categorySlug,
      String? taxPercentage,
      String? bestSeller,
      String? isBranchOpen,
      List<ReviewImagesModel>? reviewImages,
      List<AttributesModel>? attributes,
      List<ProductAddOnsModel>? productAddOns,
      List<VariantsModel>? variants,
      MinMaxPriceModel? minMaxPrice,
      String? relativePath,
      List<String>? otherImagesRelativePath,
      bool? isPurchased,
      String? isFavorite,
      String? imageMd,
      String? imageSm,
      List<VariantAttributesModel>? variantAttributes,
      String? total,
      String? cartId) {
    return ProductDetails(
        sales: sales,
        stockType: stockType,
        calories: calories,
        status: status,
        isPricesInclusiveTax: isPricesInclusiveTax,
        taxId: taxId,
        type: type,
        attrValueIds: attrValueIds,
        branchId: branchId,
        ownerName: ownerName,
        id: id,
        stock: stock,
        name: name,
        categoryId: categoryId,
        availableTime: availableTime,
        startTime: startTime,
        endTime: endTime,
        shortDescription: shortDescription,
        slug: slug,
        totalAllowedQuantity: totalAllowedQuantity,
        minimumOrderQuantity: minimumOrderQuantity,
        codAllowed: codAllowed,
        isSpicy: isSpicy,
        rowOrder: rowOrder,
        rating: rating,
        noOfRatings: noOfRatings,
        image: image,
        isCancelable: isCancelable,
        cancelableTill: cancelableTill,
        indicator: indicator,
        highlights: highlights,
        availability: availability,
        categoryName: categoryName,
        categorySlug: categorySlug,
        taxPercentage: taxPercentage,
        bestSeller: bestSeller,
        isBranchOpen: isBranchOpen,
        reviewImages: reviewImages,
        attributes: attributes,
        productAddOns: productAddOns,
        variants: variants,
        minMaxPrice: minMaxPrice,
        isPurchased: isPurchased,
        relativePath: relativePath,
        otherImagesRelativePath: otherImagesRelativePath,
        isFavorite: isFavorite,
        imageMd: imageMd,
        imageSm: imageSm,
        variantAttributes: variantAttributes,
        total: total,
        cartId: cartId);
  }

  ProductDetails.fromJson(Map<String, dynamic> json) {
    sales = json['sales'] ?? "";
    stockType = json['stock_type'] ?? "";
    calories = json['calories'] ?? "";
    status = json['status'] ?? "";
    isPricesInclusiveTax = json['is_prices_inclusive_tax'] ?? "";
    taxId = json['tax_id'] ?? "";
    type = json['type'] ?? "";
    attrValueIds = json['attr_value_ids'] ?? "";
    branchId = json['branch_id'] ?? "";
    ownerName = json['owner_name'] ?? "";
    id = json['id'] ?? "";
    stock = json['stock'] ?? "";
    name = json['name'] ?? "";
    categoryId = json['category_id'] ?? "";
    availableTime = json['available_time'] ?? "";
    startTime = json['start_time'] ?? "";
    endTime = json['end_time'] ?? "";
    shortDescription = json['short_description'] ?? "";
    slug = json['slug'] ?? "";
    totalAllowedQuantity = json['total_allowed_quantity'] ?? "";
    minimumOrderQuantity = json['minimum_order_quantity'] ?? "";
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
    availability = json['availability'].toString();
    categoryName = json['category_name'] ?? "";
    categorySlug = json['category_slug'] ?? "";
    taxPercentage = json['tax_percentage'] ?? "";
    bestSeller = json['best_seller'] ?? "";
    isBranchOpen = json['is_branch_open'] ?? "0";
    tags = json['tags'] == null
        ? List<String>.from([])
        : (json['tags'] as List).map((e) => e.toString()).toList();
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
    }
    minMaxPrice = json['min_max_price'] != null
        ? MinMaxPriceModel.fromJson(json['min_max_price'])
        : null;
    isPurchased = json['is_purchased'];
    relativePath = json['relative_path'];
    otherImagesRelativePath = json['other_images_relative_path'] == null
        ? List<String>.from([])
        : (json['other_images_relative_path'] as List)
            .map((e) => e.toString())
            .toList();
    isFavorite = json['is_favorite'] ?? "";
    imageMd = json['image_md'];
    imageSm = json['image_sm'];
    if (json['variant_attributes'] != null) {
      variantAttributes = <VariantAttributesModel>[];
      json['variant_attributes'].forEach((v) {
        variantAttributes!.add(VariantAttributesModel.fromJson(v));
      });
    }
    total = json['total'];
    cartId = json['cart_id'] ?? "";
  }
}
