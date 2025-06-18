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
