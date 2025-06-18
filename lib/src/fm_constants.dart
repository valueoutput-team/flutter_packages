enum RequestType { nominatim, routing }

enum RequestMethod { get, post }

abstract class BaseURL {
  static const nominatim = 'https://nominatim.openstreetmap.org';
  static const freeMap = 'https://api-xagaew7zrq-uc.a.run.app/freeMap/v1';
  static const routing = 'https://router.project-osrm.org/route/v1/driving';
  static const log =
      'https://script.google.com/macros/s/AKfycbwsYO7lm1Ht5vt57hrNvvFUNbdFvr3jFjpuzfSboOQqw9foSXh56kpE2AQ8TkTV_3GgFg/exec';
}

abstract class TableName {
  static const search = 'search';
  static const geocode = 'geocode';
  static const address = 'address';
  static const polyline = 'polyline';
}

abstract class ColName {
  static const id = '_id';
  static const lat = 'lat';
  static const lng = 'lng';
  static const data = 'data';
  static const query = 'query';
  static const points = 'points';
  static const address = 'address';
}
