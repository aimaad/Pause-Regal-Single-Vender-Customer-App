import 'package:erestroSingleVender/data/repositories/address/addressRepository.dart';
import 'package:erestroSingleVender/utils/apiMessageAndCodeException.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class DeliveryChargeState {}

class DeliveryChargeInitial extends DeliveryChargeState {}

class DeliveryChargeProgress extends DeliveryChargeState {}

class DeliveryChargeSuccess extends DeliveryChargeState {
  final addressId, delivaryCharge, isFreeDelivery;

  DeliveryChargeSuccess(
      this.addressId, this.delivaryCharge, this.isFreeDelivery);
}

class DeliveryChargeFailure extends DeliveryChargeState {
  final String errorStatusCode, errorMessage;
  DeliveryChargeFailure(this.errorMessage, this.errorStatusCode);
}

class DeliveryChargeCubit extends Cubit<DeliveryChargeState> {
  final AddressRepository _addressRepository;

  DeliveryChargeCubit(this._addressRepository) : super(DeliveryChargeInitial());

  fetchDeliveryCharge(String? addressId, String? finalTotal, String? branchId) {
    emit(DeliveryChargeProgress());
    _addressRepository
        .getDeliveryCharge(addressId, finalTotal, branchId)
        .then((value) => emit(DeliveryChargeSuccess(addressId,
            value['delivery_charge'], value['is_free_delivery'] ?? "")))
        .catchError((e) {
      ApiMessageAndCodeException apiMessageAndCodeException = e;
      emit(DeliveryChargeFailure(apiMessageAndCodeException.errorMessage,
          apiMessageAndCodeException.errorStatusCode!));
    });
  }

  String getDeliveryCharge() {
    if (state is DeliveryChargeSuccess) {
      return (state as DeliveryChargeSuccess).delivaryCharge!;
    }
    return "";
  }
}
