// ignore_for_file: unused_field
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_helper/google_maps_helper.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  GmhAddressData? _address;
  GoogleMapController? _controller;

  final _kSrc = CameraPosition(
    zoom: 18,
    target: LatLng(37.4165849896396, -122.08051867783071),
  );

  final _kDest = CameraPosition(
    zoom: 15,
    target: LatLng(37.420921119071586, -122.08535335958004),
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Google Maps Helper')),
        body: SafeArea(child: Stack(children: [_map, _searchField])),
      ),
    );
  }

  /// Google map widget
  Widget get _map {
    return GmhMap(
      mapOptions: GmhMapOptions(
        mapType: MapType.normal,
        initialCameraPosition: _kSrc,
        onTap: (pos) => _getAddress(pos),
        minMaxZoomPreference: MinMaxZoomPreference(15, 18),
        onMapCreated: (controller) => _controller = controller,
        markers: {
          Marker(markerId: MarkerId('src'), position: _kSrc.target),
          Marker(markerId: MarkerId('dest'), position: _kDest.target),
        },
      ),
      polylineOptions: GmhPolylineOptions(
        geodesic: true,
        color: Colors.blue,
        optimizeWaypoints: true,
        apiKey: '<GOOGLE_DIRECTIONS_API_KEY>',
      ),
    );
  }

  /// Auto-complete places search field
  Widget get _searchField {
    return GmhSearchField(
      selectedValue: _address,
      onSelected: (data) => _address = data,
      searchParams: GmhSearchParams(apiKey: '<GOOGLE_PLACES_API_KEY>'),
    );
  }

  /// REVERSE GEOCODING: Get address from geocode
  Future<void> _getAddress(LatLng pos) async {
    final data = await GmhService().getAddress(
      lat: pos.latitude,
      lng: pos.longitude,
      apiKey: '<GOOGLE_GEOCODING_API_KEY>',
    );
    if (kDebugMode) print(data?.address);
    if (data != null) _getGeocode(data.address);
  }

  /// GEOCODING: Get geocode from an address
  Future<void> _getGeocode(String address) async {
    final data = await GmhService().getGeocode(
      address: address,
      apiKey: '<GOOGLE_GEOCODING_API_KEY>',
    );
    if (kDebugMode) print('${data?.lat},${data?.lng}');
  }
}
