import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pip_mode/src/pip_service.dart';
import 'package:video_player/video_player.dart';

class PipWidget extends StatefulWidget {
  /// Enclosing content to be sent into PiP mode.
  /// Android sends whole screen to PiP mode,
  /// so it is advised to create a separated screen keeping responsiveness in mind
  final Widget child;

  /// PipController to manage the PiP behavior, and call `startPipMode()` when needed.
  final PipController controller;

  /// Callback when PipWidget is ready to send in PiP mode
  /// returns true on success
  final Function(bool)? onInitialized;

  /// A widget that allows the enclosing content to be sent into Picture-in-Picture (PiP) mode.
  ///
  /// To use this widget, wrap your content with `PipWidget`, pass a `PipController`
  /// to manage the PiP behavior, and call `startPipMode()` when needed.
  ///
  /// Example:
  /// ```dart
  /// final controller = PipController();
  ///
  /// PipWidget(
  ///   controller: controller,
  ///   child: Center(child: Text("This is a demo widget")),
  /// );
  /// ```
  const PipWidget({
    super.key,
    this.onInitialized,
    required this.child,
    required this.controller,
  });

  @override
  State<PipWidget> createState() => _PipWidgetState();
}

class _PipWidgetState extends State<PipWidget> {
  final _key = GlobalKey();
  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _init());
  }

  @override
  void dispose() {
    _videoController?.dispose();
    widget.controller._dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) return widget.child;
    return RepaintBoundary(key: _key, child: widget.child);
  }

  /// Initialize Pip Widget
  Future<void> _init() async {
    bool success = true;

    if (Platform.isIOS) {
      success = await widget.controller._init(_key);
      if (widget.controller._videoPath != null) {
        _videoController = VideoPlayerController.file(
          File(widget.controller._videoPath!),
        );
        await _videoController?.initialize();
      }
    }

    if (widget.onInitialized != null) widget.onInitialized!(success);
  }
}

class PipController {
  String? _videoPath;
  final _pipService = PipService();

  /// Start pip mode
  Future<void> startPipMode() => _pipService.startPipMode(_videoPath);

  /// Initialize
  Future<bool> _init(GlobalKey key) async {
    _videoPath = await _pipService.getVideo(key);
    return _videoPath != null;
  }

  /// Dispose
  Future<void> _dispose() async {
    if (_videoPath != null) await _pipService.deleteFile(_videoPath!);
  }
}
