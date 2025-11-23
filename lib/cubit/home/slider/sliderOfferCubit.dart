import 'package:erestroSingleVender/data/model/sliderModel.dart';
import 'package:erestroSingleVender/data/repositories/home/slider/sliderRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class SliderState {}

class SliderInitial extends SliderState {}

class SliderProgress extends SliderState {}

class SliderSuccess extends SliderState {
  final List<SliderModel> sliderList;

  SliderSuccess(this.sliderList);
}

class SliderFailure extends SliderState {
  final String errorCode;

  SliderFailure(this.errorCode);
}

class SliderCubit extends Cubit<SliderState> {
  final SliderRepository _sliderRepository;

  SliderCubit(this._sliderRepository) : super(SliderInitial());

  void fetchSlider(String? branchId) {
    emit(SliderProgress());
    _sliderRepository
        .getSlider(branchId)
        .then((value) => emit(SliderSuccess(value)))
        .catchError((e) {
      emit(SliderFailure(e.toString()));
    });
  }

  getSliderData() {
    if (state is SliderSuccess) {
      return (state as SliderSuccess).sliderList;
    }
    return [];
  }
}
