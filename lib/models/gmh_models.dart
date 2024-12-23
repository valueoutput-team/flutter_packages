import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_helper/utils/app_constants.dart';

/// Travel mode for the directions.
enum TravelMode { driving, bicycling, transit, walking, truck }

/// Preferred modes of transit.
enum TransitMode { bus, rail, subway, train, tram }

/// Features to avoid on the route.
enum AvoidableFeature { tolls, highways, ferries, indoor }

class GmhSearchParams {
  /// The Google Places API key
  final String apiKey;

  /// The radius (in meters) within which to return place results.
  /// Must be greater than 0 and less than or equal to 50,000.
  final int? radius;

  /// The language code for the results (e.g., 'en' for English).
  final String? lang;

  /// Whether to enforce strict bounds when `latLng` and `radius` are provided.
  final bool strictBounds;

  /// The country code to restrict results (ISO 3166-1 Alpha-2 format).
  final String? countryCode;

  /// The latitude and longitude coordinates to search around.
  final LatLng? loc;

  /// Parameters for Google Map Helper search functionality.
  const GmhSearchParams({
    this.loc,
    this.lang,
    this.radius,
    this.countryCode,
    required this.apiKey,
    this.strictBounds = false,
  })  : assert(radius == null || radius > 0, 'radius must be greater than 0'),
        assert(
          radius == null || radius <= 50000,
          'radius cannot be greater than 50000',
        );

  /// Converts the search parameters into a map
  Map<String, dynamic> query() {
    return {
      ApiKeys.key: apiKey,
      if (lang != null) ApiKeys.language: lang,
      if (radius != null) ApiKeys.radius: radius,
      if (loc != null) ApiKeys.location: '${loc!.latitude},${loc!.longitude}',
      if (loc != null && radius != null) ApiKeys.strictbounds: strictBounds,
      if (countryCode != null)
        ApiKeys.components: '${ApiKeys.country}:$countryCode',
    };
  }
}

class GmhAddressData {
  /// The latitude of the address.
  final double lat;

  /// The longitude of the address.
  final double lng;

  /// The unique Place ID associated with the address.
  final String placeId;

  /// The full address as a string.
  final String address;

  /// Data model representing address information returned by Google Maps.
  const GmhAddressData({
    required this.lat,
    required this.lng,
    required this.placeId,
    required this.address,
  });
}

class GmhResultViewOptions {
  /// The maximum height of the result view overlay.
  final double maxHeight;

  /// The widget to display when no results are found.
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
  final Widget Function(BuildContext, int, GmhAddressData)? itemBuilder;

