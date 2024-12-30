import 'dart:math' as math;
import 'package:free_map/src/services/api_service.dart';
import 'package:free_map/src/services/log_service.dart';
import 'package:free_map/fm_models.dart';
import 'package:free_map/src/models/_fm_models.dart';
import 'package:latlong2/latlong.dart';

class FmService {
  final _apiService = ApiService();
  final _logService = LogService();
  static final _instance = FmService._();
  final _searchEndpoint = '/search.php';
  final _reverseEndpoint = '/reverse.php';
  final _baseURL = 'https://nominatim.openstreetmap.org';
  final _polylineURL = 'https://router.project-osrm.org/route/v1/driving';

  FmService._();

  factory FmService() => _instance;

  /// GEOCODING: Get geocode from an address
  Future<FmData?> getGeocode({required String address}) async {
    final query = {
      'limit': 1,
      'format': 'jsonv2',
      'q': address.trim(),
      'polygon_geojson': 1,
    };

    String url = _baseURL;
    url += _searchEndpoint;
    url += '?${query.keys.map((k) => '$k=${query[k]}').join('&')}';

    final res = await _apiService.request(url: url);

    try {
      return (res.data as List)
          .map((e) => FMRawData.fromJSON(e).data)
          .firstOrNull;
    } catch (e, st) {
      _logService.logError(e, st);
      return null;
    }
  }

  /// REVERSE GEOCODING: Get address from geocode
  Future<FmData?> getAddress({required double lat, required double lng}) async {
    String url = _baseURL;
    url += _reverseEndpoint;
    final query = {'lat': lat, 'lon': lng, 'format': 'jsonv2'};
    url += '?${query.keys.map((k) => '$k=${query[k]}').join('&')}';

    final res = await _apiService.request(url: url);

    try {
      return FMRawData.fromJSON(res.data).data;
    } catch (e, st) {
      _logService.logError(e, st);
      return null;
    }
  }

  /// Search addresses using query
  Future<List<FmData>> search({
    required String q,
    required FmSearchParams p,
  }) async {
    if (q.trim().isEmpty) return [];

    final box = await _calculateBoundingBox(p.loc, p.radius);

    final query = {
      'limit': 10,
      'q': q.trim(),
      'format': 'jsonv2',
      'polygon_geojson': 1,
      'accept-language': p.langs.map((e) => e.trim()).join(','),
      if (p.countries != null)
        'countrycodes': p.countries?.map((e) => e.trim()).join(','),
      if (box != null) 'bounded': 1,
      if (box != null) 'viewbox': '${box[0]},${box[1]},${box[2]},${box[3]}',
    };

    String url = _baseURL;
    url += _searchEndpoint;
    url += '?${query.keys.map((k) => '$k=${query[k]}').join('&')}';

    final res = await _apiService.request(url: url);

    try {
      return (res.data as List).map((e) => FMRawData.fromJSON(e).data).toList();
    } catch (e, st) {
      _logService.logError(e, st);
      return [];
    }
  }

  /// Get polyline points
  Future<List<LatLng>> getPolyline(List<LatLng> points) async {
    final List<LatLng> polylinePoints = [];
    for (int i = 0; i < points.length - 1; i++) {
      final sLat = points[i].latitude;
      final sLng = points[i].longitude;
      final eLat = points[i + 1].latitude;
      final eLng = points[i + 1].longitude;

      final res = await _apiService.request(
        url:
            '$_polylineURL/$sLng,$sLat;$eLng,$eLat?overview=full&geometries=geojson',
      );

      try {
        final points = res.data['routes'][0]['geometry']['coordinates'] as List;
        polylinePoints.addAll(points.map((e) => LatLng(e[1], e[0])));
      } catch (e, st) {
        _logService.logError(e, st);
      }
    }

    return polylinePoints;
  }

  /// Returns a bounding box as [minLon, minLat, maxLon, maxLat]
  Future<List<double>?> _calculateBoundingBox(LatLng? pos, int? radius) async {
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
}
