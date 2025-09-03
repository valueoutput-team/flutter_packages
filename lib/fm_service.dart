import 'dart:math' as math;
import 'package:latlong2/latlong.dart';
import 'package:free_map/fm_models.dart';
import 'package:free_map/src/fm_constants.dart';
import 'package:free_map/src/models/url_model.dart';
import 'package:free_map/src/services/db_service.dart';
import 'package:free_map/src/services/api_service.dart';
import 'package:free_map/src/services/log_service.dart';
import 'package:free_map/src/services/system_service.dart';

class FmService {
  FmService._();
  factory FmService() => _instance;
  static final _instance = FmService._();

  String? _userAgent;
  bool _initialized = false;
  String _freeMapURL = BaseURL.freeMap;
  UrlModel _searchURL = UrlModel(url: BaseURL.search);
  UrlModel _reverseURL = UrlModel(url: BaseURL.reverse);
  UrlModel _polylineURL = UrlModel(url: BaseURL.polyline);

  final _dbService = DbService();
  final _apiService = ApiService();
  final _logService = LogService();
  final _systemService = SystemService();

  /// Configure third-party or self-hosted API endpoints.
  ///
  /// Ensure that the request body, parameters, and HTTP method
  /// are compatible with the default OpenStreetMap services.
  ///
  /// Parameters:
  ///  - [userAgent]: The User-Agent string to send in request headers to the Nominatim server.
  ///
  /// - [searchURL]: The URL for search address requests.
  ///   Default: `https://nominatim.openstreetmap.org/search.php`
  ///
  ///- [reverseURL]: The URL for reverse geocoding requests.
  ///   Default: `https://nominatim.openstreetmap.org/reverse.php`
  ///
  /// - [polylineURL]: The URL used to fetch routes (polylines).
  ///   Default: `https://router.project-osrm.org/route/v1/driving`
  void setData({
    String? userAgent,
    String? searchURL,
    String? reverseURL,
    String? polylineURL,
  }) {
    if (userAgent != null) _userAgent = userAgent;
    if (searchURL != null && searchURL != BaseURL.search) {
      if (!_validURL(searchURL)) throw Exception('Invalid search URL');
      _searchURL = UrlModel(url: searchURL, isCustom: true);
    }
    if (reverseURL != null && reverseURL != BaseURL.reverse) {
      if (!_validURL(reverseURL)) throw Exception('Invalid reverse URL');
      _reverseURL = UrlModel(url: reverseURL, isCustom: true);
    }
    if (polylineURL != null && polylineURL != BaseURL.polyline) {
      if (!_validURL(polylineURL)) throw Exception('Invalid polyline URL');
      _polylineURL = UrlModel(url: polylineURL, isCustom: true);
    }
  }

  /// GEOCODING: Retrieves geocode information from an address.
  ///
  /// Setting [geoJson] to `true` will load heavy data and may slow down the API call.
  /// Use it only if detailed geographic data is required.
  Future<FmData?> getGeocode({
    bool geoJson = false,
    required String address,
  }) async {
    address = address.trim();
    if (address.isEmpty) return null;

    // 1. Check local db
    try {
      final data = await _dbService.getGeocode(address);
      if (data != null && (!geoJson || data['geojson'] != null)) {
        return FmData.fromJSON(data);
      }
    } catch (e, st) {
      _logService.logError(e, st);
    }

    // 2. Wait for new API call
    final success = await _waitForNewRequest(RequestType.nominatim);
    if (!success) return null;

    // 3. Make API call
    final query = {
      'limit': 1,
      'q': address,
      'format': 'jsonv2',
      'polygon_geojson': geoJson ? 1 : 0,
    };

    final url =
        '${_searchURL.url}?${query.keys.map((k) => '$k=${query[k]}').join('&')}';

    final res = await _apiService.request(
      url: url,
      userAgent: _userAgent ?? _systemService.userAgent,
    );

    // 4. Parse & save response to local db
    try {
      final data = (res.data as List).firstOrNull;
      if (data == null) return null;
      await _dbService.saveGeocode(address, data);
      return FmData.fromJSON(data);
    } catch (e, st) {
      _logService.logError(e, st, req: address, res: res.toString());
      return null;
    }
  }

