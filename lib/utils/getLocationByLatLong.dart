import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:erestroSingleVender/utils/constants.dart';
import 'package:location_geocoder/geocoder.dart';

/// Geocoding and reverse geocoding through requests to Google APIs.
class GetLocationByLatLong {
  static const _host = "${databaseUrl}get_location_details_by_lat_long";

  final String apiKey;
  final String? language;

  final HttpClient _httpClient;

  GetLocationByLatLong(this.apiKey, {this.language})
      : _httpClient = HttpClient();

  Future<List<Address>> findAddressesFromCoordinates(
    Coordinates coordinates,
  ) async {
    try {
      final body = {
        // "key": apiKey,
        "latitude": "${coordinates.latitude}",
        "longitude": "${coordinates.longitude}",

        // if (language != null) "language": language,
      };
      return _send(body);
    } catch (e) {
      print('errorolaksmdl k4t $e');
      rethrow;
    }
  }

  Future<List<Address>> _send(Map<String, dynamic> body) async {
    final uri = Uri.parse(_host);
    final request = await _httpClient.postUrl(uri);

    // Set the correct content type
    request.headers.contentType = ContentType(
      "application",
      "x-www-form-urlencoded",
      charset: "utf-8",
    );

    // Convert Map body -> form data string
    final formData = Uri(queryParameters: body).query;

    // Write the form data into the request
    request.write(formData);

    final response = await request.close();
    final responseBody = await utf8.decoder.bind(response).join();

    var data = jsonDecode(responseBody);
    log('>> > $data and ${data.runtimeType}');
    var results = [data['data']];

    // if (results == null) return [];
    print('Lakjsndlakmnsdlkamsdlkamsdkamlkdsm');
    return results
        .map(_convertAddress)
        .map<Address>((map) => Address.fromMap(map))
        .toList();
  }

  Map? _convertCoordinates(dynamic geometry) {
    if (geometry == null) return null;

    var location = geometry['location'];
    if (location == null) return null;

    return {'latitude': location['lat'], 'longitude': location['lng']};
  }

  Map _convertAddress(dynamic data) {
    var result = {};

    result['coordinates'] = _convertCoordinates(data['geometry']);
    result['addressLine'] = data['formatted_address'];

    var addressComponents = data['address_components'];
    addressComponents.forEach((item) {
      List types = item['types'];

      if (types.contains('route')) {
        result['thoroughfare'] = item['long_name'];
      } else if (types.contains('street_number')) {
        result['subThoroughfare'] = item['long_name'];
      } else if (types.contains('country')) {
        result['countryName'] = item['long_name'];
        result['countryCode'] = item['short_name'];
      } else if (types.contains('locality')) {
        result['locality'] = item['long_name'];
      } else if (types.contains('postal_code')) {
        result['postalCode'] = item['long_name'];
      } else if (types.contains('administrative_area_level_1')) {
        result['adminArea'] = item['long_name'];
      } else if (types.contains('administrative_area_level_2')) {
        result['subAdminArea'] = item['long_name'];
      } else if (types.contains('sublocality') ||
          types.contains('sublocality_level_1')) {
        result['subLocality'] = item['long_name'];
      } else if (types.contains('premise')) {
        result['featureName'] = item['long_name'];
      }

      result['featureName'] = result['featureName'] ?? result['addressLine'];
    });

    return result;
  }
}
