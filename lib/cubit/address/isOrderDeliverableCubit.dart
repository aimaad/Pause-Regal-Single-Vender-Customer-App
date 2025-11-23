import 'package:erestroSingleVender/data/repositories/address/addressRepository.dart';
import 'package:erestroSingleVender/utils/apiMessageAndCodeException.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class IsOrderDeliverableState {}

class IsOrderDeliverableInitial extends IsOrderDeliverableState {}

class IsOrderDeliverableProgress extends IsOrderDeliverableState {}

class IsOrderDeliverableSuccess extends IsOrderDeliverableState {
  final String? message;

  IsOrderDeliverableSuccess(this.message);
}

class IsOrderDeliverableFailure extends IsOrderDeliverableState {
  final String errorStatusCode, errorMessage;
  IsOrderDeliverableFailure(this.errorMessage, this.errorStatusCode);
}

class IsOrderDeliverableCubit extends Cubit<IsOrderDeliverableState> {
  final AddressRepository _addressRepository;

  IsOrderDeliverableCubit(this._addressRepository)
      : super(IsOrderDeliverableInitial());

  fetchIsOrderDeliverable(String? branchId, String? latitude, String? longitude,
      String? addressId) {
    emit(IsOrderDeliverableProgress());
    _addressRepository
        .getIsOrderDeliverable(branchId, latitude, longitude, addressId)
        .then((value) => emit(IsOrderDeliverableSuccess(value)))
        .catchError((e) {
      ApiMessageAndCodeException apiMessageAndCodeException = e;
      emit(IsOrderDeliverableFailure(apiMessageAndCodeException.errorMessage,
          apiMessageAndCodeException.errorStatusCode!));
    });
  }

  String getCityId() {
    if (state is IsOrderDeliverableSuccess) {
      return (state as IsOrderDeliverableSuccess).message!;
    } else if (state is IsOrderDeliverableFailure) {}
    return "";
  }
}
