import 'dart:async';
import 'package:flutter/material.dart';
import 'package:free_map/fm_models.dart';
import 'package:free_map/fm_service.dart';
import 'package:free_map/src/ui/fm_shimmer_widget.dart';

/// Search field only (without map)
class FmSearchField extends StatefulWidget {
  /// callback function when a search result is selected
  final Function(FmData?) onSelected;

  /// set options for search results list
  final FmResultViewOptions? resultViewOptions;

  /// set params for searching
  final FmSearchParams searchParams;

  /// initial selected value
  final FmData? selectedValue;

  /// Create your fully customized text field.
  /// <br>Your text field must use focusNode, controller, and onChanged arguments from this method only.
  /// <br> Example
  /// ```dart
  /// FmSearchField(
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
  const FmSearchField({
    super.key,
    this.selectedValue,
    this.textFieldBuilder,
    this.resultViewOptions,
    required this.onSelected,
    this.searchParams = const FmSearchParams(),
  });

  @override
  State<FmSearchField> createState() => _FmSearchFieldState();
}

class _FmSearchFieldState extends State<FmSearchField> {
  Timer? _timer;
  FmData? _selectedValue;
  OverlayEntry? _overlayEntry;

  final _link = LayerLink();
  late final FocusNode _focus;
  final _mapService = FmService();
  late final TextEditingController _textController;
  late final StreamController<List<FmData>?> _streamController;

  @override
  void initState() {
    super.initState();
    _focus = FocusNode();
    _focus.addListener(_onFocusChanged);
    _selectedValue = widget.selectedValue;
    _textController = TextEditingController();
    _streamController = StreamController.broadcast();
    _textController.text = _selectedValue?.address ?? '';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.selectedValue == null) return;
    if (_selectedValue?.placeId == widget.selectedValue?.placeId) return;
    _selectedValue = widget.selectedValue;
    _textController.text = _selectedValue?.address ?? '';
  }

  @override
  void didUpdateWidget(covariant FmSearchField oldWidget) {
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
          ? TextField(
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
        Center(
          child: Text(
            'Type to search addresses',
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
          itemBuilder: (_, i) => const FMShimmerWidget(
            color: Colors.grey,
            child: SizedBox(height: 40, width: double.infinity),
          ),
        );
  }

  Widget get _emptyView {
    return widget.resultViewOptions?.emptyView ??
        Center(
          child: Text(
            'No search results',
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
    _timer = Timer(const Duration(seconds: 2), () async {
      if (text.trim().isEmpty) return _addStream([]);
      _addStream(null);
      final res = await _mapService.search(q: text, p: widget.searchParams);
      _addStream(res);
    });
  }

  void _onFocusChanged() async {
    if (_focus.hasFocus) {
      _showOverlay();
      if (_selectedValue == null) return;
      await Future.delayed(const Duration(milliseconds: 100));
      _addStream([widget.selectedValue!]);
    } else {
      _hideOverlay();
      setState(() {});
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
  }

  void _hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry?.dispose();
    _overlayEntry = null;
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void _addStream(List<FmData>? data) {
    if (_streamController.isClosed) return;
    _streamController.sink.add(data);
  }

  Future<void> _onSearchResultTap(FmData data) async {
    FocusScope.of(context).unfocus();

    if (data.placeId == _selectedValue?.placeId) {
      widget.onSelected(_selectedValue);
      return;
    }

    _selectedValue = data;
    widget.onSelected(data);
    _textController.text = data.address;
  }
}
