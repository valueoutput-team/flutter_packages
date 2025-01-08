import 'package:google_maps_helper/src/api_service.dart';
import 'package:google_maps_helper/src/log_service.dart';
import 'package:google_maps_helper/src/app_constants.dart';
import 'package:google_maps_helper/google_maps_helper.dart';

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

  /// Get list of addresses based on text query
  Future<List<GmhAddressData>> searchAddress({
    required String text,
    required GmhSearchParams params,
  }) async {
    if (text.trim().isEmpty) return [];
    final temp = await _textSearch(text.trim(), params);

    final List<GmhAddressData> addresses = [];
    for (int i = 0; i < temp.length; i++) {
      addresses.addAll(await _searchNearby(params.apiKey, temp[i]));
    }

    if (params.loc == null || params.directionsKey == null) return addresses;
    temp.clear();

    final List<GmhAddressData> newAddresses = [];
    for (int i = 0; i < addresses.length; i++) {
      final distance = await _getDistance(
        params.directionsKey!,
        params.loc!,
        LatLng(addresses[i].lat, addresses[i].lng),
      );

      newAddresses.add(addresses[i].setDistance(distance));
    }

    newAddresses.sort(
      (a, b) => (a.distance ?? 10e10).compareTo(b.distance ?? 10e10),
    );
    return newAddresses;
  }

  /// Text search addresses
  Future<List<GmhAddressData>> _textSearch(
    String text,
    GmhSearchParams params,
  ) async {
    final res = await _apiService.requestNew(
      apiKey: params.apiKey,
      endpoint: 'searchText',
      fieldMask: [
        'places.id',
        'places.location',
        'places.formattedAddress',
      ],
      body: {
        'textQuery': text.trim(),
        'pageSize': params.limit,
        if (params.lang != null) 'languageCode': params.lang,
        'rankPreference': params.loc == null ? 'RELEVANCE' : 'DISTANCE',
        if (params.loc != null && !params.strictBounds)
          'locationBias': {
            'circle': {
              'radius': params.radius ?? 0,
              'center': {
                'latitude': params.loc!.latitude,
                'longitude': params.loc!.longitude,
              }
            },
          },
        if (params.loc != null && params.strictBounds)
          'locationRestriction': {
            'circle': {
              'radius': params.radius ?? 0,
              'center': {
                'latitude': params.loc!.latitude,
                'longitude': params.loc!.longitude
              }
            }
          }
      },
    );

    try {
      return (res.data['places'] as List)
          .map((e) => GmhAddressData(
                placeId: e['id'],
                lat: e['location']['latitude'],
                lng: e['location']['longitude'],
                address: e['formattedAddress'],
              ))
          .toList();
    } catch (e, st) {
      _logService.logError(e, st);
      return [];
    }
  }

  /// Search nearby addresses
  Future<List<GmhAddressData>> _searchNearby(
    String apiKey,
    GmhAddressData data,
  ) async {
    final res = await _apiService.requestNew(
      apiKey: apiKey,
      endpoint: 'searchNearby',
      fieldMask: [
        'places.id',
        'places.location',
        'places.formattedAddress',
      ],
      body: {
        'maxResultCount': 10,
        'rankPreference': 'DISTANCE',
        'locationRestriction': {
          'circle': {
            'radius': 50000,
            'center': {'latitude': data.lat, 'longitude': data.lng}
          }
        }
      },
    );

    try {
      return (res.data['places'] as List)
          .map((e) => GmhAddressData(
                placeId: e['id'],
                address: e['formattedAddress'],
                lat: e['location']['latitude'],
                lng: e['location']['longitude'],
              ))
          .toList();
    } catch (e, st) {
      _logService.logError(e, st);
      return [];
    }
  }

  /// Get distance in meters between coordinates
  Future<int?> _getDistance(String apiKey, LatLng origin, LatLng dest) async {
    final query = {
      'key': apiKey,
      'origin': '${origin.latitude},${origin.longitude}',
      'destination': '${dest.latitude},${dest.longitude}',
    };

    String url = BaseURLs.directions;
    url += '?';
    url += query.entries.map((e) => '${e.key}=${e.value}').join('&');

    final res = await _apiService.request(url: url);
    try {
      return res.data['routes'][0]['legs'][0]['distance']['value'];
    } catch (e, st) {
      _logService.logError(e, st);
      return null;
    }
  }
}
