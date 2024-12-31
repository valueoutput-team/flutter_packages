import 'package:flutter/material.dart';
import 'package:google_maps_helper/src/app_utils.dart';
import 'package:google_maps_helper/gmh_models.dart';
import 'package:google_maps_helper/src/app_constants.dart';
import 'package:google_maps_helper/src/api_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GmhMap extends StatefulWidget {
  /// Google Map Options
  final GmhMapOptions mapOptions;

  /// Google Map's Polyline Options
  /// If you don't want to show polylines, send it as null
  final GmhPolylineOptions? polylineOptions;

  const GmhMap({super.key, this.polylineOptions, required this.mapOptions});

  @override
  State<GmhMap> createState() => _GmhMapState();
}

class _GmhMapState extends State<GmhMap> {
  String? _lastPolygonId;
  bool _addingPolylines = false;

  final _appUtils = AppUtils();
  final _apiService = ApiService();
  final Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _getPolylines());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) => _getPolylines());
  }

  @override
  void didUpdateWidget(covariant GmhMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) => _getPolylines());
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      key: widget.key,
      polylines: _polylines,
      style: widget.mapOptions.style,
      onTap: widget.mapOptions.onTap,
      mapType: widget.mapOptions.mapType,
      padding: widget.mapOptions.padding,
      markers: widget.mapOptions.markers,
      circles: widget.mapOptions.circles,
      polygons: widget.mapOptions.polygons,
      heatmaps: widget.mapOptions.heatmaps,
      cloudMapId: widget.mapOptions.cloudMapId,
      onLongPress: widget.mapOptions.onLongPress,
      onMapCreated: widget.mapOptions.onMapCreated,
      onCameraMove: widget.mapOptions.onCameraMove,
      onCameraIdle: widget.mapOptions.onCameraIdle,
      tileOverlays: widget.mapOptions.tileOverlays,
      compassEnabled: widget.mapOptions.compassEnabled,
      trafficEnabled: widget.mapOptions.trafficEnabled,
      liteModeEnabled: widget.mapOptions.liteModeEnabled,
      layoutDirection: widget.mapOptions.layoutDirection,
      clusterManagers: widget.mapOptions.clusterManagers,
      buildingsEnabled: widget.mapOptions.buildingsEnabled,
      mapToolbarEnabled: widget.mapOptions.mapToolbarEnabled,
      indoorViewEnabled: widget.mapOptions.indoorViewEnabled,
      gestureRecognizers: widget.mapOptions.gestureRecognizers,
      webGestureHandling: widget.mapOptions.webGestureHandling,
      cameraTargetBounds: widget.mapOptions.cameraTargetBounds,
      zoomControlsEnabled: widget.mapOptions.zoomControlsEnabled,
      zoomGesturesEnabled: widget.mapOptions.zoomGesturesEnabled,
      tiltGesturesEnabled: widget.mapOptions.tiltGesturesEnabled,
      onCameraMoveStarted: widget.mapOptions.onCameraMoveStarted,
      minMaxZoomPreference: widget.mapOptions.minMaxZoomPreference,
      myLocationEnabled: widget.mapOptions.myLocationButtonEnabled,
      initialCameraPosition: widget.mapOptions.initialCameraPosition,
      rotateGesturesEnabled: widget.mapOptions.rotateGesturesEnabled,
      scrollGesturesEnabled: widget.mapOptions.scrollGesturesEnabled,
      myLocationButtonEnabled: widget.mapOptions.myLocationButtonEnabled,
      fortyFiveDegreeImageryEnabled:
          widget.mapOptions.fortyFiveDegreeImageryEnabled,
    );
  }

  Future<void> _getPolylines() async {
    if (widget.polylineOptions == null || _addingPolylines) return;
    final markers = widget.mapOptions.markers.toList();
    if (markers.length < 2) return;

    final id = markers
        .map((e) => '${e.position.latitude},${e.position.longitude}')
        .join('|');
    if (id == _lastPolygonId) return;

    _addingPolylines = true;

    final query = widget.polylineOptions!.query(
      origin: markers.first.position,
      destination: markers.last.position,
      waypoints: markers.length == 2
          ? []
          : markers
              .sublist(1, markers.length - 1)
              .map((e) => e.position)
              .toList(),
    );

    String url = BaseURLs.directions;
    url += '?';
    url += query.entries.map((e) => '${e.key}=${e.value}').join('&');
    final res = await _apiService.request(url: url);
    final encodedPolyline = (res.data?[ApiKeys.routes] as List?)
        ?.firstOrNull?[ApiKeys.overviewPolyline]?[ApiKeys.points];

    if (encodedPolyline == null) {
      if (widget.polylineOptions?.onNoRoute != null) {
        widget.polylineOptions?.onNoRoute!();
      }
    } else {
      _polylines.add(
        Polyline(
          polylineId: PolylineId('polyline_1'),
          onTap: widget.polylineOptions!.onTap,
          width: widget.polylineOptions!.width,
          color: widget.polylineOptions!.color,
          zIndex: widget.polylineOptions!.zIndex,
          endCap: widget.polylineOptions!.endCap,
          visible: widget.polylineOptions!.visible,
          startCap: widget.polylineOptions!.startCap,
          geodesic: widget.polylineOptions!.geodesic,
          patterns: widget.polylineOptions!.patterns,
          jointType: widget.polylineOptions!.jointType,
          points: _appUtils.decodePolyline(encodedPolyline),
          consumeTapEvents: widget.polylineOptions!.consumeTapEvents,
        ),
      );
      _lastPolygonId = id;
      setState(() {});
    }

    _addingPolylines = false;
  }
}
