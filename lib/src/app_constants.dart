import 'package:google_maps_helper/gmh_models.dart';

enum ApiMethod { get, post }

abstract class BaseURLs {
  static const placesNew = 'https://places.googleapis.com/v1/places';
  static const directions =
      'https://maps.googleapis.com/maps/api/directions/json';
  static const geocode = 'https://maps.googleapis.com/maps/api/geocode/json';
}

abstract class ApiKeys {
  static const key = 'key';
  static const lat = 'lat';
  static const lng = 'lng';
  static const mode = 'mode';
  static const input = 'input';
  static const avoid = 'avoid';
  static const points = 'points';
  static const routes = 'routes';
  static const origin = 'origin';
  static const result = 'result';
  static const radius = 'radius';
  static const latlng = 'latlng';
  static const address = 'address';
  static const country = 'country';
  static const placeId = 'place_id';
  static const location = 'location';
  static const language = 'language';
  static const geometry = 'geometry';
  static const waypoints = 'waypoints';
  static const components = 'components';
  static const destination = 'destination';
  static const predictions = 'predictions';
  static const description = 'description';
  static const transitMode = 'transit_mode';
  static const strictbounds = 'strictbounds';
  static const overviewPolyline = 'overview_polyline';
  static const optimizeWaypoints = 'optimize_waypoints';
}

extension TravelModeData on TravelMode {
  String get str {
    switch (this) {
      case TravelMode.driving:
        return 'driving';
      case TravelMode.walking:
        return 'walking';
      case TravelMode.bicycling:
        return 'bicycling';
      case TravelMode.transit:
        return 'transit';
      case TravelMode.truck:
        return 'truck';
    }
  }
}

extension AvoidableFeatureData on AvoidableFeature {
  String get str {
    switch (this) {
      case AvoidableFeature.tolls:
        return 'tolls';
      case AvoidableFeature.highways:
        return 'highways';
      case AvoidableFeature.ferries:
        return 'ferries';
      case AvoidableFeature.indoor:
        return 'indoor';
    }
  }
}

extension TransitModeData on TransitMode {
  String get str {
    switch (this) {
      case TransitMode.bus:
        return 'bus';
      case TransitMode.subway:
        return 'subway';
      case TransitMode.train:
        return 'train';
      case TransitMode.tram:
        return 'tram';
      case TransitMode.rail:
        return 'rail';
    }
  }
}
