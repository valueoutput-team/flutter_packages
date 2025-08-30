import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:free_map/free_map.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  FmData? _address;
  LatLng? _currentPos;
  bool _loading = false;
  bool _isOverlayVisible = false;
  late final MapController _mapController;
  final _src = const LatLng(37.4165849896396, -122.08051867783071);
  final _dest = const LatLng(37.420921119071586, -122.08535335958004);

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Builder(builder: (context) {
        return GestureDetector(
          onTap: FocusScope.of(context).unfocus,
          child: Scaffold(
            appBar: AppBar(title: const Text('Free Map Demo')),
            body: SafeArea(
              bottom: false,
              child: Stack(children: [
                _map,
                if (_loading)
                  Container(
                    alignment: Alignment.center,
                    color: Colors.white.withAlpha(112),
                    child: CircularProgressIndicator(),
                  ),
                _searchField
              ]),
            ),
          ),
        );
      }),
    );
  }

  /// Free map widget
  Widget get _map {
    final ignoreTap = _isOverlayVisible || _loading;
    return GestureDetector(
      onTap: ignoreTap ? FocusScope.of(context).unfocus : null,
      child: IgnorePointer(
        ignoring: ignoreTap,
        child: FmMap(
          mapController: _mapController,
          mapOptions: MapOptions(
            minZoom: 5,
            maxZoom: 18,
            initialZoom: 15,
            initialCenter: _src,
            onTap: (pos, point) => _onMapTap(point),
          ),
          markers: [
            Marker(
              point: _currentPos ?? _src,
              child: const Icon(
                size: 40.0,
                color: Colors.red,
                Icons.location_on_rounded,
              ),
            ),
            if (_currentPos == null)
              Marker(
                point: _dest,
                child: const Icon(
                  size: 40.0,
                  color: Colors.blue,
                  Icons.location_on_rounded,
                ),
              ),
          ],
          polylineOptions: const FmPolylineOptions(
            strokeWidth: 3,
            color: Colors.blue,
          ),
        ),
      ),
    );
  }

  /// Auto-complete places search field
  Widget get _searchField {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: FmSearchField(
        selectedValue: _address,
        onSelected: _onAddressSelected,
        searchParams: const FmSearchParams(),
        resultViewOptions: FmResultViewOptions(
          onOverlayVisible: (v) => setState(() => _isOverlayVisible = v),
        ),
        textFieldBuilder: (focus, controller, onChanged) {
          return TextFormField(
            focusNode: focus,
            onChanged: onChanged,
            controller: controller,
            decoration: InputDecoration(
              filled: true,
              hintText: 'Search',
              fillColor: Colors.grey[300],
              suffixIcon: controller.text.trim().isEmpty || !focus.hasFocus
                  ? null
                  : IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.close),
                      onPressed: controller.clear,
                      visualDensity: VisualDensity.compact,
                    ),
            ),
          );
        },
      ),
    );
  }

  /// On address selected from auto-complete search field
  void _onAddressSelected(FmData? data) {
    if (data == null) return;
    _address = data;
    _currentPos = LatLng(data.lat, data.lng);
    _mapController.move(_currentPos!, 12);
  }

  /// REVERSE GEOCODING: Get address from geocode
  Future<void> _onMapTap(LatLng pos) async {
    setState(() => _loading = true);

    final data = await FmService().getAddress(
      lat: pos.latitude,
      lng: pos.longitude,
    );

    _address = data;
    _currentPos = pos;
    setState(() => _loading = false);
  }

  /// GEOCODING: Get geocode from an address
  Future<void> getGeocode(String address) async {
    final data = await FmService().getGeocode(address: address);
    if (kDebugMode) print('${data?.lat},${data?.lng}');
  }
}
