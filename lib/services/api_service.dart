import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:google_maps_helper/models/res_model.dart';
import 'package:google_maps_helper/services/log_service.dart';

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
}
