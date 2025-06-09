import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:free_map/src/fm_constants.dart';
import 'package:free_map/src/models/res_model.dart';
import 'package:free_map/src/services/log_service.dart';

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
    String? userAgent,
    int retryCount = 0,
    required String url,
    Map<String, dynamic>? body,
    RequestMethod method = RequestMethod.get,
  }) async {
    startTime ??= DateTime.now().millisecondsSinceEpoch;

    if (retryCount == 0) {
      _logService.logInfo('----------------------------------------------');
      _logService.logInfo('URL: $url');
    }

    try {
      http.Response res;
      switch (method) {
        case RequestMethod.get:
          res = await http
              .get(
                Uri.parse(url),
                headers: userAgent == null ? null : {'User-Agent': userAgent},
              )
              .timeout(const Duration(seconds: 10));
          break;
        case RequestMethod.post:
          res = await http
              .post(Uri.parse(url), body: jsonEncode(body))
              .timeout(const Duration(seconds: 10));
          break;
      }

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
          body: body,
          method: method,
          userAgent: userAgent,
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
}
