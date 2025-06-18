import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:free_map/src/models/_fm_models.dart';
import 'package:latlong2/latlong.dart';

class FmSearchParams {
  /// country codes to search in particular countries only
  final List<String>? countries;

  /// language codes to allow languages in the search results
  final List<String> langs;

  /// The latitude and longitude coordinates to search around.
  final LatLng? loc;

  /// The radius (in meters) within which to return place results.
  final int? radius;

  /// Parameters for search functionality.
  const FmSearchParams({
    this.loc,
    this.radius,
    this.countries,
    this.langs = const ['en'],
  }) : assert(radius == null || radius > 0, 'radius must be greater than 0');

  @override
  String toString() {
    return 'loc: (${loc?.latitude}, ${loc?.longitude}), radius: $radius, countries: [${countries?.join(', ')}], langs: [${langs.join(', ')}]';
  }
}

class FmResultViewOptions {
  /// The maximum height of the result view overlay.
  final double maxHeight;

  /// The maximum height of the result view overlay.
  final Widget? emptyView;

  /// The widget to display when there is no input text.
  final Widget? noTextView;

  /// The widget to display while loading results.
  final Widget? loadingView;

  /// The padding for the result view overlay.
  final EdgeInsets? padding;

  /// The decoration for the result view overlay.
  final BoxDecoration? overlayDecoration;

  /// receive callback when result overlay visibility changes
  /// USE CASE: ignore background pointers & unfocus text field when overlay is visible
  final Function(bool)? onOverlayVisible;

  /// A builder function for customizing the separator between list items.
  final Widget Function(BuildContext, int)? separatorBuilder;

  /// A builder function for customizing the appearance of list items.
  final Widget Function(BuildContext, int, FmData)? itemBuilder;

  /// Options for customizing the result view
  const FmResultViewOptions({
    this.padding,
    this.emptyView,
    this.noTextView,
    this.loadingView,
    this.itemBuilder,
    this.maxHeight = 200,
    this.separatorBuilder,
    this.onOverlayVisible,
    this.overlayDecoration,
  });
}

class FmData {
  final double lat;
  final double lng;
  final String type;
  final String name;
  final String osmId;
  final String osmType;
  final String placeId;
  final String address;
  final String license;
  final String category;
  final String placeRank;
  final String importance;
  final String addressType;
  final FmAddress? rawAddress;
  final FMGeoJsonModel? geoJson;
  final List<double> boundingBox;

  const FmData({
    required this.lat,
    required this.lng,
    required this.type,
    required this.name,
    required this.osmId,
    required this.osmType,
    required this.placeId,
    required this.address,
    required this.license,
    required this.geoJson,
    required this.category,
    required this.placeRank,
    required this.rawAddress,
    required this.importance,
    required this.addressType,
    required this.boundingBox,
  });

  factory FmData.fromJSON(Map<String, dynamic> data) {
    return FmData(
      type: '${data['type'] ?? ''}',
      name: '${data['name'] ?? ''}',
      osmId: '${data['osm_id'] ?? ''}',
      lat: double.parse('${data['lat']}'),
      lng: double.parse('${data['lon']}'),
      license: '${data['licence'] ?? ''}',
      osmType: '${data['osm_type'] ?? ''}',
      placeId: '${data['place_id'] ?? ''}',
      category: '${data['category'] ?? ''}',
      address: '${data['display_name'] ?? ''}',
      placeRank: '${data['place_rank'] ?? ''}',
      importance: '${data['importance'] ?? ''}',
      addressType: '${data['address_type'] ?? data['addresstype'] ?? ''}',
      rawAddress: data['address'] == null
          ? FmAddress.fromJSON({
              '${data['addresstype'] ?? ''}': data['name'],
            })
          : FmAddress.fromJSON(data['address']),
      geoJson: data['geojson'] == null
          ? null
          : FMGeoJsonModel.fromJSON(data['geojson']),
      boundingBox: (data['boundingbox'] as List?)
              ?.map((e) => double.parse('$e'))
              .toList() ??
          [],
    );
  }
}

class FmAddress {
  final String? iso;
  final String? city;
  final String? state;
  final String? suburb;
  final String? county;
  final String? country;
  final String? postcode;
  final String? countryCode;
  final String? residential;
  final String? stateDistrict;

  const FmAddress({
    required this.iso,
    required this.city,
    required this.state,
    required this.suburb,
    required this.county,
    required this.country,
    required this.postcode,
    required this.countryCode,
    required this.residential,
    required this.stateDistrict,
  });

  factory FmAddress.fromJSON(Map<String, dynamic> data) {
    return FmAddress(
      city: data['city'] != null ? '${data['city']}' : null,
      state: data['state'] != null ? '${data['state']}' : null,
      suburb: data['suburb'] != null ? '${data['suburb']}' : null,
      county: data['county'] != null ? '${data['county']}' : null,
      country: data['country'] != null ? '${data['country']}' : null,
      postcode: data['postcode'] != null ? '${data['postcode']}' : null,
      iso: data['ISO3166-2-lvl4'] != null ? '${data['ISO3166-2-lvl4']}' : null,
      residential:
          data['residential'] != null ? '${data['residential']}' : null,
      countryCode:
          data['country_code'] != null ? '${data['country_code']}' : null,
      stateDistrict:
          data['state_district'] is String ? data['state_district'] : null,
    );
  }
}

class FmPolylineOptions {
  /// The width of the stroke
  final double strokeWidth;

  /// Determines whether the line should be solid, dotted, or dashed, and the
  /// exact characteristics of each
  ///
  /// Defaults to being a solid/unbroken line ([StrokePattern.solid]).
  final StrokePattern pattern;

  /// The color of the line stroke.
  final Color color;

  /// The width of the stroke with of the line border.
  /// Defaults to 0.0 (disabled).
  final double borderStrokeWidth;

  /// The [Color] of the [Polyline] border.
  final Color borderColor;

  /// The List of colors in case a gradient should get used.
  final List<Color>? gradientColors;

  /// The stops for the gradient colors.
  final List<double>? colorsStop;

  /// Styles to use for line endings.
  final StrokeCap strokeCap;

  /// Styles to use for line segment joins.
  final StrokeJoin strokeJoin;

  /// Set to true if the width of the stroke should have meters as unit.
  final bool useStrokeWidthInMeter;

  /// Options to style the polyline
  const FmPolylineOptions({
    this.colorsStop,
    this.gradientColors,
    this.strokeWidth = 1.0,
    this.borderStrokeWidth = 0.0,
    this.strokeCap = StrokeCap.round,
    this.strokeJoin = StrokeJoin.round,
    this.useStrokeWidthInMeter = false,
    this.color = const Color(0xFF00FF00),
    this.pattern = const StrokePattern.solid(),
    this.borderColor = const Color(0xFFFFFF00),
  });
}
