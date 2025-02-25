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

    if (!res.success) return null;

    try {
      return GmhAddressData(
        placeId: res.data['results'][0]['place_id'],
        address: res.data['results'][0]['formatted_address'],
        lat: res.data['results'][0]['geometry']['location']['lat'],
        lng: res.data['results'][0]['geometry']['location']['lng'],
      );
    } catch (e, st) {
      _logService.logError(e, st, extra: 'address: $address');
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
    if (!res.success) return null;

    try {
      return GmhAddressData(
        placeId: res.data['results'][0]['place_id'],
        address: res.data['results'][0]['formatted_address'],
        lat: res.data['results'][0]['geometry']['location']['lat'],
        lng: res.data['results'][0]['geometry']['location']['lng'],
      );
    } catch (e, st) {
      _logService.logError(e, st, extra: 'lat: $lat, lng: $lng');
      return null;
    }
  }

  /// Get list of addresses based on text query
  Stream<List<GmhAddressData>> searchAddress({
    required String text,
    required GmhSearchParams params,
  }) async* {
    if (text.trim().isEmpty) {
      yield [];
      return;
    }

    var r1 = await _textSearch(text.trim(), params);
    yield r1;

    if (params.searchNearby) {
      final List<GmhAddressData> r2 = [...r1];
      for (int i = 0; i < r1.length; i++) {
        if (r1[i].types.contains('postal_code')) {
          r2.addAll(await _searchNearby(params.apiKey, r1[i]));
        }
      }

      yield r2;
      r1 = r2;
    }

    if (params.loc == null || params.directionsKey == null || r1.length <= 5) {
      return;
    }

    final List<GmhAddressData> r3 = [];
    for (int i = 0; i < r1.length; i++) {
      final distance = await _getDistance(
        params.directionsKey!,
        params.loc!,
        LatLng(r1[i].lat, r1[i].lng),
      );

      r3.add(r1[i].setDistance(distance));
    }

    r3.sort(
      (a, b) => (a.distance ?? 10e10).compareTo(b.distance ?? 10e10),
    );
    yield r3;
  }

  /// Text search addresses
  Future<List<GmhAddressData>> _textSearch(
    String text,
    GmhSearchParams params,
  ) async {
    final res = await _apiService.requestNew(
      apiKey: params.apiKey,
      endpoint: 'autocomplete',
      fieldMask: [
        'suggestions.placePrediction.types',
        'suggestions.placePrediction.placeId',
        'suggestions.placePrediction.text.text',
      ],
      body: {
        'input': text.trim(),
        if (params.lang != null) 'languageCode': params.lang,
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

    if (res.statusCode == 403) throw Exception(res.message);
    if (!res.success) return [];

    try {
      final List<GmhAddressData> data = [];
      final list = res.data['suggestions'] as List;
      for (int i = 0; i < list.length; i++) {
        final id = list[i]['placePrediction']['placeId'];
        final loc = await _getDetails(params.apiKey, id);
        if (loc == null) continue;
        data.add(GmhAddressData(
          lat: loc.$1,
          lng: loc.$2,
          placeId: id,
          address: list[i]['placePrediction']['text']['text'],
          types: List<String>.from(list[i]['placePrediction']['types']),
        ));
      }
      return data;
    } catch (e, st) {
      _logService.logError(
        e,
        st,
        extra: 'text: $text | params: ${params.toString()}',
      );
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
            'radius': 1000,
            'center': {'latitude': data.lat, 'longitude': data.lng}
          }
        }
      },
    );

    if (res.statusCode == 403) throw Exception(res.message);
    if (!res.success) return [];

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
      _logService.logError(e, st, extra: 'data: ${data.toString()}');
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
    if (!res.success) return null;
    try {
      return res.data['routes'][0]['legs'][0]['distance']['value'];
    } catch (e, st) {
      _logService.logError(
        e,
        st,
        extra:
            'origin: (${origin.latitude}, ${origin.longitude}) | dest: (${dest.latitude}, ${dest.longitude})',
      );
      return null;
    }
  }

  /// Get geocodes using place ID
  Future<(double, double)?> _getDetails(String apiKey, String placeId) async {
    final res = await _apiService.requestNew(
      isGet: true,
      apiKey: apiKey,
      useBaseURL: false,
      fieldMask: ['location'],
      endpoint: '${BaseURLs.placesNew}/$placeId',
    );

    if (res.statusCode == 403) throw Exception(res.message);
    if (!res.success) return null;

    try {
      final lat = res.data['location']['latitude'] as double;
      final lng = res.data['location']['longitude'] as double;
      return (lat, lng);
    } catch (e, st) {
      _logService.logError(e, st, extra: 'placeId: $placeId');
      return null;
    }
  }
}
