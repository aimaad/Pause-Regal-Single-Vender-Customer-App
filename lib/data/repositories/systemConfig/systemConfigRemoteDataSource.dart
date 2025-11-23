import 'package:erestroSingleVender/data/model/settingModel.dart';
import 'package:erestroSingleVender/utils/api.dart';
import 'package:erestroSingleVender/utils/apiBodyParameterLabels.dart';
import 'package:erestroSingleVender/utils/apiMessageException.dart';

class SystemConfigRemoteDataSource {
  Future<SettingModel> getSystemConfing(String? userId) async {
    try {
      final body = {};
      if (userId != "") {
        body[userIdKey] = userId;
      }
      final result = await Api.post(
          body: body, url: Api.getSettingsUrl, token: true, errorCode: false);
      return SettingModel.fromJson(result);
    } catch (e) {
      print("error: ${e.toString()}");
      throw ApiMessageException(errorMessage: e.toString());
    }
  }

  Future<String> getAppSettings(String type) async {
    try {
      final body = {};
      final result = await Api.post(
          body: body, url: Api.getSettingsUrl, token: true, errorCode: false);
      return result[dataKey][type][0].toString();
    } catch (e) {
      throw ApiMessageException(errorMessage: e.toString());
    }
  }
}
