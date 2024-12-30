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
              child: Stack(children: [_map, _searchField]),
            ),
          ),
        );
      }),
    );
  }

  /// Free map widget
  Widget get _map {
    return FmMap(
      mapController: _mapController,
      mapOptions: MapOptions(
        minZoom: 15,
        maxZoom: 18,
        initialZoom: 15,
        initialCenter: _src,
        onTap: (pos, point) => _getAddress(point),
      ),
      markers: [
        Marker(
          point: _src,
          child: const Icon(
            size: 40.0,
            color: Colors.red,
            Icons.location_on_rounded,
          ),
        ),
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
    );
  }

  /// Auto-complete places search field
  Widget get _searchField {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: FmSearchField(
        selectedValue: _address,
        searchParams: const FmSearchParams(),
        onSelected: (data) => _address = data,
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

  /// REVERSE GEOCODING: Get address from geocode
  Future<void> _getAddress(LatLng pos) async {
    final data = await FmService().getAddress(
      lat: pos.latitude,
      lng: pos.longitude,
    );
    if (kDebugMode) print(data?.address);
    if (data != null) _getGeocode(data.address);
  }

  /// GEOCODING: Get geocode from an address
  Future<void> _getGeocode(String address) async {
    final data = await FmService().getGeocode(address: address);
    if (kDebugMode) print('${data?.lat},${data?.lng}');
  }
}
