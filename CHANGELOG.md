## 2.3.0

- Optimized search
- Made FmAddress paramaters nullable
- FmData now includes the full response

## 2.2.0

- Implemented wait-time enforcement to comply with Nominatim's rate limit
- Added option in FmService to use self-hosted or third-party Nominatim servers
- Added caching mechanism

## 2.1.0

- Added hintText parameter in FmSearchField
- Removed internal handling of the selected value in FmSearchField. Pass selectedValue to FmSearchField and update the state explicitly.

## 2.0.4

- Added web support
- Upgraded dependency package versions
- Hid the clear button when the search field lost focus

## 2.0.3

- Improved logging system

## 2.0.2

- Updated dart version ^3.4.0
- Added onOverlayVisible param to listen for result overlay visibility
- Search field bug fixes

## 2.0.1

- Minor fixes

## 2.0.0

- Draw polylines on the map
- Made search field & map independent of each other for higher customization
- Removed geolocator dependency

## 1.0.6

- Search within a specific radius

## 1.0.5

- Fixed search stream controller on close issue

## 1.0.4

- Fixed FMWidget onSelect null exception

## 1.0.3

- Updated license

## 1.0.2

- Fixed FMWidget loader issue when location service is disabled

## 1.0.1

- Fixed marker position for initialValue in FMWidget

## 1.0.0

- Free address search, location picking, current location detection, and reverse geocoding
