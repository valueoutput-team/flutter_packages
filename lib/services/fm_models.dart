import 'package:flutter/material.dart';

class FMSearchOptions {
  /// maximum number of search results
  final int limit;

  /// maximum retries on a search failure
  final int maxRetries;

  /// languages allowed in the search results
  final List<String> langs;

  /// search in particular countries only
  final List<String>? countries;

  const FMSearchOptions({
    this.countries,
    this.limit = 10,
    this.maxRetries = 3,
    this.langs = const ['en'],
  })  : assert(limit > 0, 'limit must be greater than 0'),
        assert(maxRetries <= 5, 'Keep maxRetries less than or equal to 5');

  factory FMSearchOptions.initial() => const FMSearchOptions();

  factory FMSearchOptions.reducedRetry(FMSearchOptions options) {
    return FMSearchOptions(
      limit: options.limit,
      langs: options.langs,
      countries: options.countries,
      maxRetries: options.maxRetries - 1,
    );
  }
}

class FMSearchResultListOptions {
  final double maxHeight;
  final Widget? emptyView;
  final Widget? noTextView;
  final Widget? loadingView;
  final EdgeInsets? padding;
  final BoxDecoration? overlayDecoration;
  final Widget Function(BuildContext, int)? separatorBuilder;
  final Widget Function(BuildContext, int, FMData)? itemBuilder;

  const FMSearchResultListOptions({
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

class FMSelectButtonOptions {
  final Widget? child;
  final ButtonStyle? style;
  final EdgeInsets padding;
  final Alignment alignment;
  final ButtonStyle? disabledStyle;

  const FMSelectButtonOptions({
    this.child,
    this.style,
    this.disabledStyle,
    this.padding = const EdgeInsets.all(20),
    this.alignment = Alignment.bottomCenter,
  });

  factory FMSelectButtonOptions.initial() => const FMSelectButtonOptions();
}

class FMAddress {
  final String iso;
  final String state;
  final String suburb;
  final String county;
  final String country;
  final String postcode;
  final String countryCode;
  final String residential;
  final String stateDistrict;

  const FMAddress({
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

  factory FMAddress.fromJSON(Map<String, dynamic> data) {
    return FMAddress(
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

class FMData {
  /// latitude
  final double lat;

  /// longitude
  final double lng;

  /// full address text
  final String address;

  /// raw address data
  final FMAddress? rawAddress;

  const FMData({
    required this.lat,
    required this.lng,
    required this.address,
    required this.rawAddress,
  });
}
