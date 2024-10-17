import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:free_map/services/fm_models.dart';
import 'package:free_map/services/_fm_models.dart';

class FMService {
  static final _instance = FMService._();
  final _searchEndpoint = '/search.php';
  final _reverseEndpoint = '/reverse.php';
  final _baseURL = 'https://nominatim.openstreetmap.org';

  FMService._();

  factory FMService() {
    return _instance;
  }

  /// Get current coordinates
  Future<Position> getCurrentPosition() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw Exception('LOCATION_DISABLED');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('PERMISSION_DENIED');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('PERMISSION_DENIED');
    }

    return Geolocator.getCurrentPosition();
  }

  /// Search addresses using query
  Future<List<FMData>> search({
    FMSearchOptions? options,
    required String searchText,
    Function(Object, StackTrace)? onError,
  }) async {
    if (searchText.trim().isEmpty) return [];
    options ??= FMSearchOptions.initial();

    try {
      final query = {
        'format': 'jsonv2',
        'polygon_geojson': 1,
        'q': searchText.trim(),
        'limit': options.limit,
        'accept-language': options.langs.map((e) => e.trim()).join(','),
        if (options.countries != null)
          'countrycodes': options.countries?.map((e) => e.trim()).join(','),
      };

      String url = _baseURL;
      url += _searchEndpoint;
      url += '?${query.keys.map((k) => '$k=${query[k]}').join('&')}';

      final res = await http.get(Uri.parse(url));
      final data = jsonDecode(res.body) as List;

      if (data.isEmpty && options.maxRetries > 0) {
        return search(
          searchText: searchText,
          options: FMSearchOptions.reducedRetry(options),
        );
      }

      return data.map((e) => FMRawData.fromJSON(e).data).toList();
    } catch (e, st) {
      if (options.maxRetries > 0) {
        return search(
          searchText: searchText,
          options: FMSearchOptions.reducedRetry(options),
        );
      }

      if (onError != null) onError(e, st);
      return [];
    }
  }

  /// Get address from coordinates (Reverse Geocoding)
  Future<FMData?> getAddress({
    required double lat,
    required double lng,
    int maxRetries = 3,
    Function(Object, StackTrace)? onError,
  }) async {
    assert(maxRetries <= 5, 'Keep maxRetries less than or equal to 5');
    try {
      final query = {'lat': lat, 'lon': lng, 'zoom': 18, 'format': 'jsonv2'};
      String url = _baseURL;
      url += _reverseEndpoint;
      url += '?${query.keys.map((k) => '$k=${query[k]}').join('&')}';

      final res = await http.get(Uri.parse(url));
      return FMRawData.fromJSON(jsonDecode(res.body)).data;
    } catch (e, st) {
      if (maxRetries > 0) {
        return getAddress(lat: lat, lng: lng, maxRetries: --maxRetries);
      }
      if (onError != null) onError(e, st);
      return null;
    }
  }
}
