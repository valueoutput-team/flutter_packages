A flutter package powered by OpenStreetMap for free map, autocomplete places textfield, polylines drawing, geocoding, and reverse geocoding.

![free_map screenshot](https://github.com/valueoutput-team/flutter_packages/blob/main/assets/images/free_map_1.png?raw=true)

## Features

- **Address Search:** Perform address searches with autocomplete textfield.
- **Map Features:** Add markers, draw polylines, select location on tap, and fine control map using controller.
- **Geocoding:** Get geographic coordinates from an address.
- **Reverse Geocoding:** Retrieve addresses from geographic coordinates.
- **Powered by OpenStreetMap:** A free, open-source alternative to Google Maps.
- **Highly Customizable:** Adjust the widgets appearance to match your app’s design.

## Getting started

### Android

1. Add Internet permission in your `AndroidManifest.xml` file.

```xml
<uses-permission android:name="android.permission.INTERNET" />
```

## Usage

### Auto-complete text field

```dart
FmSearchField(
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
)
```

### Map Widget

```dart
FmMap(
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
),
```

### Geocoding

```dart
final data = await FmService().getGeocode(address: address);
```

### Reverse Geocoding

```dart
final data = await FmService().getAddress(
    lat: pos.latitude,
    lng: pos.longitude,
);
```

## Additional information

Think you've found a bug, or would like to see a new feature? We'd love to hear about it! Visit the [Issues](https://github.com/valueoutput-team/flutter_packages/issues) section of the git repository.
