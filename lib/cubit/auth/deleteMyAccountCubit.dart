import 'package:erestroSingleVender/utils/apiMessageAndCodeException.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:erestroSingleVender/data/repositories/auth/authRepository.dart';

@immutable
abstract class DeleteMyAccountState {}

class DeleteMyAccountInitial extends DeleteMyAccountState {}

class DeleteMyAccountProgress extends DeleteMyAccountState {
  DeleteMyAccountProgress();
}

class DeleteMyAccountSuccess extends DeleteMyAccountState {
  DeleteMyAccountSuccess();
}

class DeleteMyAccountFailure extends DeleteMyAccountState {
  final String errorMessage, errorStatusCode;
  DeleteMyAccountFailure(this.errorMessage, this.errorStatusCode);
}

class DeleteMyAccountCubit extends Cubit<DeleteMyAccountState> {
  final AuthRepository _authRepository;
  DeleteMyAccountCubit(this._authRepository) : super(DeleteMyAccountInitial());

  //to delete my account
  void deleteMyAccount() {
    //emitting DeleteMyAccountProgress state
    emit(DeleteMyAccountProgress());
    //to delete my account
    _authRepository.deleteMyAccount().then((result) {
      emit(DeleteMyAccountSuccess());
    }).catchError((e) {
      ApiMessageAndCodeException authException = e;
      emit(DeleteMyAccountFailure(authException.errorMessage.toString(),
          authException.errorStatusCode.toString()));
    });
  }
}
