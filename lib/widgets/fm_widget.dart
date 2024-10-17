import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:free_map/services/fm_models.dart';
import 'package:free_map/services/fm_service.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:free_map/widgets/fm_search_field.dart';

/// Map with search field
class FMWidget extends StatefulWidget {
  /// alignment of the attribution
  final Alignment attributionAlignment;

  /// text style of attribution
  final TextStyle? attributionStyle;

  /// Floating action button for getting current location
  /// <br> assign zero size SizedBox() to hide
  final Widget? currentLocationFab;

  /// initial selected coordinates (latitude, longitude)
  final FMData? initialValue;

  /// map loading view
  final Widget? loadingView;

  /// marker icon
  final Widget? marker;

  /// Error handler
  /// <br> Can be used to show custom dialog, snackbar, etc. when location is disabled, or permission denied, and other search error occured
  /// <br> Example
  /// ```dart
  /// FMWidget(
  ///   onError: (e, st) {
  ///     if (e.toString().contains('LOCATION_DISABLED')) {
  ///       // show snackbar asking user to enable device location
  ///     } else if (e.toString().contains('PERMISSION_DENIED')) {
  ///       // show dialog asking user to grant location permission
  ///     }
  ///   },
  /// )
  /// ```
  final Function(Object, StackTrace)? onError;

  /// callback function when a search result is selected
  final Function(FMData) onSelected;

  /// margin around search field
  final EdgeInsets searchFieldMargin;

  /// set options for searching
  final FMSearchOptions? searchOptions;

  /// set options for search results list
  final FMSearchResultListOptions? searchResultListOptions;

  /// Create your fully customized text field.
  /// <br>Your text field must use focusNode, controller, and onChanged arguments from this method only.
  /// <br> Example
  /// ```dart
  /// FMSearchField(
  ///   textFieldBuilder: (focusNode, controller, onChanged) => TextFormField(
  ///     focusNode: focusNode,
  ///     controller: controller,
  ///     onChanged: onChanged,
  ///     decoration: const InputDecoration(hintText: 'Search Address'),
  ///   ),
  /// )
  /// ```
  final TextFormField Function(
    FocusNode focusNode,
    TextEditingController controller,
    void Function(String)? onChanged,
  )? searchTextFieldBuilder;

  /// set options for final select button
  final FMSelectButtonOptions? selectButtonOptions;

  const FMWidget({
    super.key,
    this.marker,
    this.onError,
    this.loadingView,
    this.initialValue,
    this.searchOptions,
    this.attributionStyle,
    this.currentLocationFab,
    required this.onSelected,
    this.selectButtonOptions,
    this.searchTextFieldBuilder,
    this.searchResultListOptions,
    this.searchFieldMargin = const EdgeInsets.all(20),
    this.attributionAlignment = Alignment.bottomLeft,
  });

  @override
  State<FMWidget> createState() => _FMWidgetState();
}

class _FMWidgetState extends State<FMWidget> {
  bool _loading = false;
  FMData? _selectedValue;
  bool _overlayOpen = false;
  var _currentPos = const LatLng(28.6139, 77.2088);

  late final MapController _mapController;
  late final TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _selectedValue = widget.initialValue;
    _textController = TextEditingController();
    if (widget.initialValue != null) {
      _currentPos = LatLng(widget.initialValue!.lat, widget.initialValue!.lng);
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: widget.currentLocationFab ?? _fab,
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              maxZoom: 18,
              onTap: _onTap,
              initialZoom: 18,
              initialCenter: _currentPos,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _currentPos,
                    child: widget.marker ??
                        const Icon(
                          Icons.location_on_rounded,
                          color: Colors.red,
                          size: 40.0,
                        ),
                  ),
                ],
              ),
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
          if (_overlayOpen)
            Positioned.fill(
              child: GestureDetector(
                onTap: FocusScope.of(context).unfocus,
                child: Container(color: Colors.transparent),
              ),
            ),
          if (_loading)
            Positioned.fill(
              child: widget.loadingView ??
                  Container(
                    color: Colors.black.withOpacity(0.1),
                    child: const Center(child: CircularProgressIndicator()),
                  ),
            ),
          FMSearchField(
            initialValue: _selectedValue,
            onSelected: _onSearchSelected,
            textController: _textController,
            margin: widget.searchFieldMargin,
            onSearchError: widget.onError,
            searchOptions: widget.searchOptions,
            textFieldBuilder: widget.searchTextFieldBuilder,
            searchResultListOptions: widget.searchResultListOptions,
            onOverlayVisibilityChanged: (v) => setState(() => _overlayOpen = v),
          ),
          _selectBtn,
        ],
      ),
    );
  }

  Widget get _fab {
    return FloatingActionButton(
      onPressed: _getCurrentPosition,
      child: const Icon(Icons.location_searching_rounded),
    );
  }

  Widget get _selectBtn {
    final options =
        widget.selectButtonOptions ?? FMSelectButtonOptions.initial();
    return Align(
      alignment: options.alignment,
      child: Padding(
        padding: options.padding,
        child: ElevatedButton(
          onPressed: () => widget.onSelected(_selectedValue!),
          style: options.style,
          child: options.child ?? const Text('Select'),
        ),
      ),
    );
  }

  Future<void> _onTap(TapPosition pos, LatLng coordinates) async {
    _currentPos = coordinates;
    setState(() => _loading = true);
    _selectedValue = await FMService().getAddress(
      lat: coordinates.latitude,
      lng: coordinates.longitude,
      onError: widget.onError,
      maxRetries: widget.searchOptions?.maxRetries ?? 3,
    );
    _textController.text = _selectedValue?.address ?? '';
    setState(() => _loading = false);
  }

  void _onSearchSelected(FMData data) {
    _selectedValue = data;
    _currentPos = LatLng(data.lat, data.lng);
    _mapController.move(_currentPos, 18);
    setState(() {});
  }

  Future<void> _getCurrentPosition() async {
    try {
      setState(() => _loading = true);
      final pos = await FMService().getCurrentPosition();
      _currentPos = LatLng(pos.latitude, pos.longitude);
      _selectedValue = await FMService().getAddress(
        lat: pos.latitude,
        lng: pos.longitude,
      );
      _mapController.move(_currentPos, 18);
    } catch (e, st) {
      if (widget.onError != null) {
        widget.onError!(e, st);
      } else {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context)
          ..removeCurrentSnackBar()
          ..showSnackBar(SnackBar(
            content: Text(e.toString().replaceAll('Exception:', '').trim()),
          ));
      }
    } finally {
      setState(() => _loading = false);
    }
  }
}