  /// REVERSE GEOCODING: Get address from geocode
  Future<FmData?> getAddress({required double lat, required double lng}) async {
    // 1. Check local db
    try {
      final data = await _dbService.getAddress(lat, lng);
      if (data != null) return FmData.fromJSON(data);
    } catch (e, st) {
      _logService.logError(e, st);
    }

    // 2. Wait for new request
    final success = await _waitForNewRequest(RequestType.nominatim);
    if (!success) return null;

    // 3. Make API call
    final query = {'lat': lat, 'lon': lng, 'format': 'jsonv2'};
    final url =
        '${_reverseURL.url}?${query.keys.map((k) => '$k=${query[k]}').join('&')}';

    final res = await _apiService.request(
      url: url,
      userAgent: _userAgent ?? _systemService.userAgent,
    );

    // 4. Parse & save response to local db
    try {
      await _dbService.saveAddress(lat, lng, res.data);
      return FmData.fromJSON(res.data);
    } catch (e, st) {
      _logService.logError(e, st, req: '($lat, $lng)', res: res.toString());
      return null;
    }
  }

  /// Search addresses using query
  ///
  /// Setting [geoJson] to `true` will load heavy data and may slow down the API call.
  /// Use it only if detailed geographic data is required.
  Future<List<FmData>> search({
    required String q,
    bool geoJson = false,
    required FmSearchParams p,
  }) async {
    q = q.trim();
    if (q.isEmpty) return [];

    // 1. Form query
    final box = _calculateBoundingBox(p.loc, p.radius);
    final query = {
      'q': q,
      'limit': 10,
      'format': 'jsonv2',
      'polygon_geojson': geoJson ? 1 : 0,
      'accept-language': p.langs.map((e) => e.trim()).join(','),
      if (p.countries != null)
        'countrycodes': p.countries?.map((e) => e.trim()).join(','),
      if (box != null) 'bounded': 1,
      if (box != null) 'viewbox': '${box[0]},${box[1]},${box[2]},${box[3]}',
    };

    // 2. Check local db
    try {
      final data = await _dbService.getSearch(query);
      if (data != null) {
        return data.map((e) => FmData.fromJSON(e)).toList();
      }
    } catch (e, st) {
      _logService.logError(e, st);
    }

    // 3. Wait for new request
    final success = await _waitForNewRequest(RequestType.nominatim);
    if (!success) return [];

    // 4. Make API call
    final url =
        '${_searchURL.url}?${query.keys.map((k) => '$k=${query[k]}').join('&')}';

    final res = await _apiService.request(
      url: url,
      userAgent: _userAgent ?? _systemService.userAgent,
    );

    // 5. Parse response & save it to local db
    try {
      await _dbService.saveSearch(query, res.data);
      return (res.data as List).map((e) => FmData.fromJSON(e)).toList();
    } catch (e, st) {
      _logService.logError(
        e,
        st,
        res: res.toString(),
        req: 'query: $q | params: ${p.toString()}',
      );
      return [];
    }
  }

  /// Get polyline points
  Future<List<LatLng>> getPolyline(List<LatLng> points) async {
    if (points.isEmpty) return [];

    // 1. Check local db
    try {
      final data = await _dbService.getPolyline(
        points.map((e) => {'lat': e.latitude, 'lng': e.longitude}).toList(),
      );
      if (data != null) {
        return data.map((e) => LatLng(e['lat'], e['lng'])).toList();
      }
    } catch (e, st) {
      _logService.logError(e, st);
    }

    // 2. Get polyline between two points
    final List<LatLng> polylinePoints = [];
    for (int i = 0; i < points.length - 1; i++) {
      final sLat = points[i].latitude;
      final sLng = points[i].longitude;
      final eLat = points[i + 1].latitude;
      final eLng = points[i + 1].longitude;

      // 2a. Wait for new request
      final success = await _waitForNewRequest(RequestType.routing);
      if (!success) return [];

      // 2b. Get polyline data
      final res = await _apiService.request(
        userAgent: _userAgent ?? _systemService.userAgent,
        url:
            '${_polylineURL.url}/$sLng,$sLat;$eLng,$eLat?overview=full&geometries=geojson',
      );

      // 2c. Parse response
      try {
        final points = res.data['routes'][0]['geometry']['coordinates'] as List;
        polylinePoints.addAll(points.map((e) => LatLng(e[1], e[0])));
      } catch (e, st) {
        _logService.logError(
          e,
          st,
          res: res.toString(),
          req:
              'points: ${points.map((e) => '(${e.latitude},${e.longitude})').join(' | ')}',
        );
        return [];
      }
    }

    if (polylinePoints.isEmpty) return [];

    // 3. Save to local db
    try {
      await _dbService.savePolyline(
        points.map((e) => {'lat': e.latitude, 'lng': e.longitude}).toList(),
        polylinePoints
            .map((e) => {'lat': e.latitude, 'lng': e.longitude})
            .toList(),
      );
    } catch (e, st) {
      _logService.logError(e, st);
    }

    return polylinePoints;
  }

