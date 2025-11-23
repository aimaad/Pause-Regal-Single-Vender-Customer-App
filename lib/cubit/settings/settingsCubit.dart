import 'package:erestroSingleVender/data/model/branchModel.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:erestroSingleVender/data/model/settingsModel.dart';
import 'package:erestroSingleVender/data/repositories/settings/settingsRepository.dart';

class SettingsState {
  final SettingsModel? settingsModel;
  SettingsState({this.settingsModel});
}

class SettingsCubit extends Cubit<SettingsState> {
  final SettingsRepository _settingsRepository;
  SettingsCubit(this._settingsRepository) : super(SettingsState()) {
    _getCurrentSettings();
  }

  void _getCurrentSettings() {
    emit(SettingsState(
        settingsModel:
            SettingsModel.fromJson(_settingsRepository.getCurrentSettings())));
  }

  SettingsModel getSettings() {
    return state.settingsModel!;
  }

  void changeShowIntroSlider() {
    _settingsRepository.changeIntroSlider(false);
    emit(SettingsState(
        settingsModel: state.settingsModel!.copyWith(showIntroSlider: false)));
  }

  void changeShowSkip() {
    _settingsRepository.changeSkip(false);
    emit(SettingsState(
        settingsModel: state.settingsModel!.copyWith(skip: false)));
  }

  setCity(String city) {
    _settingsRepository.changeCity(city);
    emit(SettingsState(
        settingsModel: state.settingsModel!.copyWith(city: city)));
  }

  setCityId(String cityId) {
    _settingsRepository.changeCityId(cityId);
    emit(SettingsState(
        settingsModel: state.settingsModel!.copyWith(cityId: cityId)));
  }

  setLatitude(String latitude) {
    _settingsRepository.changeLatitude(latitude);
    emit(SettingsState(
        settingsModel: state.settingsModel!.copyWith(latitude: latitude)));
  }

  setLongitude(String longitude) {
    _settingsRepository.changeLongitude(longitude);
    emit(SettingsState(
        settingsModel: state.settingsModel!.copyWith(longitude: longitude)));
  }

  setAddress(String address) {
    _settingsRepository.changeAddress(address);
    emit(SettingsState(
        settingsModel: state.settingsModel!.copyWith(address: address)));
  }

  setBranchId(String branchId) {
    _settingsRepository.changeBranchId(branchId);
    emit(SettingsState(
        settingsModel: state.settingsModel!.copyWith(branchId: branchId)));
  }

  setCartCount(String cartCount) {
    _settingsRepository.changeCartCount(cartCount);
    emit(SettingsState(
        settingsModel: state.settingsModel!.copyWith(cartCount: cartCount)));
  }

  setCartTotal(String cartTotal) {
    print("total--$cartTotal");
    _settingsRepository.changeCartTotal(cartTotal);
    emit(SettingsState(
        settingsModel: state.settingsModel!.copyWith(cartTotal: cartTotal)));
  }

  setIsBranchOpen(String isBranchOpen) {
    _settingsRepository.changeisBranchOpen(isBranchOpen);
    emit(SettingsState(
        settingsModel:
            state.settingsModel!.copyWith(isBranchOpen: isBranchOpen)));
  }

  setBranchLatitude(String branchLatitude) {
    _settingsRepository.changeBranchLatitude(branchLatitude);
    emit(SettingsState(
        settingsModel:
            state.settingsModel!.copyWith(branchLatitude: branchLatitude)));
  }

  setBranchLongitude(String branchLongitude) {
    _settingsRepository.changeBranchLongitude(branchLongitude);
    emit(SettingsState(
        settingsModel:
            state.settingsModel!.copyWith(branchLongitude: branchLongitude)));
  }

  setBranchAddress(String branchAddress) {
    _settingsRepository.changeBranchAddress(branchAddress);
    emit(SettingsState(
        settingsModel:
            state.settingsModel!.copyWith(branchAddress: branchAddress)));
  }

  setSelfPickup(String selfPickup) {
    _settingsRepository.changeSelfPickup(selfPickup);
    emit(SettingsState(
        settingsModel: state.settingsModel!.copyWith(selfPickup: selfPickup)));
  }

  setDeliverOrder(String deliverOrder) {
    _settingsRepository.changeDeliverOrder(deliverOrder);
    emit(SettingsState(
        settingsModel:
            state.settingsModel!.copyWith(deliverOrder: deliverOrder)));
  }

  setBranchModel(BranchModel branchModel) {
    _settingsRepository.changeBranchModel(branchModel);
    emit(SettingsState(
        settingsModel:
            state.settingsModel!.copyWith(branchModel: branchModel)));
  }

  void changeNotification(bool value) {
    _settingsRepository.changeNotification(value);
    emit(SettingsState(
        settingsModel: state.settingsModel!.copyWith(notification: value)));
  }
}
