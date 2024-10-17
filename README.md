A Flutter package powered by OpenStreetMap for free address search, location picking, current location detection, and reverse geocoding (finding addresses from coordinates).

![free_map screenshot](https://github.com/Hitesh822/flutter_packages/blob/main/assets/images/free_map_1.png?raw=true)

## Features

- **Free Address Search:** Perform address searches without any usage fees.
- **Search-Only Field:** Use a standalone search field for address lookup, independent of the map.
- **Location Picker:** Select locations directly on an interactive map.
- **Full Map with Search Widget:** Combined search field and map in one seamless widget.
- **Current Location Detection:** Get the user’s current GPS location.
- **Reverse Geocoding:** Retrieve addresses from geographic coordinates.
- **Powered by OpenStreetMap:** A free, open-source alternative to Google Places API.
- **Highly Customizable:** Adjust the widgets appearance to match your app’s design.

## Getting started

Checkout [geolocator](https://pub.dev/packages/geolocator#usage) platform setup instructions.

## Usage

### Search-Only Field

```
FMSearchField(
      initialValue: _selectedValue,
      textController: _textController,
      margin: const EdgeInsets.all(20),
      textFieldBuilder: _searchTextFieldBuilder,
      onSelected: (v) => setState(() => _selectedValue = v),
)
```

### Full Map with Search Widget

```
FMWidget(
    initialValue: _selectedValue,
    searchTextFieldBuilder: _searchTextFieldBuilder,
    onSelected: (v) {
        _selectedValue = v;
        Navigator.pop(context);
    },
),
```

### Get Current Location

```
 final pos = await FMService().getCurrentPosition();
```

### Get Address

```
final data = await FMService().getAddress(
    lat: pos.latitude,
    lng: pos.longitude,
);
```

## Additional information

Think you've found a bug, or would like to see a new feature? We'd love to hear about it! Visit the [Issues](https://github.com/Hitesh822/flutter_packages/issues) section of the git repository. DO NOT FORGOT TO MENTION THE PACKAGE NAME "free_map" IN THE TITLE.
