import 'package:erestroSingleVender/data/model/branchModel.dart';
import 'package:erestroSingleVender/data/repositories/address/addressRepository.dart';
import 'package:erestroSingleVender/utils/apiBodyParameterLabels.dart';
import 'package:erestroSingleVender/utils/apiMessageAndCodeException.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

abstract class CityDeliverableState {}

class CityDeliverableInitial extends CityDeliverableState {}

class CityDeliverableProgress extends CityDeliverableState {}

class CityDeliverableSuccess extends CityDeliverableState {
  final String? name, cityId;
  final List<BranchModel> branchModel;

  CityDeliverableSuccess(this.name, this.cityId, this.branchModel);
}

class CityDeliverableFailure extends CityDeliverableState {
  final String errorStatusCode, errorMessage;
  CityDeliverableFailure(this.errorMessage, this.errorStatusCode);
}

class CityDeliverableCubit extends Cubit<CityDeliverableState> {
  final AddressRepository _addressRepository;

  CityDeliverableCubit(this._addressRepository)
      : super(CityDeliverableInitial());

  fetchCityDeliverable(String? name, String? latitude, String? longitude) {
    emit(CityDeliverableProgress());
    _addressRepository
        .getCityDeliverable(name, latitude, longitude)
        .then((value) => emit(CityDeliverableSuccess(
            name,
            value['city_id'],
            (value[dataKey] as List)
                .map((e) => BranchModel.fromJson(e))
                .toList())))
        .catchError((e) {
      ApiMessageAndCodeException apiMessageAndCodeException = e;
      emit(CityDeliverableFailure(apiMessageAndCodeException.errorMessage,
          apiMessageAndCodeException.errorStatusCode!));
    });
  }

  String getCityId() {
    if (state is CityDeliverableSuccess) {
      return (state as CityDeliverableSuccess).cityId!;
    } else if (state is CityDeliverableFailure) {}
    return "";
  }

  BranchWorkingTime branchWorkingTime() {
    DateTime now = DateTime.now();
    String nowHour = DateFormat('EEEE').format(now);
    if (state is CityDeliverableSuccess) {
      List<BranchWorkingTime> branchModel =
          (state as CityDeliverableSuccess).branchModel[0].branchWorkingTime!;
      int index = branchModel.indexWhere((element) => element.day == nowHour);
      return branchModel[index];
    } else if (state is CityDeliverableFailure) {}
    return BranchWorkingTime();
  }
}
