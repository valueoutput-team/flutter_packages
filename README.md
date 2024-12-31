A flutter package that extends google_maps_flutter with essential functionalities, including autocomplete textfield for places search, polylines drawing, geocoding, and reverse geocoding.

## Features

- All Google map features in one package
- Auto-complete text field for Google places
- Draw polylines on Google map
- [GEOCODING] Get geocode from an address
- [REVERSE GEOCODING] Get address from geocode
- No need for separate google_maps_flutter package
- Easy to use & highly customizable

![google_maps_helper screenshot](https://github.com/valueoutput-team/flutter_packages/blob/main/assets/images/google_maps_helper_1.png?raw=true)

## Getting started

Checkout [google_maps_flutter](https://pub.dev/packages/google_maps_flutter) setup instructions.

## Usage

### Auto-complete text field for Google places

```dart
  Widget get _searchField {
    return GmhSearchField(
      selectedValue: _address,
      onSelected: (data) => _address = data,
      searchParams: GmhSearchParams(apiKey: '<GOOGLE_PLACES_API_KEY>'),
    );
  }
```

### Google map widget

```dart
GoogleMapController? _controller;
final _kSrc = CameraPosition(
    target: LatLng(37.4165849896396, -122.08051867783071),
);
final _kDest = CameraPosition(
    target: LatLng(37.420921119071586, -122.08535335958004),
);

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
```

### Geocoding

```dart
Future<void> _getGeocode(String address) async {
  final data = await GmhService().getGeocode(
    address: address,
    apiKey: '<GOOGLE_GEOCODING_API_KEY>',
  );
  print('${data?.lat},${data?.lng}');
}
```

### Reverse Geocoding

```dart
Future<void> _getAddress(LatLng pos) async {
  final data = await GmhService().getAddress(
    lat: pos.latitude,
    lng: pos.longitude,
    apiKey: '<GOOGLE_GEOCODING_API_KEY>',
  );
  print(data?.address);
}
```

## Additional information

Think you've found a bug, or would like to see a new feature? We'd love to hear about it! Visit the [Issues](https://github.com/valueoutput-team/flutter_packages/issues) section of the git repository.
