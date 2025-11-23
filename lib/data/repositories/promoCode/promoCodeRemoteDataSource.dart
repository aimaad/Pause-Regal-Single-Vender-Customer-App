import 'package:erestroSingleVender/data/model/promoCodeValidateModel.dart';
import 'package:erestroSingleVender/utils/api.dart';
import 'package:erestroSingleVender/utils/apiBodyParameterLabels.dart';
import 'package:erestroSingleVender/utils/apiMessageAndCodeException.dart';

class PromoCodeRemoteDataSource {
//to promoCode
  Future<PromoCodeValidateModel> validatePromoCode(
      {String? promoCode, String? finalTotal, String? branchId}) async {
    try {
      //body of post request
      final body = {
        promoCodeKey: promoCode,
        finalTotalKey: finalTotal,
        branchIdKey: branchId
      };
      final result = await Api.post(
          body: body,
          url: Api.validatePromoCodeUrl,
          token: true,
          errorCode: true);
      return PromoCodeValidateModel.fromJson(result[dataKey][0]);
    } catch (e) {
      ApiMessageAndCodeException apiMessageAndCodeException =
          e as ApiMessageAndCodeException;
      throw ApiMessageAndCodeException(
          errorMessage: apiMessageAndCodeException.errorMessage,
          errorStatusCode: apiMessageAndCodeException.errorStatusCode);
    }
  }
}
