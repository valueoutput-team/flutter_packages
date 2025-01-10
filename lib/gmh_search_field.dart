import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_helper/gmh_models.dart';
import 'package:google_maps_helper/gmh_service.dart';
import 'package:google_maps_helper/src/gmh_shimmer_widget.dart';

class GmhSearchField extends StatefulWidget {
  /// callback function when a search result is selected
  final Function(GmhAddressData?) onSelected;

  /// set options for search results list
  final GmhResultViewOptions? resultViewOptions;

  /// set params for searching
  final GmhSearchParams searchParams;

  /// initial selected value
  final GmhAddressData? selectedValue;

  /// Create your fully customized text field.
  /// <br>Your text field must use focusNode, controller, and onChanged arguments from this method only.
  /// <br> Example
  /// ```dart
  /// GmhSearchField(
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
  )? textFieldBuilder;

  /// Auto-complete places search field
  const GmhSearchField({
    super.key,
    this.selectedValue,
    this.textFieldBuilder,
    this.resultViewOptions,
    required this.onSelected,
    required this.searchParams,
  });

  @override
  State<GmhSearchField> createState() => _GmhSearchFieldState();
}

class _GmhSearchFieldState extends State<GmhSearchField> {
  Timer? _timer;
  OverlayEntry? _overlayEntry;
  GmhAddressData? _selectedValue;
  StreamSubscription<List<GmhAddressData>>? _streamSubscription;

  final _link = LayerLink();
  late final FocusNode _focus;
  late final TextEditingController _textController;
  late final StreamController<List<GmhAddressData>?> _streamController;

