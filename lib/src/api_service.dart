import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:google_maps_helper/src/app_constants.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_helper/src/res_model.dart';
import 'package:google_maps_helper/src/log_service.dart';

/// Handle API requests
class ApiService {
  final _logService = LogService();
  static final _instance = ApiService._();

  ApiService._();

  factory ApiService() {
    return _instance;
  }

  /// Send an API request
  Future<ResModel> request({
    int? startTime,
    int retryCount = 0,
    required String url,
  }) async {
    startTime ??= DateTime.now().millisecondsSinceEpoch;

    if (retryCount == 0) {
      _logService.logInfo('----------------------------------------------');
      _logService.logInfo('URL: $url');
    }

    try {
      final res =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));
      final excTime = DateTime.now().millisecondsSinceEpoch - startTime;
      _logService.logInfo('STATUS CODE: ${res.statusCode}');
      _logService.logInfo('RESPONSE: ${res.body}');
      _logService.logInfo('EXC TIME: $excTime ms');
      _logService.logInfo('----------------------------------------------');

      return ResModel.fromJSON(res.body, statusCode: res.statusCode);
    } catch (e, st) {
      if (retryCount < 2) {
        return request(
          url: url,
          startTime: startTime,
          retryCount: ++retryCount,
        );
      }

      // if (endpoint != ApiEndpoints.logs)
      _logService.logError(e, st);
      return ResModel(
        message: e.runtimeType == SocketException
            ? 'No internet connection'
            : e.runtimeType == TimeoutException
                ? 'Server did not respond'
                : 'An error occured',
      );
    }
  }

  /// Request Places API New
  Future<ResModel> requestNew({
    int? startTime,
    int retryCount = 0,
    required String apiKey,
    List<String>? fieldMask,
    required String endpoint,
    required Map<String, dynamic> body,
  }) async {
    startTime ??= DateTime.now().millisecondsSinceEpoch;
    final url = '${BaseURLs.placesNew}:$endpoint';

    if (retryCount == 0) {
      _logService.logInfo('----------------------------------------------');
      _logService.logInfo('URL: $url');
    }

    try {
      final res = await http.post(
        Uri.parse(url),
        body: jsonEncode(body),
        headers: {
          'X-Goog-Api-Key': apiKey,
          'Content-Type': 'application/json',
          'X-Goog-FieldMask': fieldMask?.join(',') ?? '*',
        },
      ).timeout(const Duration(seconds: 10));
      final excTime = DateTime.now().millisecondsSinceEpoch - startTime;
      _logService.logInfo('STATUS CODE: ${res.statusCode}');
      _logService.logInfo('RESPONSE: ${res.body}');
      _logService.logInfo('EXC TIME: $excTime ms');
      _logService.logInfo('----------------------------------------------');

      return ResModel.fromJSON(res.body, statusCode: res.statusCode);
    } catch (e, st) {
      if (retryCount < 2) {
        return requestNew(
          body: body,
          apiKey: apiKey,
          endpoint: endpoint,
          fieldMask: fieldMask,
          startTime: startTime,
          retryCount: ++retryCount,
        );
      }

      _logService.logError(e, st);
      return ResModel(
        message: e.runtimeType == SocketException
            ? 'No internet connection'
            : e.runtimeType == TimeoutException
                ? 'Server did not respond'
                : 'An error occured',
      );
    }
  }
}
