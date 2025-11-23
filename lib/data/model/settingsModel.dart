import 'package:erestroSingleVender/data/model/branchModel.dart';
import 'package:erestroSingleVender/utils/constants.dart';

class SettingsModel {
  final bool showIntroSlider;
  final bool skip;
  final bool notification;
  String city;
  String cityId;
  String latitude;
  String longitude;
  String address;
  String cartCount;
  String cartTotal;
  String isBranchOpen;
  String branchId;
  String branchLatitude;
  String branchLongitude;
  String selfPickup;
  String deliverOrder;
  String branchAddress;
  BranchModel branchModel;

  SettingsModel(
      {required this.city,
      required this.cityId,
      required this.latitude,
      required this.longitude,
      required this.address,
      required this.notification,
      required this.showIntroSlider,
      required this.skip,
      required this.cartCount,
      required this.cartTotal,
      required this.isBranchOpen,
      required this.branchId,
      required this.branchLatitude,
      required this.branchLongitude,
      required this.selfPickup,
      required this.deliverOrder,
      required this.branchAddress,
      required this.branchModel});

  static SettingsModel fromJson(var settingsJson) {
    //to see the json response go to getCurrentSettings() function in settingsRepository
    return SettingsModel(
        notification: settingsJson['notification'],
        showIntroSlider: settingsJson['showIntroSlider'],
        cityId: settingsJson['cityId'],
        city: settingsJson['city'] ?? defaultCity,
        latitude: settingsJson['latitude'] ?? defaultLatitude,
        longitude: settingsJson['longitude'] ?? defaultLongitude,
        address: settingsJson['address'] ?? defaultAddress,
        skip: settingsJson['skip'],
        cartCount: settingsJson['cartCount'] ?? "0",
        cartTotal: settingsJson['cartTotal'] ?? "0.00",
        isBranchOpen: settingsJson['isBranchOpen'] ?? "",
        branchId: settingsJson['branchId'] ?? "",
        branchLatitude: settingsJson['branchLatitude'] ?? "",
        branchLongitude: settingsJson['branchLongitude'] ?? "",
        selfPickup: settingsJson['selfPickup'] ?? "",
        deliverOrder: settingsJson['deliverOrder'] ?? "",
        branchAddress: settingsJson['branchAddress'] ?? "",
        branchModel: settingsJson['branchModel'] ?? BranchModel());
  }

  SettingsModel copyWith(
      {bool? showIntroSlider,
      bool? skip,
      bool? notification,
      String? city,
      String? cityId,
      String? latitude,
      String? longitude,
      String? address,
      String? cartCount,
      String? cartTotal,
      String? isBranchOpen,
      String? branchId,
      String? branchLatitude,
      String? branchLongitude,
      String? selfPickup,
      String? deliverOrder,
      String? branchAddress,
      BranchModel? branchModel}) {
    return SettingsModel(
        notification: notification ?? this.notification,
        showIntroSlider: showIntroSlider ?? this.showIntroSlider,
        skip: skip ?? this.skip,
        cityId: cityId ?? this.cityId,
        city: city ?? this.city,
        latitude: (latitude) ?? this.latitude,
        longitude: longitude ?? this.longitude,
        address: address ?? this.address,
        cartCount: cartCount ?? this.cartCount,
        cartTotal: cartTotal ?? this.cartTotal,
        isBranchOpen: isBranchOpen ?? this.isBranchOpen,
        branchId: branchId ?? this.branchId,
        branchLatitude: branchLatitude ?? this.branchLatitude,
        branchLongitude: branchLongitude ?? this.branchLongitude,
        selfPickup: selfPickup ?? this.selfPickup,
        deliverOrder: deliverOrder ?? this.deliverOrder,
        branchAddress: branchAddress ?? this.branchAddress,
        branchModel: branchModel ?? this.branchModel);
  }
}