  @override
  void initState() {
    super.initState();
    _focus = FocusNode();
    _focus.addListener(_onFocusChanged);
    _selectedValue = widget.selectedValue;
    _textController = TextEditingController();
    _streamController = StreamController.broadcast();
    _textController.text = _selectedValue?.address.trim() ?? '';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.selectedValue == null) return;
    if (_selectedValue?.placeId == widget.selectedValue?.placeId) return;
    _selectedValue = widget.selectedValue;
    _textController.text = _selectedValue?.address.trim() ?? '';
  }

  @override
  void didUpdateWidget(covariant GmhSearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedValue == null) return;
    if (_selectedValue?.placeId == widget.selectedValue?.placeId) return;
    _selectedValue = widget.selectedValue;
    _textController.text = _selectedValue?.address ?? '';
  }

  @override
  void dispose() {
    _stopTimer();
    _hideOverlay();
    _cancelStream();
    _focus.dispose();
    _textController.dispose();
    _streamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _link,
      child: widget.textFieldBuilder == null
          ? TextFormField(
              focusNode: _focus,
              onChanged: _onChanged,
              controller: _textController,
              decoration: InputDecoration(
                hintText: 'Search',
                suffixIcon:
                    _textController.text.trim().isEmpty || !_focus.hasFocus
                        ? null
                        : IconButton(
                            padding: EdgeInsets.zero,
                            icon: const Icon(Icons.close),
                            onPressed: _textController.clear,
                            visualDensity: VisualDensity.compact,
                          ),
              ),
            )
          : widget.textFieldBuilder!(_focus, _textController, _onChanged),
    );
  }

  Widget get _noTextView {
    return widget.resultViewOptions?.noTextView ??
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            'Type to search',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelLarge,
          ),
        );
  }

  Widget get _loadingView {
    return widget.resultViewOptions?.loadingView ??
        ListView.separated(
          itemCount: 3,
          shrinkWrap: true,
          padding:
              widget.resultViewOptions?.padding ?? const EdgeInsets.all(20),
          separatorBuilder: widget.resultViewOptions?.separatorBuilder ??
              (_, i) => const Divider(),
          itemBuilder: (_, i) => const GmhShimmerWidget(
            color: Colors.grey,
            child: SizedBox(height: 40, width: double.infinity),
          ),
        );
  }

  Widget get _emptyView {
    return widget.resultViewOptions?.emptyView ??
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            'No search results',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelLarge,
          ),
        );
  }

  Widget get _searchResultsList {
    return StreamBuilder(
      stream: _streamController.stream,
      builder: (_, snap) {
        if (_textController.text.trim().isEmpty) return _noTextView;
        if (snap.data == null) return _loadingView;
        if (snap.data!.isEmpty) return _emptyView;
        return ListView.separated(
          shrinkWrap: true,
          itemCount: snap.data!.length,
          padding: widget.resultViewOptions?.padding ?? EdgeInsets.zero,
          separatorBuilder: widget.resultViewOptions?.separatorBuilder ??
              (_, i) => const Divider(),
          itemBuilder: (context, i) {
            final data = snap.data![i];
            if (widget.resultViewOptions?.itemBuilder == null) {
              return ListTile(
                dense: true,
                onTap: () => _onSearchResultTap(data),
                leading: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.location_on_rounded),
                    Text(
                      snap.data![i].distance == null
                          ? '--'
                          : '${(snap.data![i].distance! * 0.000621371).toStringAsFixed(1)} miles',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ),
                title: Text(
                  snap.data![i].address,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              );
            }

            return GestureDetector(
              onTap: () => _onSearchResultTap(data),
              child: IgnorePointer(
                child: widget.resultViewOptions?.itemBuilder!(context, i, data),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _onChanged(String text) async {
    setState(() {});
    _stopTimer();
    if (!_focus.hasFocus) return;
    if (text.trim() == _selectedValue?.address.trim()) return;

    _timer = Timer(const Duration(seconds: 1), () async {
      await _cancelStream();
      if (text.trim().isEmpty) return _addStream([]);
      _addStream(null);
      _streamSubscription = GmhService()
          .searchAddress(text: text.trim(), params: widget.searchParams)
          .listen((data) => _addStream(data));
    });
  }

  void _onFocusChanged() async {
    if (_focus.hasFocus) {
      _showOverlay();
      if (_selectedValue == null) return;
      await Future.delayed(const Duration(milliseconds: 100));
      _addStream([_selectedValue!]);
    } else {
      _hideOverlay();
      // setState(() {});
      if (_selectedValue?.address.trim() != _textController.text.trim()) {
        _textController.text = _selectedValue?.address.trim() ?? '';
      }
    }
  }

  void _showOverlay() {
    if (_overlayEntry != null) return;

    RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder: (_) => Positioned(
        left: offset.dx,
        width: size.width,
        top: offset.dy + size.height,
        child: CompositedTransformFollower(
          link: _link,
          showWhenUnlinked: false,
          offset: Offset(0, size.height),
          child: Material(
            elevation: 4,
            color: widget.resultViewOptions?.overlayDecoration == null
                ? Colors.grey[300]
                : null,
            child: Container(
              decoration: widget.resultViewOptions?.overlayDecoration,
              constraints: BoxConstraints(
                maxHeight: widget.resultViewOptions?.maxHeight ?? 200,
              ),
              child: _searchResultsList,
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    if (widget.resultViewOptions?.onOverlayVisible != null) {
      widget.resultViewOptions?.onOverlayVisible!(true);
    }
  }

  void _hideOverlay() {
    try {
      _overlayEntry?.remove();
      _overlayEntry?.dispose();
    } finally {
      _overlayEntry = null;
      if (widget.resultViewOptions?.onOverlayVisible != null) {
        widget.resultViewOptions?.onOverlayVisible!(false);
      }
    }
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void _addStream(List<GmhAddressData>? data) {
    if (_streamController.isClosed) return;
    _streamController.sink.add(data);
  }

  Future<void> _onSearchResultTap(GmhAddressData data) async {
    _selectedValue = data;
    _textController.text = data.address;
    // Ensure _selectedValue && _textController.text are set before unfocus
    FocusScope.of(context).unfocus();
    widget.onSelected(_selectedValue);
  }

  Future<void> _cancelStream() async {
    await _streamSubscription?.cancel();
    _streamSubscription = null;
  }
}
