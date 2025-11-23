import 'package:erestroSingleVender/data/localDataStore/settingsLocalDataSource.dart';
import 'package:erestroSingleVender/data/model/branchModel.dart';
import 'package:erestroSingleVender/utils/constants.dart';
import 'package:erestroSingleVender/utils/hiveBoxKey.dart';
import 'package:hive/hive.dart';

class SettingsRepository {
  static final SettingsRepository _settingsRepository =
      SettingsRepository._internal();
  late SettingsLocalDataSource _settingsLocalDataSource;

  factory SettingsRepository() {
    _settingsRepository._settingsLocalDataSource = SettingsLocalDataSource();
    return _settingsRepository;
  }

  SettingsRepository._internal();

  Map<String, dynamic> getCurrentSettings() {
    return {
      "showIntroSlider": _settingsLocalDataSource.showIntroSlider(),
      "notification": _settingsLocalDataSource.notification(),
      "cityId": _settingsLocalDataSource.showCityId(),
      "city": _settingsLocalDataSource.showCity(),
      "latitude": _settingsLocalDataSource.showLatitude(),
      "longitude": _settingsLocalDataSource.showLongitude(),
      "address": _settingsLocalDataSource.showAddress(),
      "cartCount": _settingsLocalDataSource.showCartCount(),
      "cartTotal": _settingsLocalDataSource.showCartTotal(),
      "isBranchOpen": _settingsLocalDataSource.showIsBranchOpen(),
      "skip": _settingsLocalDataSource.showSkip(),
    };
  }

  void changeIntroSlider(bool value) =>
      _settingsLocalDataSource.setShowIntroSlider(value);
  void changeSkip(bool value) => _settingsLocalDataSource.setSkip(value);
  void changeCity(String city) => _settingsLocalDataSource.setCity(city);
  void changeCityId(String cityId) =>
      _settingsLocalDataSource.setCityId(cityId);
  void changeLatitude(String latitude) =>
      _settingsLocalDataSource.setLatitude(latitude);
  void changeLongitude(String longitude) =>
      _settingsLocalDataSource.setLongitude(longitude);
  void changeAddress(String address) =>
      _settingsLocalDataSource.setAddress(address);
  void changeBranchId(String branchId) =>
      _settingsLocalDataSource.setBranchId(branchId);
  void changeCartCount(String cartCount) =>
      _settingsLocalDataSource.setCartCount(cartCount);
  void changeCartTotal(String cartTotal) =>
      _settingsLocalDataSource.setCartTotal(cartTotal);
  void changeisBranchOpen(String isBranchOpen) =>
      _settingsLocalDataSource.setIsBranchOpen(isBranchOpen);
  void changeBranchLatitude(String branchLatitude) =>
      _settingsLocalDataSource.setBranchLatitude(branchLatitude);
  void changeBranchLongitude(String branchLongitude) =>
      _settingsLocalDataSource.setBranchLongitude(branchLongitude);
  void changeSelfPickup(String selfPickup) =>
      _settingsLocalDataSource.setSelfPickup(selfPickup);
  void changeDeliverOrder(String deliverOrder) =>
      _settingsLocalDataSource.setDeliverOrder(deliverOrder);
  void changeBranchAddress(String branchAddress) =>
      _settingsLocalDataSource.setBranchAddress(branchAddress);
  void changeBranchModel(BranchModel branchModel) =>
      _settingsLocalDataSource.setBranchModel(branchModel);
  void changeNotification(bool value) =>
      _settingsLocalDataSource.setNotification(value);
  String getCurrentLanguageCode() {
    return Hive.box(settingsBox).get(currentLanguageCodeKey) ??
        defaultLanguageCode;
  }

  Future<void> setCurrentLanguageCode(String value) async {
    Hive.box(settingsBox).put(currentLanguageCodeKey, value);
  }
}
