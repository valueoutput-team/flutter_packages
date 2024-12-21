import 'package:flutter/material.dart';
import 'package:google_maps_helper/models/gmh_models.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_helper/ui/gmh_map.dart';
import 'package:google_maps_helper/ui/gmh_search_field.dart';

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
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: Scaffold(
        appBar: AppBar(title: Text('Google Maps Helper')),
        body: SafeArea(
          child: Stack(
            children: [
              _map,
              _searchField,
            ],
          ),
        ),
      ),
    );
  }

  /// Google map
  Widget get _map {
    return GmhMap(
      mapOptions: GmhMapOptions(
        mapType: MapType.normal,
        initialCameraPosition: _kSrc,
        onTap: (pos) => print('Tapped: $pos'),
        minMaxZoomPreference: MinMaxZoomPreference(15, 18),
        onMapCreated: (controller) => _controller = controller,
        markers: {
          Marker(
            draggable: true,
            position: _kSrc.target,
            markerId: MarkerId('src'),
            infoWindow: InfoWindow(title: 'Source'),
            onTap: () => _controller?.showMarkerInfoWindow(MarkerId('src')),
          ),
          Marker(
            draggable: true,
            position: _kDest.target,
            markerId: MarkerId('dest'),
            infoWindow: InfoWindow(title: 'Destination'),
            onTap: () => _controller?.showMarkerInfoWindow(MarkerId('dest')),
          ),
        },
      ),
      polylineOptions: GmhPolylineOptions(
        geodesic: true,
        color: Colors.blue,
        apiKey: '<GOOGLE_DIRECTIONS_API_KEY>',
      ),
    );
  }

  /// Auto-complete places search field
  Widget get _searchField {
    return GmhSearchField(
      initialValue: _address,
      onSelected: (data) => _address = data,
      searchParams: GmhSearchParams(apiKey: '<GOOGLE_PLACES_API_KEY>'),
    );
  }
}
