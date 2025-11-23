import 'package:erestroSingleVender/data/model/withdrawModel.dart';
import 'package:erestroSingleVender/data/repositories/payment/paymentRepository.dart';
import 'package:erestroSingleVender/utils/apiBodyParameterLabels.dart';
import 'package:erestroSingleVender/utils/apiMessageAndCodeException.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class SendWithdrawRequestState {}

class SendWithdrawRequestIntial extends SendWithdrawRequestState {}

class SendWithdrawRequestFetchInProgress extends SendWithdrawRequestState {}

class SendWithdrawRequestFetchSuccess extends SendWithdrawRequestState {
  final String? userId, amount, paymentAddress, walletAmount;
  final WithdrawModel? withdrawModel;
  SendWithdrawRequestFetchSuccess(
      {this.userId,
      this.amount,
      this.paymentAddress,
      this.walletAmount,
      this.withdrawModel});
}

class SendWithdrawRequestFetchFailure extends SendWithdrawRequestState {
  final String errorCode, errorStatusCode;
  SendWithdrawRequestFetchFailure(this.errorCode, this.errorStatusCode);
}

class SendWithdrawRequestCubit extends Cubit<SendWithdrawRequestState> {
  final PaymentRepository _paymentRepository;
  SendWithdrawRequestCubit(this._paymentRepository)
      : super(SendWithdrawRequestIntial());

  //to sendWithdrawRequest user
  void sendWithdrawRequest(String? amount, String? paymentAddress) {
    //emitting SendWithdrawRequestProgress state
    emit(SendWithdrawRequestFetchInProgress());
    //SendWithdrawRequest in api
    _paymentRepository
        .sendWalletRequest(amount, paymentAddress)
        .then((value) => emit(SendWithdrawRequestFetchSuccess(
            amount: amount,
            paymentAddress: paymentAddress,
            walletAmount: value['new_balance'],
            withdrawModel: WithdrawModel.fromJson(value[dataKey][0]))))
        .catchError((e) {
      ApiMessageAndCodeException apiMessageAndCodeException = e;
      emit(SendWithdrawRequestFetchFailure(
          apiMessageAndCodeException.errorMessage.toString(),
          apiMessageAndCodeException.errorStatusCode.toString()));
    });
  }
}