  /// Options for customizing the result view in Google Map Helper.
  const GmhResultViewOptions({
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

class GmhMapOptions {
  /// The initial position of the map's camera.
  final CameraPosition initialCameraPosition;

  /// Callback method for when the map is ready to be used.
  ///
  /// Used to receive a [GoogleMapController] for this [GoogleMap].
  final MapCreatedCallback? onMapCreated;

  /// The style for the map.
  ///
  /// Set to null to clear any previous custom styling.
  ///
  /// If problems were detected with the [mapStyle], including un-parsable
  /// styling JSON, unrecognized feature type, unrecognized element type, or
  /// invalid styler keys, the style is left unchanged, and the error can be
  /// retrieved with [GoogleMapController.getStyleError].
  ///
  /// The style string can be generated using the
  /// [map style tool](https://mapstyle.withgoogle.com/).
  final String? style;

  /// True if the map should show a compass when rotated.
  final bool compassEnabled;

  /// True if the map should show a toolbar when you interact with the map. Android only.
  final bool mapToolbarEnabled;

  /// Geographical bounding box for the camera target.
  final CameraTargetBounds cameraTargetBounds;

  /// Type of map tiles to be rendered.
  final MapType mapType;

  /// The layout direction to use for the embedded view.
  ///
  /// If this is null, the ambient [Directionality] is used instead. If there is
  /// no ambient [Directionality], [TextDirection.ltr] is used.
  final TextDirection? layoutDirection;

  /// Preferred bounds for the camera zoom level.
  ///
  /// Actual bounds depend on map data and device.
  final MinMaxZoomPreference minMaxZoomPreference;

  /// True if the map view should respond to rotate gestures.
  final bool rotateGesturesEnabled;

  /// True if the map view should respond to scroll gestures.
  final bool scrollGesturesEnabled;

  /// True if the map view should show zoom controls. This includes two buttons
  /// to zoom in and zoom out. The default value is to show zoom controls.
  ///
  /// This is only supported on Android. And this field is silently ignored on iOS.
  final bool zoomControlsEnabled;

  /// True if the map view should respond to zoom gestures.
  final bool zoomGesturesEnabled;

  /// True if the map view should be in lite mode. Android only.
  ///
  /// See https://developers.google.com/maps/documentation/android-sdk/lite#overview_of_lite_mode for more details.
  final bool liteModeEnabled;

  /// True if the map view should respond to tilt gestures.
  final bool tiltGesturesEnabled;

  /// True if 45 degree imagery should be enabled. Web only.
  final bool fortyFiveDegreeImageryEnabled;

  /// Padding to be set on map. See https://developers.google.com/maps/documentation/android-sdk/map#map_padding for more details.
  final EdgeInsets padding;

  /// Markers to be placed on the map.
  /// If you want to show polylines, ensure markers are in sequence from origin to destination.
  final Set<Marker> markers;

  /// Polygons to be placed on the map.
  final Set<Polygon> polygons;

  /// Circles to be placed on the map.
  final Set<Circle> circles;

  /// Heatmaps to show on the map.
  final Set<Heatmap> heatmaps;

  /// Tile overlays to be placed on the map.
  final Set<TileOverlay> tileOverlays;

  /// Cluster Managers to be initialized for the map.
  final Set<ClusterManager> clusterManagers;

  /// Called when the camera starts moving.
  ///
  /// This can be initiated by the following:
  /// 1. Non-gesture animation initiated in response to user actions.
  ///    For example: zoom buttons, my location button, or marker clicks.
  /// 2. Programmatically initiated animation.
  /// 3. Camera motion initiated in response to user gestures on the map.
  ///    For example: pan, tilt, pinch to zoom, or rotate.
  final VoidCallback? onCameraMoveStarted;

  /// Called repeatedly as the camera continues to move after an
  /// onCameraMoveStarted call.
  ///
  /// This may be called as often as once every frame and should
  /// not perform expensive operations.
  final CameraPositionCallback? onCameraMove;

  /// Called when camera movement has ended, there are no pending
  /// animations and the user has stopped interacting with the map.
  final VoidCallback? onCameraIdle;

  /// Called every time a [GoogleMap] is tapped.
  final ArgumentCallback<LatLng>? onTap;

  /// Called every time a [GoogleMap] is long pressed.
  final ArgumentCallback<LatLng>? onLongPress;

  /// True if a "My Location" layer should be shown on the map.
  ///
  /// This layer includes a location indicator at the current device location,
  /// as well as a My Location button.
  /// * The indicator is a small blue dot if the device is stationary, or a
  /// chevron if the device is moving.
  /// * The My Location button animates to focus on the user's current location
  /// if the user's location is currently known.
  ///
  /// Enabling this feature requires adding location permissions to both native
  /// platforms of your app.
  /// * On Android add either
  /// `<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />`
  /// or `<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />`
  /// to your `AndroidManifest.xml` file. `ACCESS_COARSE_LOCATION` returns a
  /// location with an accuracy approximately equivalent to a city block, while
  /// `ACCESS_FINE_LOCATION` returns as precise a location as possible, although
  /// it consumes more battery power. You will also need to request these
  /// permissions during run-time. If they are not granted, the My Location
  /// feature will fail silently.
  /// * On iOS add a `NSLocationWhenInUseUsageDescription` key to your
  /// `Info.plist` file. This will automatically prompt the user for permissions
  /// when the map tries to turn on the My Location layer.
  final bool myLocationEnabled;

  /// Enables or disables the my-location button.
  ///
  /// The my-location button causes the camera to move such that the user's
  /// location is in the center of the map. If the button is enabled, it is
  /// only shown when the my-location layer is enabled.
  ///
  /// By default, the my-location button is enabled (and hence shown when the
  /// my-location layer is enabled).
  ///
  /// See also:
  ///   * [myLocationEnabled] parameter.
  final bool myLocationButtonEnabled;

  /// Enables or disables the indoor view from the map
  final bool indoorViewEnabled;

  /// Enables or disables the traffic layer of the map
  final bool trafficEnabled;

  /// Enables or disables showing 3D buildings where available
  final bool buildingsEnabled;

  /// Which gestures should be consumed by the map.
  ///
  /// It is possible for other gesture recognizers to be competing with the map on pointer
  /// events, e.g if the map is inside a [ListView] the [ListView] will want to handle
  /// vertical drags. The map will claim gestures that are recognized by any of the
  /// recognizers on this list.
  ///
  /// When this set is empty, the map will only handle pointer events for gestures that
  /// were not claimed by any other gesture recognizer.
  final Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers;

  /// This setting controls how the API handles gestures on the map. Web only.
  ///
  /// See [WebGestureHandling] for more details.
  final WebGestureHandling? webGestureHandling;

  /// Identifier that's associated with a specific cloud-based map style.
  ///
  /// See https://developers.google.com/maps/documentation/get-map-id
  /// for more details.
  final String? cloudMapId;

  /// Google map's options
  const GmhMapOptions({
    required this.initialCameraPosition,
    this.onMapCreated,
    this.style,
    this.gestureRecognizers = const <Factory<OneSequenceGestureRecognizer>>{},
    this.webGestureHandling,
    this.compassEnabled = true,
    this.mapToolbarEnabled = true,
    this.cameraTargetBounds = CameraTargetBounds.unbounded,
    this.mapType = MapType.normal,
    this.minMaxZoomPreference = MinMaxZoomPreference.unbounded,
    this.rotateGesturesEnabled = true,
    this.scrollGesturesEnabled = true,
    this.zoomControlsEnabled = true,
    this.zoomGesturesEnabled = true,
    this.liteModeEnabled = false,
    this.tiltGesturesEnabled = true,
    this.fortyFiveDegreeImageryEnabled = false,
    this.myLocationEnabled = false,
    this.myLocationButtonEnabled = true,
    this.layoutDirection,
    this.padding = EdgeInsets.zero,
    this.indoorViewEnabled = false,
    this.trafficEnabled = false,
    this.buildingsEnabled = true,
    this.markers = const <Marker>{},
    this.polygons = const <Polygon>{},
    this.circles = const <Circle>{},
    this.clusterManagers = const <ClusterManager>{},
    this.heatmaps = const <Heatmap>{},
    this.onCameraMoveStarted,
    this.tileOverlays = const <TileOverlay>{},
    this.onCameraMove,
    this.onCameraIdle,
    this.onTap,
    this.onLongPress,
    this.cloudMapId,
  });
}

class GmhPolylineOptions {
  /// Google directions API key
  final String apiKey;

  /// True if the [Polyline] consumes tap events.
  ///
  /// If this is false, [onTap] callback will not be triggered.
  final bool consumeTapEvents;

  /// Line segment color in ARGB format, the same format used by Color. The default value is black (0xff000000).
  final Color color;

  /// Indicates whether the segments of the polyline should be drawn as geodesics, as opposed to straight lines
  /// on the Mercator projection.
  ///
  /// A geodesic is the shortest path between two points on the Earth's surface.
  /// The geodesic curve is constructed assuming the Earth is a sphere
  final bool geodesic;

  /// Joint type of the polyline line segments.
  ///
  /// The joint type defines the shape to be used when joining adjacent line segments at all vertices of the
  /// polyline except the start and end vertices. See [JointType] for supported joint types. The default value is
  /// mitered.
  ///
  /// Supported on Android only.
  final JointType jointType;

  /// The stroke pattern for the polyline.
  ///
  /// Solid or a sequence of PatternItem objects to be repeated along the line.
  /// Available PatternItem types: Gap (defined by gap length in pixels), Dash (defined by line width and dash
  /// length in pixels) and Dot (circular, centered on the line, diameter defined by line width in pixels).
  final List<PatternItem> patterns;

  /// The vertices of the polyline to be drawn.
  ///
  /// Line segments are drawn between consecutive points. A polyline is not closed by
  /// default; to form a closed polyline, the start and end points must be the same.
  final List<LatLng> points;

  /// The cap at the start vertex of the polyline.
  ///
  /// The default start cap is ButtCap.
  ///
  /// Supported on Android only.
  final Cap startCap;

  /// The cap at the end vertex of the polyline.
  ///
  /// The default end cap is ButtCap.
  ///
  /// Supported on Android only.
  final Cap endCap;

  /// True if the polyline is visible.
  final bool visible;

  /// Width of the polyline, used to define the width of the line segment to be drawn.
  ///
  /// The width is constant and independent of the camera's zoom level.
  /// The default value is 10.
  final int width;

  /// The z-index of the polyline, used to determine relative drawing order of
  /// map overlays.
  ///
  /// Overlays are drawn in order of z-index, so that lower values means drawn
  /// earlier, and thus appearing to be closer to the surface of the Earth.
  final int zIndex;

  /// Callbacks to receive tap events for polyline placed on this map.
  final VoidCallback? onTap;

  /// Travel mode for the directions.
  final TravelMode mode;

  /// Features to avoid on the route.
  final List<AvoidableFeature>? avoid;

  /// Specify preferred modes of transit.
  final List<TransitMode>? transitModes;

  /// callback function when no route is found between the markers
  final VoidCallback? onNoRoute;

  /// Whether to optimize the waypoints provided in the request.
  final bool optimizeWaypoints;

  /// Google map's polyline options
  const GmhPolylineOptions({
    this.onTap,
    this.avoid,
    this.onNoRoute,
    this.width = 10,
    this.zIndex = 0,
    this.transitModes,
    required this.apiKey,
    this.visible = true,
    this.geodesic = false,
    this.endCap = Cap.buttCap,
    this.color = Colors.black,
    this.startCap = Cap.buttCap,
    this.mode = TravelMode.driving,
    this.consumeTapEvents = false,
    this.optimizeWaypoints = false,
    this.points = const <LatLng>[],
    this.jointType = JointType.mitered,
    this.patterns = const <PatternItem>[],
  });

  Map<String, dynamic> query({
    required LatLng origin,
    required LatLng destination,
    required List<LatLng> waypoints,
  }) {
    return {
      ApiKeys.key: apiKey,
      ApiKeys.mode: mode.str,
      ApiKeys.origin: '${origin.latitude},${origin.longitude}',
      ApiKeys.destination: '${destination.latitude},${destination.longitude}',
      if (avoid != null && avoid!.isNotEmpty)
        ApiKeys.avoid: avoid!.map((e) => e.str).join('|'),
      if (transitModes != null && transitModes!.isNotEmpty)
        ApiKeys.transitMode: transitModes!.map((e) => e.str).join('|'),
      if (waypoints.isNotEmpty) ApiKeys.optimizeWaypoints: optimizeWaypoints,
      if (waypoints.isNotEmpty)
        ApiKeys.waypoints:
            waypoints.map((e) => 'via:${e.latitude},${e.longitude}').join('|'),
    };
  }
}
