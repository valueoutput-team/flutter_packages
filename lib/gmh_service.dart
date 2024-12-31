import 'package:google_maps_helper/gmh_models.dart';
import 'package:google_maps_helper/src/api_service.dart';
import 'package:google_maps_helper/src/log_service.dart';
import 'package:google_maps_helper/src/app_constants.dart';

class GmhService {
  final _apiService = ApiService();
  final _logService = LogService();
  static final _instance = GmhService._();

  GmhService._();

  factory GmhService() => _instance;

  /// GEOCODING: Get geocode from an address
  Future<GmhAddressData?> getGeocode({
    required String apiKey,
    required String address,
  }) async {
    final res = await _apiService.request(
      url: '${BaseURLs.geocode}?key=$apiKey&address=$address',
    );

    try {
      return GmhAddressData(
        placeId: res.data['results'][0]['place_id'],
        address: res.data['results'][0]['formatted_address'],
        lat: res.data['results'][0]['geometry']['location']['lat'],
        lng: res.data['results'][0]['geometry']['location']['lng'],
      );
    } catch (e, st) {
      _logService.logError(e, st);
      return null;
    }
  }

  /// REVERSE GEOCODING: Get address from geocode
  Future<GmhAddressData?> getAddress({
    required double lat,
    required double lng,
    required String apiKey,
  }) async {
    final res = await _apiService.request(
      url: '${BaseURLs.geocode}?key=$apiKey&latlng=$lat,$lng',
    );

    try {
      return GmhAddressData(
        placeId: res.data['results'][0]['place_id'],
        address: res.data['results'][0]['formatted_address'],
        lat: res.data['results'][0]['geometry']['location']['lat'],
        lng: res.data['results'][0]['geometry']['location']['lng'],
      );
    } catch (e, st) {
      _logService.logError(e, st);
      return null;
    }
  }
}
