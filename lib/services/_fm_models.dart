import 'package:free_map/services/fm_models.dart';

enum FMGeocodeJsonType { point, polygon, unknown }

extension FMGeocodeJsonTypeData on String {
  FMGeocodeJsonType get geocodeJsonType {
    switch (trim().toLowerCase()) {
      case 'point':
        return FMGeocodeJsonType.point;
      case 'polygon':
        return FMGeocodeJsonType.polygon;
      default:
        return FMGeocodeJsonType.unknown;
    }
  }
}

class FMGeocodeModel {
  final String lat;
  final String lng;
  const FMGeocodeModel(this.lat, this.lng);
}

class FMGeoJsonModel {
  final FMGeocodeJsonType type;
  final List<FMGeocodeModel> coordinates;
  const FMGeoJsonModel({required this.type, required this.coordinates});

  factory FMGeoJsonModel.fromJSON(Map<String, dynamic> data) {
    final List<FMGeocodeModel> coordinates = [];
    final type = '${data['type']}'.geocodeJsonType;

    switch (type) {
      case FMGeocodeJsonType.point:
        coordinates.add(FMGeocodeModel(
          '${data['coordinates'][0]}',
          '${data['coordinates'][1]}',
        ));
        break;
      case FMGeocodeJsonType.polygon:
        final l = (data['coordinates'][0] as List?)
            ?.map((e) => FMGeocodeModel('${e[0]}', '${e[1]}'));
        if (l != null) coordinates.addAll(l);
        break;
      default:
    }

    return FMGeoJsonModel(type: type, coordinates: coordinates);
  }
}

class FMRawData {
  final double lat;
  final double lng;
  final String type;
  final String name;
  final String osmId;
  final String osmType;
  final String placeId;
  final String license;
  final String category;
  final String placeRank;
  final String importance;
  final String addressType;
  final String displayName;
  final FMAddress? address;
  final FMGeoJsonModel? geoJson;
  final List<String> boundingBox;

  const FMRawData({
    required this.lat,
    required this.lng,
    required this.type,
    required this.name,
    required this.osmId,
    required this.osmType,
    required this.placeId,
    required this.license,
    required this.geoJson,
    required this.address,
    required this.category,
    required this.placeRank,
    required this.importance,
    required this.addressType,
    required this.displayName,
    required this.boundingBox,
  });

  factory FMRawData.fromJSON(Map<String, dynamic> data) {
    return FMRawData(
      type: '${data['type'] ?? ''}',
      name: '${data['name'] ?? ''}',
      osmId: '${data['osm_id'] ?? ''}',
      lat: double.parse('${data['lat']}'),
      lng: double.parse('${data['lon']}'),
      license: '${data['licence'] ?? ''}',
      osmType: '${data['osm_type'] ?? ''}',
      placeId: '${data['place_id'] ?? ''}',
      category: '${data['category'] ?? ''}',
      placeRank: '${data['place_rank'] ?? ''}',
      importance: '${data['importance'] ?? ''}',
      addressType: '${data['address_type'] ?? ''}',
      displayName: '${data['display_name'] ?? ''}',
      address:
          data['address'] == null ? null : FMAddress.fromJSON(data['address']),
      geoJson: data['geojson'] == null
          ? null
          : FMGeoJsonModel.fromJSON(data['geojson']),
      boundingBox:
          (data['boundingbox'] as List<dynamic>?)?.map((e) => '$e').toList() ??
              [],
    );
  }

  FMData get data => FMData(
        lat: lat,
        lng: lng,
        address: displayName,
        rawAddress: address,
      );
}
