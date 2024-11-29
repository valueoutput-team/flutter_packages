// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:deeplynks/models/deeplynks_model.dart';
import 'package:deeplynks/services/api_service.dart';
import 'package:deeplynks/services/log_service.dart';
import 'package:deeplynks/utils/api_constants.dart';
import 'package:deeplynks/utils/app_constants.dart';

/// Deeplynks singleton class
class Deeplynks {
  String? _appId;
  String? _clickId;
  double _devicePixelRatio = 0;

  final _apiService = ApiService();
  final _logService = LogService();
  static final _instance = Deeplynks._();
  late final StreamController<String> _streamController;

  Deeplynks._() {
    _streamController = StreamController.broadcast();
    _initMethodChannel();
  }

  factory Deeplynks() {
    return _instance;
  }

  /// Stream of link data
  Stream<String> get stream => _streamController.stream;

  /// Initialize the service
  /// Must be called first, before using any other DeepLynks method
  /// returns a unique app ID for your app. This ID remains same until application id or bundle id is changed
  Future<String?> init({
    IOSInfo? iosInfo,
    AndroidInfo? androidInfo,
    required BuildContext context,
  }) async {
    assert(
      androidInfo != null || iosInfo != null,
      ErrorStrings.appInfoMissing,
    );

    if (_appId != null) return _appId;
    _devicePixelRatio = MediaQuery.of(context).devicePixelRatio;

    final res = await _apiService.request(
      method: ApiMethod.post,
      endpoint: ApiEndpoints.registerApp,
      body: {
        if (iosInfo != null) ApiKeys.iOS: iosInfo.toMap(),
        if (androidInfo != null) ApiKeys.android: androidInfo.toMap(),
      },
    );

    if (res.success) {
      try {
        _appId = res.data[ApiKeys.data][ApiKeys.id];
        _searchClick();
      } catch (e, st) {
        _logService.logError(e, st);
      }
    }

    return _appId;
  }

  /// Creates a new deep link.
  /// @param [data] The content to share through the link.
  /// This can be an absolute URL, relative URL, query parameters, JSON object, plain text, or any other string-formatted data.
  Future<String?> createLink(String data) async {
    assert(_appId != null, ErrorStrings.serviceUninitialized);

    if (_appId == null) return null;

    final res = await _apiService.request(
      method: ApiMethod.post,
      endpoint: ApiEndpoints.links,
      body: {ApiKeys.appId: _appId, ApiKeys.data: data},
    );

    if (!res.success) return null;

    try {
      final id = res.data[ApiKeys.data][ApiKeys.id];
      return '${ApiConstants.webBaseURL}/$_appId/$id';
    } catch (e, st) {
      _logService.logError(e, st);
      return null;
    }
  }

  /// Mark the link as completed
  /// This prevants it from coming up again in the next app session
  Future<bool> markCompleted() async {
    assert(_appId != null, ErrorStrings.serviceUninitialized);
    if (_clickId == null) return false;
    final res = await _apiService.request(
      method: ApiMethod.delete,
      endpoint: '${ApiEndpoints.deleteClick}/$_clickId',
    );
    return res.success;
  }

  /// initialize the method channel
  Future<void> _initMethodChannel() async {
    if (kIsWeb) return;
    const platform = MethodChannel(AppConstants.channelName);

    // 1. Get initial link (Android Only)
    if (Platform.isAndroid) {
      try {
        final link = await platform.invokeMethod<String>(
          AppConstants.getInitialLinkMethod,
        );
        if (link != null) await _onLink(link);
      } catch (e) {
        // _logService.logError(e, st);
      }
    }

    // 2. Listen to incoming links
    platform.setMethodCallHandler((call) async {
      if (call.method == AppConstants.onLinkMethod) {
        if (call.arguments is String) _onLink(call.arguments);
      }
    });
  }

  /// search for click
  Future<void> _searchClick() async {
    if (kIsWeb) return;

    // 1. Get IP address
    String? ip;
    var res = await _apiService.request(
      useBaseURL: false,
      method: ApiMethod.get,
      endpoint: ApiConstants.ip,
    );

    try {
      ip = res.data[ApiKeys.ip];
    } catch (e, st) {
      _logService.logError(e, st);
    }

    if (ip == null) return;

    // 2. Search click
    res = await _apiService.request(
      method: ApiMethod.post,
      endpoint: ApiEndpoints.searchClick,
      body: {
        ApiKeys.ip: ip,
        ApiKeys.appId: _appId,
        ApiKeys.devicePixelRatio: _devicePixelRatio,
        ApiKeys.os: Platform.isAndroid ? OS.android.str : OS.iOS.str,
      },
    );

    if (!res.success) return;

    try {
      final timeMs = res.data[ApiKeys.data][ApiKeys.lastUpdated];
      final diff = DateTime.now().millisecondsSinceEpoch - timeMs;
      if (diff > 24 * 60 * 60 * 1000) return;
      _clickId = res.data[ApiKeys.data][ApiKeys.id] as String;
      _onData(res.data[ApiKeys.data][ApiKeys.linkData] as String);
    } catch (e, st) {
      _logService.logError(e, st);
    }
  }

  /// Handle app opened by link
  Future<void> _onLink(String link) async {
    final linkId = Uri.tryParse(link)?.pathSegments.lastOrNull;
    if (linkId == null) return;

    final res = await _apiService.request(
      method: ApiMethod.get,
      endpoint: '${ApiEndpoints.links}/$linkId',
    );
    if (!res.success) return;

    try {
      _onData(res.data[ApiKeys.data][ApiKeys.linkData] as String);
    } catch (e, st) {
      _logService.logError(e, st);
    }
  }

  /// Add link data to stream
  void _onData(String data) {
    if (!_streamController.isClosed) _streamController.sink.add(data);
  }
}
