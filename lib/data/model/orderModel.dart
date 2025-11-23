import 'package:erestroSingleVender/data/model/addOnsDataModel.dart';
import 'package:erestroSingleVender/data/model/branchModel.dart';

class OrderModel {
  String? id;
  String? userId;
  String? riderId;
  String? branchId;
  String? addressId;
  String? cityId;
  String? mobile;
  String? total;
  String? deliveryCharge;
  String? isDeliveryChargeReturnable;
  String? walletBalance;
  String? totalPayable;
  String? promoCode;
  String? promoDiscount;
  String? discount;
  String? finalTotal;
  String? paymentMethod;
  String? latitude;
  String? longitude;
  String? address;
  String? deliveryTime;
  String? deliveryDate;
  List<List>? status;
  String? activeStatus;
  String? dateAdded;
  String? otp;
  String? isSelfPickUp;
  String? ownerNote;
  String? selfPickupTime;
  String? reason;
  String? notes;
  String? deliveryTip;
  String? username;
  String? usermobile;
  String? profile;
  String? countryCode;
  String? name;
  String? riderMobile;
  String? riderName;
  String? riderImage;
  String? riderRating;
  String? riderNoOfRatings;
  String? totalTaxPercent;
  String? totalTaxAmount;
  String? invoiceHtml;
  List<OrderItems>? orderItems;
  BranchModel? branchModel;
  String? orderProductRating;
  String? orderRiderRating;

  OrderModel(
      {this.id,
      this.userId,
      this.riderId,
      this.branchId,
      this.addressId,
      this.cityId,
      this.mobile,
      this.total,
      this.deliveryCharge,
      this.isDeliveryChargeReturnable,
      this.walletBalance,
      this.totalPayable,
      this.promoCode,
      this.promoDiscount,
      this.discount,
      this.finalTotal,
      this.paymentMethod,
      this.latitude,
      this.longitude,
      this.address,
      this.deliveryTime,
      this.deliveryDate,
      this.status,
      this.activeStatus,
      this.dateAdded,
      this.otp,
      this.isSelfPickUp,
      this.ownerNote,
      this.selfPickupTime,
      this.reason,
      this.notes,
      this.deliveryTip,
      this.username,
      this.usermobile,
      this.profile,
      this.countryCode,
      this.name,
      this.riderMobile,
      this.riderName,
      this.riderImage,
      this.riderRating,
      this.riderNoOfRatings,
      this.totalTaxPercent,
      this.totalTaxAmount,
      this.invoiceHtml,
      this.orderItems,
      this.branchModel,
      this.orderProductRating,
      this.orderRiderRating});

  OrderModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    riderId = json['rider_id'];
    branchId = json['branch_id'];
    addressId = json['address_id'];
    cityId = json['city_id'];
    mobile = json['mobile'];
    total = json['total'];
    deliveryCharge = json['delivery_charge'];
    isDeliveryChargeReturnable = json['is_delivery_charge_returnable'];
    walletBalance = json['wallet_balance'];
    totalPayable = json['total_payable'];
    promoCode = json['promo_code'];
    promoDiscount = json['promo_discount'];
    discount = json['discount'];
    finalTotal = json['final_total'];
    paymentMethod = json['payment_method'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    address = json['address'];
    deliveryTime = json['delivery_time'];
    deliveryDate = json['delivery_date'];
    if (json['status'] != null) {
      status = <List>[];
      json['status'].forEach((v) {
        status!.add((v));
      });
    }
    activeStatus = json['active_status'];
    dateAdded = json['date_added'];
    otp = json['otp'];
    isSelfPickUp = json['is_self_pick_up'];
    ownerNote = json['owner_note'];
    selfPickupTime = json['self_pickup_time'];
    reason = json['reason'];
    notes = json['notes'];
    deliveryTip = json['delivery_tip'];
    username = json['username'];
    usermobile = json['user_mobile'];
    profile = json['profile'];
    countryCode = json['country_code'];
    name = json['name'];
    riderMobile = json['rider_mobile'];
    riderName = json['rider_name'];
    riderImage = json['rider_image'];
    riderRating = json['rider_rating'];
    riderNoOfRatings = json['rider_no_of_ratings'];
    totalTaxPercent = json['total_tax_percent'];
    totalTaxAmount = json['total_tax_amount'];
    invoiceHtml = json['invoice_html'];
    if (json['order_items'] != null) {
      orderItems = <OrderItems>[];
      json['order_items'].forEach((v) {
        orderItems!.add(OrderItems.fromJson(v));
      });
    }
    branchModel = json['branch_details'] != null
        ? BranchModel.fromJson(json['branch_details'])
        : null;
    orderProductRating = json["order_product_rating"] ?? "";
    orderRiderRating = json["order_rider_rating"] ?? "";
  }
}

class OrderItems {
  String? id;
  String? userId;
  String? orderId;
  String? isCredited;
  String? productName;
  String? variantName;
  List<AddOnsDataModel>? addOns;
  String? productVariantId;
  String? quantity;
  String? price;
  String? discountedPrice;
  String? taxPercent;
  String? taxAmount;
  String? discount;
  String? subTotal;
  String? dateAdded;
  String? productId;
  String? isCancelable;
  String? cancelableTill;
  String? isReturnable;
  String? image;
  String? name;
  String? indicator;
  String? type;
  String? orderCounter;
  String? varaintIds;
  String? variantValues;
  String? attrName;
  String? imageSm;
  String? imageMd;

  OrderItems(
      {this.id,
      this.userId,
      this.orderId,
      this.isCredited,
      this.productName,
      this.variantName,
      this.productVariantId,
      this.quantity,
      this.price,
      this.discountedPrice,
      this.taxPercent,
      this.taxAmount,
      this.discount,
      this.subTotal,
      this.dateAdded,
      this.productId,
      this.isCancelable,
      this.cancelableTill,
      this.isReturnable,
      this.image,
      this.name,
      this.indicator,
      this.type,
      this.orderCounter,
      this.varaintIds,
      this.variantValues,
      this.attrName,
      this.imageSm,
      this.imageMd});

  OrderItems.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    orderId = json['order_id'];
    isCredited = json['is_credited'];
    productName = json['product_name'];
    variantName = json['variant_name'];
    if (json['add_ons'] != null) {
      addOns = <AddOnsDataModel>[];
      json['add_ons'].forEach((v) {
        addOns!.add(AddOnsDataModel.fromJson(v));
      });
    }
    productVariantId = json['product_variant_id'];
    quantity = json['quantity'];
    price = json['price'];
    discountedPrice = json['discounted_price'];
    taxPercent = json['tax_percent'];
    taxAmount = json['tax_amount'];
    discount = json['discount'];
    subTotal = json['sub_total'];
    dateAdded = json['date_added'];
    productId = json['product_id'];
    isCancelable = json['is_cancelable'];
    cancelableTill = json['cancelable_till'] ?? "";
    isReturnable = json['is_returnable'];
    image = json['image'];
    name = json['name'];
    indicator = json['indicator'];
    type = json['type'];
    orderCounter = json['order_counter'];
    varaintIds = json['varaint_ids'];
    variantValues = json['variant_values'];
    attrName = json['attr_name'];
    imageSm = json['image_sm'];
    imageMd = json['image_md'];
  }
}
