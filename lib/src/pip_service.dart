import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'package:pip_mode/src/log_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ffmpeg_kit_flutter_min_gpl/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_min_gpl/return_code.dart';

class PipService {
  String? _dirPath;
  final _logService = LogService();
  static final _instance = PipService._();
  final _channel = MethodChannel('com.valueoutput.pip_mode');

  PipService._();

  factory PipService() => _instance;

  /// Generate video
  Future<String?> getVideo(GlobalKey key) async {
    try {
      final imagePath = await _createImage(key);
      final videoPath = await _createVideo(imagePath);
      await deleteFile(imagePath);
      return videoPath;
    } catch (e, st) {
      _logService.logError(e, st);
      return null;
    }
  }

  /// Delete file
  Future<void> deleteFile(String path) => File(path).delete();

  /// Start PiP Mode
  Future<void> startPipMode(String? videoPath) async {
    try {
      await _channel.invokeMethod('enterPipMode', {'videoPath': videoPath});
    } catch (e, st) {
      _logService.logError(e, st);
    }
  }

  /// Create image from widget
  Future<String> _createImage(GlobalKey key) async {
    final b = key.currentContext?.findRenderObject() as RenderRepaintBoundary;
    final image = await b.toImage(
      pixelRatio: MediaQuery.of(key.currentContext!).devicePixelRatio,
    );
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    _dirPath ??= (await getTemporaryDirectory()).path;
    final imagePath = '$_dirPath/${DateTime.now().millisecondsSinceEpoch}.png';
    await File(imagePath).writeAsBytes(data!.buffer.asUint8List());
    return imagePath;
  }

  /// Create video from image
  Future<String> _createVideo(String imagePath) async {
    final videoPath = imagePath.replaceAll('.png', '.mp4');
    final session = await FFmpegKit.execute(
      '-y -loop 1 -i $imagePath -vf "scale=320:240" -c:v libx264 -t 10 -r 30 -pix_fmt yuv420p -f mp4 $videoPath',
    );

    final code = await session.getReturnCode();
    if (!ReturnCode.isSuccess(code)) {
      final logs = await session.getAllLogsAsString();
      throw Exception(logs);
    }

    return videoPath;
  }
}
