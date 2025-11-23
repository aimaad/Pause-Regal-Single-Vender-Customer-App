import 'package:erestroSingleVender/data/model/branchModel.dart';
import 'package:erestroSingleVender/utils/apiBodyParameterLabels.dart';
import 'package:erestroSingleVender/utils/constants.dart';
import 'package:erestroSingleVender/utils/hiveBoxKey.dart';
import 'package:hive/hive.dart';

class SettingsLocalDataSource {
  bool? showIntroSlider() {
    return Hive.box(settingsBox).get(showIntroSliderKey, defaultValue: true);
  }

  String? showCity() {
    return Hive.box(settingsBox).get(cityKey, defaultValue: "");
  }

  String? showCityId() {
    return Hive.box(settingsBox).get(cityIdKey, defaultValue: "");
  }

  String? showBranchId() {
    return Hive.box(settingsBox).get(branchIdKey, defaultValue: "");
  }

  String? showLatitude() {
    return Hive.box(settingsBox).get(latitudeKey, defaultValue: "");
  }

  String? showLongitude() {
    return Hive.box(settingsBox).get(longitudeKey, defaultValue: "");
  }

  String? showAddress() {
    return Hive.box(settingsBox).get(addressKey, defaultValue: "");
  }

  String? showCartCount() {
    return Hive.box(settingsBox).get(cartCountKey, defaultValue: "0");
  }

  String? showCartTotal() {
    return Hive.box(settingsBox).get(cartTotalKey, defaultValue: "0.00");
  }

  String? showIsBranchOpen() {
    return Hive.box(settingsBox).get(isBranchOpenKey, defaultValue: "");
  }

  bool? showSkip() {
    return Hive.box(settingsBox).get(skipKey, defaultValue: true);
  }

  String getCurrentLanguageCode() {
    return Hive.box(settingsBox).get(currentLanguageCodeKey) ??
        defaultLanguageCode;
  }

  Future<void> setCurrentLanguageCode(String value) async {
    Hive.box(settingsBox).put(currentLanguageCodeKey, value);
  }

  Future<void> setShowIntroSlider(bool value) async {
    Hive.box(settingsBox).put(showIntroSliderKey, value);
  }

  Future<void> setSkip(bool value) async {
    Hive.box(settingsBox).put(skipKey, value);
  }

  Future<void> setCity(String city) async {
    Hive.box(settingsBox).put(cityKey, city);
  }

  Future<void> setCityId(String cityId) async {
    Hive.box(settingsBox).put(cityIdKey, cityId);
  }

  Future<void> setLatitude(String latitude) async {
    Hive.box(settingsBox).put(latitudeKey, latitude);
  }

  Future<void> setLongitude(String longitude) async {
    Hive.box(settingsBox).put(longitudeKey, longitude);
  }

  Future<void> setAddress(String address) async {
    Hive.box(settingsBox).put(addressKey, address);
  }

  Future<void> setBranchId(String branchId) async {
    Hive.box(settingsBox).put(branchIdKey, branchId);
  }

  Future<void> setCartCount(String cartCount) async {
    Hive.box(settingsBox).put(cartCountKey, cartCount);
  }

  Future<void> setCartTotal(String cartTotal) async {
    Hive.box(settingsBox).put(cartTotalKey, cartTotal);
  }

  Future<void> setIsBranchOpen(String isBranchOpen) async {
    Hive.box(settingsBox).put(isBranchOpenKey, isBranchOpen);
  }

  bool? notification() {
    return Hive.box(settingsBox).get(soundKey, defaultValue: true);
  }

  Future<void> setNotification(bool value) async {
    Hive.box(settingsBox).put(soundKey, value);
  }

  Future<void> setBranchLatitude(String branchLatitude) async {
    Hive.box(settingsBox).put(branchLatitudeKey, branchLatitude);
  }

  Future<void> setBranchLongitude(String branchLongitude) async {
    Hive.box(settingsBox).put(branchlongitudeKey, branchLongitude);
  }

  Future<void> setDeliverOrder(String deliverOrder) async {
    Hive.box(settingsBox).put(deliverOrderKey, deliverOrder);
  }

  Future<void> setSelfPickup(String selfPickup) async {
    Hive.box(settingsBox).put(isSelfPickUpKey, selfPickup);
  }

  Future<void> setBranchAddress(String branchAddress) async {
    Hive.box(settingsBox).put(branchAddressKey, branchAddress);
  }

  Future<void> setBranchModel(BranchModel branchModel) async {
    Hive.box(settingsBox).put(branchModelKey, branchModel);
  }
}
