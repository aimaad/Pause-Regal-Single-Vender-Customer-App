import 'package:erestroSingleVender/data/localDataStore/addressLocalDataSource.dart';
import 'package:erestroSingleVender/data/model/addressModel.dart';
import 'package:erestroSingleVender/data/model/getLocationDetailsModel.dart';
import 'package:erestroSingleVender/data/model/search_location_model.dart';
import 'package:erestroSingleVender/data/repositories/address/addressRemoteDataSource.dart';
import 'package:erestroSingleVender/utils/apiBodyParameterLabels.dart';
import 'package:erestroSingleVender/utils/apiMessageAndCodeException.dart';

class AddressRepository {
  static final AddressRepository _addressRepository =
      AddressRepository._internal();
  late AddressRemoteDataSource _addressRemoteDataSource;
  late AddressLocalDataSource _addressLocalDataSource;

  factory AddressRepository() {
    _addressRepository._addressRemoteDataSource = AddressRemoteDataSource();
    _addressRepository._addressLocalDataSource = AddressLocalDataSource();
    return _addressRepository;
  }

  AddressRepository._internal();
  AddressLocalDataSource get addressLocalDataSource => _addressLocalDataSource;

  Future<List<AddressModel>> getAddress() async {
    try {
      List<AddressModel> result = await _addressRemoteDataSource.getAddress();
      return result;
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

  Future getAddAddress(
      String? mobile,
      String? address,
      String? cityId,
      String? latitude,
      String? longitude,
      String? area,
      String? type,
      String? name,
      String? countryCode,
      String? alternateCountryCode,
      String? alternateMobile,
      String? landmark,
      String? pincode,
      String? state,
      String? country,
      String? isDefault) async {
    try {
      final result = await _addressRemoteDataSource.addAddress(
          mobile,
          address,
          cityId,
          latitude,
          longitude,
          area,
          type,
          name,
          countryCode,
          alternateCountryCode,
          alternateMobile,
          landmark,
          pincode,
          state,
          country,
          isDefault);
      _addressLocalDataSource.setCity(result['city']);
      _addressLocalDataSource.setLatitude(result['latitude']);
      _addressLocalDataSource.setLongitude(result['longitude']);
      _addressLocalDataSource.getCity();
      return result;
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

  Future getUpdateAddress(
      String? id,
      String? userId,
      String? mobile,
      String? address,
      String? city,
      String? latitude,
      String? longitude,
      String? area,
      String? type,
      String? name,
      String? countryCode,
      String? alternateCountryCode,
      String? alternateMobile,
      String? landmark,
      String? pincode,
      String? state,
      String? country,
      String? isDefault) async {
    try {
      final result = await _addressRemoteDataSource.updateAddress(
          id ?? "",
          userId,
          mobile,
          address,
          city,
          latitude,
          longitude,
          area ?? "",
          type,
          name,
          countryCode,
          alternateCountryCode,
          alternateMobile ?? "",
          landmark ?? "",
          pincode ?? "",
          state ?? "",
          country ?? "",
          isDefault ?? "");
      _addressLocalDataSource.setCity(result['city']);
      _addressLocalDataSource.setLatitude(result['latitude']);
      _addressLocalDataSource.setLongitude(result['longitude']);
      return result;
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

  Future getDeleteAddress(String? id) async {
    try {
      final result = await _addressRemoteDataSource.deleteAddress(id);
      return result;
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

  Future getCityDeliverable(
      String? name, String? latitude, String? longitude) async {
    try {
      final result = await _addressRemoteDataSource.checkCityDeliverable(
          name, latitude, longitude);
      await _addressLocalDataSource.setCityId(result['$cityIdKey']);

      return result;
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

  Future getIsOrderDeliverable(String? branchId, String? latitude,
      String? longitude, String? addressId) async {
    try {
      final result = await _addressRemoteDataSource.checkIsOrderDeliverable(
          branchId, latitude, longitude, addressId);
      return result[messageKey];
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

  Future<Map> getDeliveryCharge(
      String? addressId, String? finalTotal, String? branchId) async {
    try {
      final result = await _addressRemoteDataSource.checkDeliveryChargeCubit(
          addressId, finalTotal, branchId);

      return Map.from(result);
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

  Future<SearchLocationModel> getSearchLocation(String search) async {
    try {
      final result = await _addressRemoteDataSource.searchLocation(search);

      return result;
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

  Future<LocationDetailsModel> getlocationDetails(String? placeId) async {
    try {
      if (placeId == null || placeId.isEmpty) {
        throw ApiMessageAndCodeException(
            errorMessage: "Place ID cannot be empty", errorStatusCode: "400");
      }

      final result = await _addressRemoteDataSource.locationDetails(placeId);
      return result;
    } on ApiMessageAndCodeException catch (e) {
      throw ApiMessageAndCodeException(
          errorMessage: e.errorMessage.toString(),
          errorStatusCode: e.errorStatusCode?.toString() ?? "500");
    } catch (e) {
      throw ApiMessageAndCodeException(
          errorMessage: e.toString(), errorStatusCode: "500");
    }
  }
}
