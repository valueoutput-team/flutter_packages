import 'dart:async';
import 'package:flutter/material.dart';
import 'package:free_map/services/fm_models.dart';
import 'package:free_map/services/fm_service.dart';
import 'package:free_map/widgets/fm_shimmer_widget.dart';

/// Search field only (without map)
class FMSearchField extends StatefulWidget {
  /// initial selected value
  final FMData? initialValue;

  /// margin around search field
  final EdgeInsets margin;

  /// callback function when overlay visibility changed
  final Function(bool)? onOverlayVisibilityChanged;

  /// callback function on search error
  final Function(Object, StackTrace)? onSearchError;

  /// callback function when a search result is selected
  final Function(FMData) onSelected;

  /// set options for searching
  final FMSearchOptions? searchOptions;

  /// set options for search results list
  final FMSearchResultListOptions? searchResultListOptions;

  /// search text editing controller
  final TextEditingController textController;

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
  )? textFieldBuilder;

  const FMSearchField({
    super.key,
    this.initialValue,
    this.onSearchError,
    this.searchOptions,
    this.textFieldBuilder,
    required this.onSelected,
    required this.textController,
    this.searchResultListOptions,
    this.onOverlayVisibilityChanged,
    this.margin = const EdgeInsets.all(20),
  });

  @override
  State<FMSearchField> createState() => _FMSearchFieldState();
}

class _FMSearchFieldState extends State<FMSearchField> {
  Timer? _timer;
  OverlayEntry? _overlayEntry;

  final _link = LayerLink();
  final _mapService = FMService();
  late final FocusNode _searchFocus;
  late final StreamController<List<FMData>?> _searchStreamController;

  @override
  void initState() {
    super.initState();
    _searchFocus = FocusNode();
    _searchFocus.addListener(_onFocusChanged);
    widget.textController.text = widget.initialValue?.address ?? '';
    _searchStreamController = StreamController<List<FMData>?>.broadcast();
  }

  @override
  void didUpdateWidget(covariant FMSearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    widget.textController.text = widget.initialValue?.address ?? '';
  }

  @override
  void dispose() {
    _stopTimer();
    _hideOverlay();
    _searchFocus.dispose();
    _searchStreamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: widget.margin,
      child: CompositedTransformTarget(
        link: _link,
        child: widget.textFieldBuilder == null
            ? TextFormField(
                onChanged: _onChanged,
                focusNode: _searchFocus,
                controller: widget.textController,
                decoration: const InputDecoration(hintText: 'Search Address'),
              )
            : widget.textFieldBuilder!(
                _searchFocus,
                widget.textController,
                _onChanged,
              ),
      ),
    );
  }

  Widget get _searchResultsList {
    return StreamBuilder(
      stream: _searchStreamController.stream,
      builder: (_, snap) {
        if (widget.textController.text.trim().isEmpty) return _noTextView;
        if (snap.data == null) return _loadingView;
        if (snap.data!.isEmpty) return _emptyView;
        return ListView.separated(
          shrinkWrap: true,
          itemCount: snap.data!.length,
          padding: widget.searchResultListOptions?.padding ?? EdgeInsets.zero,
          separatorBuilder: widget.searchResultListOptions?.separatorBuilder ??
              (_, i) => const Divider(),
          itemBuilder: (context, i) {
            final data = snap.data![i];
            if (widget.searchResultListOptions?.itemBuilder == null) {
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
                child: widget.searchResultListOptions?.itemBuilder!(
                  context,
                  i,
                  data,
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget get _noTextView {
    if (widget.searchResultListOptions?.noTextView != null) {
      return widget.searchResultListOptions!.noTextView!;
    }

    return Center(
      child: Text(
        'Type to search addresses',
        style: Theme.of(context).textTheme.labelLarge,
      ),
    );
  }

  Widget get _loadingView {
    if (widget.searchResultListOptions?.loadingView != null) {
      return widget.searchResultListOptions!.loadingView!;
    }
    return ListView.separated(
      itemCount: 3,
      shrinkWrap: true,
      padding:
          widget.searchResultListOptions?.padding ?? const EdgeInsets.all(20),
      separatorBuilder: widget.searchResultListOptions?.separatorBuilder ??
          (_, i) => const Divider(),
      itemBuilder: (_, i) => const FMShimmerWidget(
        color: Colors.grey,
        child: SizedBox(height: 40, width: double.infinity),
      ),
    );
  }

  Widget get _emptyView {
    if (widget.searchResultListOptions?.emptyView != null) {
      return widget.searchResultListOptions!.emptyView!;
    }
    return Center(
      child: Text(
        'No search results',
        style: Theme.of(context).textTheme.labelLarge,
      ),
    );
  }

  Future<void> _onChanged(String text) async {
    _stopTimer();
    if (!_searchFocus.hasFocus) return;
    _timer = Timer(const Duration(seconds: 2), () async {
      _searchStreamController.sink.add(null);
      final res = await _mapService.search(
        searchText: text.trim(),
        options: widget.searchOptions,
        onError: widget.onSearchError,
      );
      _searchStreamController.sink.add(res);
    });
  }

  void _onSearchResultTap(FMData data) {
    FocusScope.of(context).unfocus();
    widget.textController.text = data.address;
    widget.onSelected(data);
  }

  void _onFocusChanged() async {
    if (_searchFocus.hasFocus) {
      _showOverlay();
      if (widget.initialValue != null) {
        await Future.delayed(const Duration(milliseconds: 100));
        _searchStreamController.sink.add([widget.initialValue!]);
      }
    } else {
      _hideOverlay();
      widget.textController.text = widget.initialValue?.address ?? '';
    }
    if (widget.onOverlayVisibilityChanged != null) {
      widget.onOverlayVisibilityChanged!(_searchFocus.hasFocus);
    }
  }

  void _showOverlay() {
    _hideOverlay();
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);
    _overlayEntry = OverlayEntry(
      builder: (_) => Positioned(
        left: offset.dx,
        width: size.width - widget.margin.left - widget.margin.right,
        top: offset.dy + size.height - widget.margin.top - widget.margin.bottom,
        child: CompositedTransformFollower(
          link: _link,
          showWhenUnlinked: false,
          offset: Offset(
            0,
            size.height - widget.margin.top - widget.margin.bottom,
          ),
          child: Material(
            elevation: 4,
            color: widget.searchResultListOptions?.overlayDecoration == null
                ? Colors.grey[300]
                : null,
            child: Container(
              decoration: widget.searchResultListOptions?.overlayDecoration,
              constraints: BoxConstraints(
                maxHeight: widget.searchResultListOptions?.maxHeight ?? 200,
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
}
