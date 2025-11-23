import 'dart:convert';
import 'dart:io';
import 'package:erestroSingleVender/utils/api.dart';
import 'package:erestroSingleVender/utils/apiMessageAndCodeException.dart';
import 'package:erestroSingleVender/utils/string.dart';
import 'package:erestroSingleVender/utils/apiBodyParameterLabels.dart';

class ProfileManagementRemoteDataSource {
  Future addProfileImage(File? images) async {
    try {
      Map<String, String?> body = {};
      Map<String, File?> fileList = {
        imageKey: images,
      };
      var response = await Api.postApiFileProfilePic(
          Uri.parse(Api.updateUserUrl), fileList, body);
      final res = json.decode(response);
      if (res[errorKey]) {
        throw ApiMessageAndCodeException(
            errorMessage: res[messageKey],
            errorStatusCode: res[statusCodeKey].toString());
      }
      return res[dataKey];
    } on SocketException catch (_) {
      throw ApiMessageAndCodeException(errorMessage: StringsRes.noInternet);
    } on ApiMessageAndCodeException catch (e) {
      ApiMessageAndCodeException apiMessageAndCodeException = e;
      throw ApiMessageAndCodeException(
          errorMessage: apiMessageAndCodeException.errorMessage.toString(),
          errorStatusCode:
              apiMessageAndCodeException.errorStatusCode.toString());
    } catch (e) {
      throw ApiMessageAndCodeException(errorMessage: e.toString());
    }
  }

  Future<void> updateProfile(
      {String? email,
      String? name,
      String? mobile,
      String? referralCode}) async {
    try {
      //body of post request
      Map<String, String> body = {
        emailKey: email!,
        nameKey: name!,
        mobileKey: mobile!,
        referralCodeKey: referralCode!
      };
      final result = await Api.post(
          body: body, url: Api.updateUserUrl, token: true, errorCode: true);
      return result;
    } catch (e) {
      ApiMessageAndCodeException apiMessageAndCodeException =
          e as ApiMessageAndCodeException;
      throw ApiMessageAndCodeException(
          errorMessage: apiMessageAndCodeException.errorMessage,
          errorStatusCode: apiMessageAndCodeException.errorStatusCode);
    }
  }
}
