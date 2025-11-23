import 'dart:io';

import 'package:erestroSingleVender/data/model/settingModel.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:erestroSingleVender/data/repositories/systemConfig/systemConfigRepository.dart';

abstract class SystemConfigState {}

class SystemConfigIntial extends SystemConfigState {}

class SystemConfigFetchInProgress extends SystemConfigState {}

class SystemConfigFetchSuccess extends SystemConfigState {
  final SettingModel systemConfigModel;

  SystemConfigFetchSuccess({required this.systemConfigModel});
}

class SystemConfigFetchFailure extends SystemConfigState {
  final String errorCode;

  SystemConfigFetchFailure(this.errorCode);
}

class SystemConfigCubit extends Cubit<SystemConfigState> {
  final SystemConfigRepository _systemConfigRepository;
  SystemConfigCubit(this._systemConfigRepository) : super(SystemConfigIntial());

  //to getSettings
  getSystemConfig(String? userId) {
    //emitting SystemConfigFetchInProgress state
    emit(SystemConfigFetchInProgress());
    //getSettings details in api
    _systemConfigRepository
        .getSystemConfig(userId)
        .then(
            (value) => emit(SystemConfigFetchSuccess(systemConfigModel: value)))
        .catchError((e) {
      emit(SystemConfigFetchFailure(e.toString()));
    });
  }

  String getCurrency() {
    if (state is SystemConfigFetchSuccess) {
      return (state as SystemConfigFetchSuccess)
          .systemConfigModel
          .data!
          .currency![0];
    }
    return "";
  }

  String getMobile() {
    if (state is SystemConfigFetchSuccess) {
      return (state as SystemConfigFetchSuccess)
          .systemConfigModel
          .data!
          .userData![0]
          .mobile!;
    }
    return "";
  }

  String getEmail() {
    if (state is SystemConfigFetchSuccess) {
      return (state as SystemConfigFetchSuccess)
          .systemConfigModel
          .data!
          .userData![0]
          .email!;
    }
    return "";
  }

  String getName() {
    if (state is SystemConfigFetchSuccess) {
      return (state as SystemConfigFetchSuccess)
          .systemConfigModel
          .data!
          .userData![0]
          .username!;
    }
    return "";
  }

  String getWallet() {
    if (state is SystemConfigFetchSuccess) {
      print(
          "${(state as SystemConfigFetchSuccess).systemConfigModel.data!.userData.runtimeType != Null}==${(state as SystemConfigFetchSuccess).systemConfigModel.data!.userData.runtimeType}");
      return (state as SystemConfigFetchSuccess)
              .systemConfigModel
              .data!
              .userData!
              .isNotEmpty
          ? (state as SystemConfigFetchSuccess)
              .systemConfigModel
              .data!
              .userData![0]
              .balance!
          : "0.0";
    }
    return "";
  }

  setWallet(String? walletAmount) {
    final systemSettingDetails =
        (state as SystemConfigFetchSuccess).systemConfigModel;
    final dataDetails = systemSettingDetails.data;
    final userDetails = dataDetails!.userData;
    List<UserData> otherStatuses = List<UserData>.generate(
        userDetails!.length, (i) => UserData(balance: walletAmount));
    emit((SystemConfigFetchSuccess(
        systemConfigModel: systemSettingDetails.copyWith(
            data: dataDetails.copyWith(userData: otherStatuses)))));
  }

  String getReferCode() {
    if (state is SystemConfigFetchSuccess) {
      return (state as SystemConfigFetchSuccess)
          .systemConfigModel
          .data!
          .userData![0]
          .referralCode!;
    }
    return "";
  }

  String getIsReferEarnOn() {
    if (state is SystemConfigFetchSuccess) {
      return (state as SystemConfigFetchSuccess)
          .systemConfigModel
          .data!
          .systemSettings![0]
          .isReferEarnOn!;
    }
    return "";
  }

  String getCurrentVersionAndroid() {
    if (state is SystemConfigFetchSuccess) {
      return (state as SystemConfigFetchSuccess)
          .systemConfigModel
          .data!
          .systemSettings![0]
          .currentVersion!;
    }
    return "";
  }

