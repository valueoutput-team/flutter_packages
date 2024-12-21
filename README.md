A simplified flutter package solution that extends google_maps_flutter with essential functionalities, including autocomplete place search and polyline drawing.

## Features

- All Google map features in one package
- Auto-complete text field for Google places
- Draw polylines on Google map
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
      initialValue: _address,
      onSelected: (data) => _address = data,
      searchParams: GmhSearchParams(
        placesApiKey: '<GOOGLE_PLACES_API_KEY>',
      ),
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

GmhMap(
    mapOptions: GmhMapOptions(
        initialCameraPosition: _kSrc,
        onMapCreated: (controller) => _controller = controller,
        markers: {
            Marker(
                position: _kSrc.target,
                markerId: MarkerId('src'),
            ),
            Marker(
                position: _kDest.target,
                markerId: MarkerId('dest'),
            ),
        },
    ),
    polylineOptions: GmhPolylineOptions(
        geodesic: true,
        color: Colors.blue,
        apiKey: '<GOOGLE_DIRECTIONS_API_KEY>',
    ),
),
```

## Additional information

Think you've found a bug, or would like to see a new feature? We'd love to hear about it! Visit the [Issues](https://github.com/valueoutput-team/flutter_packages/issues) section of the git repository.
