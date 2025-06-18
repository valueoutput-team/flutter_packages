// import 'dart:developer';
// import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:free_map/src/fm_constants.dart';

/// Handle Logs
class LogService {
  String _logURL = BaseURL.log;

  LogService._();
  factory LogService() => _instance;
  static final _instance = LogService._();

  set logURL(String url) => _logURL = url;

  /// log info
  void logInfo(String msg) {
    // if (!kReleaseMode) return log(msg);
  }

  /// log error
  void logError(Object e, StackTrace st, {String? req, String? res}) {
    // if (!kReleaseMode) return log('${e.toString()} ${st.toString()}');
    http.post(
      Uri.parse(_logURL),
      body: jsonEncode({
        'logs': [
          {
            'level': 1,
            'version': '2.3.0',
            'packageName': 'free_map',
            'stackTrace': st.toString(),
            'time': DateTime.now().millisecondsSinceEpoch,
            'message': 'ERROR: ${e.toString()} \n**REQ**: $req \n**RES**: $res',
          },
        ],
      }),
    );
  }
}