  String getCurrentVersionIos() {
    if (state is SystemConfigFetchSuccess) {
      return (state as SystemConfigFetchSuccess)
          .systemConfigModel
          .data!
          .systemSettings![0]
          .currentVersionIos!;
    }
    return "";
  }

  String getReferEarnOn() {
    if (state is SystemConfigFetchSuccess) {
      return (state as SystemConfigFetchSuccess)
          .systemConfigModel
          .data!
          .systemSettings![0]
          .isReferEarnOn!;
    }
    return "";
  }

  String isForceUpdateEnable() {
    if (state is SystemConfigFetchSuccess) {
      return (state as SystemConfigFetchSuccess)
          .systemConfigModel
          .data!
          .systemSettings![0]
          .isVersionSystemOn!;
    }
    return "";
  }

  String isAppMaintenance() {
    if (state is SystemConfigFetchSuccess) {
      return (state as SystemConfigFetchSuccess)
          .systemConfigModel
          .data!
          .systemSettings![0]
          .isAppMaintenanceModeOn!;
    }
    return "";
  }

  String getCartMaxItemAllow() {
    if (state is SystemConfigFetchSuccess) {
      return (state as SystemConfigFetchSuccess)
          .systemConfigModel
          .data!
          .systemSettings![0]
          .maxItemsCart!;
    }
    return "";
  }

  String getCartMinAmount() {
    if (state is SystemConfigFetchSuccess) {
      return (state as SystemConfigFetchSuccess)
          .systemConfigModel
          .data!
          .systemSettings![0]
          .minimumCartAmt!;
    }
    return "";
  }

  String getDemoMode() {
    if (state is SystemConfigFetchSuccess) {
      print(
          "getDemoMode:${(state as SystemConfigFetchSuccess).systemConfigModel.allowModification!.toString()}");
      return (state as SystemConfigFetchSuccess)
          .systemConfigModel
          .allowModification!
          .toString();
    }
    return "";
  }

  String isOtpLoginEnable() {
    if (state is SystemConfigFetchSuccess) {
      return (state as SystemConfigFetchSuccess)
          .systemConfigModel
          .data!
          .systemSettings![0]
          .otpLogin!;
    }
    return "";
  }

  String isGoogleLoginEnable() {
    if (state is SystemConfigFetchSuccess) {
      return (state as SystemConfigFetchSuccess)
          .systemConfigModel
          .data!
          .systemSettings![0]
          .googleLogin!;
    }
    return "";
  }

  String isAppleLoginEnable() {
    if (state is SystemConfigFetchSuccess) {
      return (state as SystemConfigFetchSuccess)
          .systemConfigModel
          .data!
          .systemSettings![0]
          .appleLogin!;
    }
    return "";
  }

  String getAuthenticationMethod() {
    if (state is SystemConfigFetchSuccess) {
      return (state as SystemConfigFetchSuccess)
          .systemConfigModel
          .data!
          .authenticationMode
          .toString();
    }
    return "0";
  }

  String isFirstOrder() {
    if (state is SystemConfigFetchSuccess) {
      return (state as SystemConfigFetchSuccess)
              .systemConfigModel
              .data!
              .userData!
              .isEmpty
          ? "0"
          : (state as SystemConfigFetchSuccess)
              .systemConfigModel
              .data!
              .userData![0]
              .isFirstOrder!;
    }
    return "0";
  }

  String getAppLink() {
    if (state is SystemConfigFetchSuccess) {
      return Platform.isIOS
          ? (state as SystemConfigFetchSuccess)
              .systemConfigModel
              .data!
              .systemSettings![0]
              .customerAppIosLink!
          : (state as SystemConfigFetchSuccess)
              .systemConfigModel
              .data!
              .systemSettings![0]
              .customerAppAndroidLink!;
    }
    return "";
  }

  String isReferEarnOn() {
    if (state is SystemConfigFetchSuccess) {
      return (state as SystemConfigFetchSuccess)
          .systemConfigModel
          .data!
          .systemSettings![0]
          .isReferEarnOn!;
    }
    return "0";
  }

  String appReference() {
    if (state is SystemConfigFetchSuccess) {
      return (state as SystemConfigFetchSuccess)
          .systemConfigModel
          .data!
          .systemSettings![0]
          .appReference!;
    }
    return "";
  }
}