  /// Returns a bounding box as [minLon, minLat, maxLon, maxLat]
  List<double>? _calculateBoundingBox(LatLng? pos, int? radius) {
    if (pos == null || radius == null) return null;

    try {
      const earthRadius = 6378137.0; // Earth's radius in meters
      final latDelta = radius / earthRadius * (180 / math.pi);
      final lonDelta = radius /
          (earthRadius * math.cos(math.pi * pos.latitude / 180)) *
          (180 / math.pi);

      final minLat = pos.latitude - latDelta;
      final maxLat = pos.latitude + latDelta;
      final minLon = pos.longitude - lonDelta;
      final maxLon = pos.longitude + lonDelta;

      return [minLon, minLat, maxLon, maxLat];
    } catch (e) {
      return null;
    }
  }

  /// Fetch base URLs
  Future<void> init() async {
    if (_initialized) return;

    // 1. Get package name
    await _systemService.init();
    if (_systemService.packageName == null) return;

    // 2. Get URLs
    final res = await _apiService.request(
      method: RequestMethod.post,
      url: '${BaseURL.freeMap}/urls',
      body: {'deviceId': '1', 'appId': _systemService.packageName},
    );

    _initialized = res.success;

    // 3. Update base URLs
    try {
      _freeMapURL = res.data['data']['fm'];
      _logService.logURL = res.data['data']['log'];
      final searchURL = res.data['data']['search'];
      final reverseURL = res.data['data']['reverse'];
      final routingURL = res.data['data']['polyline'];

      // Ensure the custom URL set by the developer is not overridden.
      if ((_searchURL.isCustom && _searchURL.url == searchURL) ||
          (!_searchURL.isCustom && _searchURL.url != searchURL)) {
        _searchURL = UrlModel(url: searchURL);
      }

      if ((_reverseURL.isCustom && _reverseURL.url == reverseURL) ||
          (!_reverseURL.isCustom && _reverseURL.url != reverseURL)) {
        _reverseURL = UrlModel(url: reverseURL);
      }

      if ((_polylineURL.isCustom && _polylineURL.url == routingURL) ||
          (!_polylineURL.isCustom && _polylineURL.url != routingURL)) {
        _polylineURL = UrlModel(url: routingURL);
      }
    } catch (e, st) {
      _logService.logError(e, st);
    }
  }

  /// Wait for new request
  Future<bool> _waitForNewRequest(RequestType type) async {
    // 1. Return if developer using self-hosted or third-party servers
    if (type == RequestType.routing && _polylineURL.isCustom) return true;
    if (type == RequestType.nominatim && _searchURL.isCustom) return true;

    // 2. Fetch base URLs
    await init();

    // 3. Get wait-time for new request
    final res = await _apiService.request(
      method: RequestMethod.post,
      url: '$_freeMapURL/waitTime',
      body: {
        'deviceId': '1',
        'type': '${type.index}',
        'appId': _systemService.packageName,
      },
    );

    // 4. Wait for the given time, before returning
    try {
      final execTime = res.data['data']['execTime'];
      final waitTime = execTime - DateTime.now().millisecondsSinceEpoch;
      if (waitTime <= 0) return true;
      await Future.delayed(Duration(milliseconds: waitTime));
      return true;
    } catch (e, st) {
      _logService.logError(e, st);
      return false;
    }
  }

  /// Validates a URL string.
  bool _validURL(String url) {
    return RegExp(
      r"^(https?:\/\/)((([a-zA-Z0-9-]{1,63}\.)+[a-zA-Z]{2,63})|(localhost)|(\d{1,3}(\.\d{1,3}){3}))(:\d{1,5})?(\/[a-zA-Z0-9\-._~%!$&\'()*+,;=:@/]*)?(\?[a-zA-Z0-9\-._~%!$&\'()*+,;=:@/?]*)?(\#[a-zA-Z0-9\-._~%!$&\'()*+,;=:@/?]*)?$",
    ).hasMatch(url);
  }
}
