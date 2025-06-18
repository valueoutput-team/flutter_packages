import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SystemService {
  String? _version;
  String? _packageName;
  late final String _os;

  factory SystemService() => _instance;
  static final _instance = SystemService._();
  SystemService._() {
    _os = kIsWeb ? 'web' : Platform.operatingSystem;
  }

  String? get packageName => _packageName;
  String get userAgent =>
      '${_packageName ?? 'unknown'}/${_version ?? '0'}; $_os';

  Future<void> init() async {
    if (_packageName != null) return;
    final packageInfo = await PackageInfo.fromPlatform();
    _version = packageInfo.version;
    _packageName = packageInfo.packageName;
  }
}
