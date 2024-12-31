import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:deeplynks/src/log_service.dart';
import 'package:http/http.dart' as http;
import 'package:deeplynks/src/res_model.dart';
import 'package:deeplynks/src/api_constants.dart';
import 'package:deeplynks/src/app_constants.dart';

/// Handle API requests
class ApiService {
  String? _token;
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
    bool useBaseURL = true,
    required String endpoint,
    required ApiMethod method,
    Map<String, dynamic>? body,
    Map<String, String>? query,
  }) async {
    startTime ??= DateTime.now().millisecondsSinceEpoch;

    // 1. Create url
    String url = useBaseURL ? ApiConstants.apiBaseURL + endpoint : endpoint;
    if (query != null) {
      url += '?';
      url += query.keys.map((k) => '$k=${query[k]}').join('&');
    }

    // 2. Create headers
    final Map<String, String> headers = useBaseURL
        ? {
            'accept': 'application/json',
            'content-type': 'application/json',
            if (_token != null) 'Authorization': 'Bearer $_token',
          }
        : {};

    if (retryCount == 0) {
      _logService.logInfo('----------------------------------------------');
      _logService.logInfo('URL: $url');
      _logService.logInfo('METHOD: $method');
      _logService.logInfo('HEADERS: ${jsonEncode(headers)}');
      if (body != null) _logService.logInfo('BODY: ${jsonEncode(body)}');
    }

    // 3. Call API
    try {
      final (statusCode, resBody) = await _jsonReq(url, method, headers, body);

      final excTime = DateTime.now().millisecondsSinceEpoch - startTime;
      _logService.logInfo('STATUS CODE: $statusCode');
      _logService.logInfo('RESPONSE: $resBody');
      _logService.logInfo('EXC TIME: $excTime ms');
      _logService.logInfo('----------------------------------------------');

      final res = ResModel.fromJSON(resBody, statusCode: statusCode);
      if (res.success && endpoint == ApiEndpoints.registerApp) {
        _token = res.data[ApiKeys.data][ApiKeys.token];
      }

      return res;
    } catch (e, st) {
      if (retryCount < 2) {
        return request(
          body: body,
          query: query,
          method: method,
          endpoint: endpoint,
          startTime: startTime,
          useBaseURL: useBaseURL,
          retryCount: ++retryCount,
        );
      }

      if (endpoint != ApiEndpoints.logs) _logService.logError(e, st);
      return ResModel(
        message: e.runtimeType == SocketException
            ? ErrorStrings.noInternet
            : e.runtimeType == TimeoutException
                ? ErrorStrings.noResponse
                : ErrorStrings.errorOccured,
      );
    }
  }

  /// Send REST API request
  Future<(int, String)> _jsonReq(
    String url,
    ApiMethod method,
    Map<String, String> headers,
    Map<String, dynamic>? body,
  ) async {
    http.Response res;
    switch (method) {
      case ApiMethod.get:
        res = await http
            .get(Uri.parse(url), headers: headers)
            .timeout(const Duration(seconds: 10));
        break;
      case ApiMethod.post:
        res = await http
            .post(
              Uri.parse(url),
              headers: headers,
              body: body == null ? null : json.encode(body),
            )
            .timeout(const Duration(seconds: 10));
        break;
      case ApiMethod.delete:
        res = await http
            .delete(Uri.parse(url), headers: headers)
            .timeout(const Duration(seconds: 10));
        break;
    }

    return (res.statusCode, res.body);
  }
}
