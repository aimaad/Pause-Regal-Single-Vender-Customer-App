import 'dart:io';
import 'package:erestroSingleVender/data/model/helpAndSupportModel.dart';
import 'package:erestroSingleVender/utils/api.dart';
import 'package:erestroSingleVender/utils/apiBodyParameterLabels.dart';
import 'package:erestroSingleVender/utils/apiMessageAndCodeException.dart';
import 'package:erestroSingleVender/utils/apiMessageException.dart';

class HelpAndSupportRemoteDataSource {
  Future<List<HelpAndSupportModel>> getHelpAndSupport() async {
    try {
      final body = {};
      final result = await Api.post(
          body: body,
          url: Api.getTicketTypesUrl,
          token: true,
          errorCode: false);
      return (result[dataKey] as List)
          .map((e) => HelpAndSupportModel.fromJson(Map.from(e)))
          .toList();
    } catch (e) {
      throw ApiMessageException(errorMessage: e.toString());
    }
  }

  Future getAddTicket(String? ticketTypeId, String? subject, String? email,
      String? description) async {
    try {
      final body = {
        ticketTypeIdKey: ticketTypeId,
        subjectKey: subject,
        emailKey: email,
        descriptionKey: description
      };
      final result = await Api.post(
          body: body, url: Api.addTicketUrl, token: true, errorCode: true);
      return result[dataKey];
    } catch (e) {
      ApiMessageAndCodeException apiMessageAndCodeException =
          e as ApiMessageAndCodeException;
      throw ApiMessageAndCodeException(
          errorMessage: apiMessageAndCodeException.errorMessage,
          errorStatusCode: apiMessageAndCodeException.errorStatusCode);
    }
  }

  Future getEditTicket(String? ticketId, String? ticketTypeId, String? subject,
      String? email, String? description, String? status) async {
    try {
      final body = {
        ticketIdKey: ticketId,
        ticketTypeIdKey: ticketTypeId,
        subjectKey: subject,
        emailKey: email,
        descriptionKey: description,
        statusKey: status
      };
      final result = await Api.post(
          body: body, url: Api.editTicketUrl, token: true, errorCode: true);
      return result[dataKey];
    } catch (e) {
      ApiMessageAndCodeException apiMessageAndCodeException =
          e as ApiMessageAndCodeException;
      throw ApiMessageAndCodeException(
          errorMessage: apiMessageAndCodeException.errorMessage,
          errorStatusCode: apiMessageAndCodeException.errorStatusCode);
    }
  }

  Future setMessage(String? userType, String? ticketId, String? message,
      List<File>? attachments) async {
    try {
      final body = {
        userTypeKey: userType,
        ticketIdKey: ticketId,
        messageKey: message
      };
      final result = await Api.post(
          body: body, url: Api.sendMessageUrl, token: true, errorCode: true);
      return result[dataKey];
    } catch (e) {
      throw ApiMessageAndCodeException(errorMessage: e.toString());
    }
  }
}
