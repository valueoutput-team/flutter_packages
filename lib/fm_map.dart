import 'package:flutter/material.dart';
import 'package:free_map/fm_models.dart';
import 'package:free_map/fm_service.dart';
import 'package:flutter_map/flutter_map.dart';

class FmMap extends StatefulWidget {
  /// Alignment of the attribution
  final Alignment attributionAlignment;

  /// Text style of attribution
  final TextStyle? attributionStyle;

  /// Markers to be placed on the map.
  /// If you want to show polylines, ensure markers are in sequence from origin to destination.
  final List<Marker> markers;

  /// Configure this map's permanent rules and initial state
  final MapOptions mapOptions;

  /// Map controller
  final MapController? mapController;

  /// Polyline Options. If you don't want to show polylines, send it as null
  final FmPolylineOptions? polylineOptions;

  /// Creates an interactive geographical map
  const FmMap({
    super.key,
    this.mapController,
    this.polylineOptions,
    this.attributionStyle,
    this.markers = const [],
    this.mapOptions = const MapOptions(),
    this.attributionAlignment = Alignment.bottomLeft,
  });

  @override
  State<FmMap> createState() => _FmMapState();
}

class _FmMapState extends State<FmMap> {
  String? _lastPolygonId;
  bool _addingPolylines = false;

  final _mapService = FmService();
  final List<Polyline> _polylines = [];

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
  void didUpdateWidget(covariant FmMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) => _getPolylines());
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FlutterMap(
          options: widget.mapOptions,
          mapController: widget.mapController,
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            ),
            if (_polylines.isNotEmpty) PolylineLayer(polylines: _polylines),
            if (widget.markers.isNotEmpty) MarkerLayer(markers: widget.markers),
          ],
        ),
        Align(
          alignment: widget.attributionAlignment,
          child: Text(
            '© OpenStreetMap',
            style: widget.attributionStyle ??
                Theme.of(context).textTheme.labelSmall,
          ),
        ),
      ],
    );
  }

  /// Get polylines
  Future<void> _getPolylines() async {
    if (widget.polylineOptions == null || widget.markers.length < 2) return;
    if (_addingPolylines) return;

    final id = widget.markers
        .map((e) => '${e.point.latitude},${e.point.longitude}')
        .join('_');
    if (id == _lastPolygonId) return;

    _addingPolylines = true;

    final polylinePoints = await _mapService.getPolyline(
      widget.markers.map((e) => e.point).toList(),
    );

    if (polylinePoints.isNotEmpty) {
      _polylines.add(Polyline(
        points: polylinePoints,
        color: widget.polylineOptions!.color,
        pattern: widget.polylineOptions!.pattern,
        strokeCap: widget.polylineOptions!.strokeCap,
        strokeJoin: widget.polylineOptions!.strokeJoin,
        colorsStop: widget.polylineOptions!.colorsStop,
        strokeWidth: widget.polylineOptions!.strokeWidth,
        borderColor: widget.polylineOptions!.borderColor,
        gradientColors: widget.polylineOptions!.gradientColors,
        borderStrokeWidth: widget.polylineOptions!.borderStrokeWidth,
        useStrokeWidthInMeter: widget.polylineOptions!.useStrokeWidthInMeter,
      ));
      if (mounted) setState(() {});
    }

    _lastPolygonId = id;
    _addingPolylines = false;
  }
}
