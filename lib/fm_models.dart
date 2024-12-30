import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
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
    this.overlayDecoration,
  });
}

class FmAddress {
  final String iso;
  final String state;
  final String suburb;
  final String county;
  final String country;
  final String postcode;
  final String countryCode;
  final String residential;
  final String stateDistrict;

  const FmAddress({
    required this.iso,
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
      state: '${data['state'] ?? ''}',
      suburb: '${data['suburb'] ?? ''}',
      county: '${data['county'] ?? ''}',
      country: '${data['country'] ?? ''}',
      postcode: '${data['postcode'] ?? ''}',
      iso: '${data['ISO3166-2-lvl4'] ?? ''}',
      residential: '${data['residential'] ?? ''}',
      countryCode: '${data['country_code'] ?? ''}',
      stateDistrict: '${data['state_district'] ?? ''}',
    );
  }
}

class FmData {
  /// The latitude of the address.
  final double lat;

  /// The latitude of the address.
  final double lng;

  /// The unique Place ID associated with the address.
  final String placeId;

  /// The full address as a string.
  final String address;

  /// raw address data
  final FmAddress? rawAddress;

  /// Data model representing address information
  const FmData({
    required this.lat,
    required this.lng,
    required this.placeId,
    required this.address,
    required this.rawAddress,
  });
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
