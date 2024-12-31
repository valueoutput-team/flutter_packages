import 'dart:convert';
// import 'dart:developer';
import 'package:http/http.dart' as http;
// import 'package:flutter/foundation.dart';

/// Handle Logs
class LogService {
  static final _instance = LogService._();

  LogService._();

  factory LogService() {
    return _instance;
  }

  /// log info
  void logInfo(String msg) {
    // if (!kReleaseMode) log(msg);
  }

  /// log error
  void logError(Object e, StackTrace st) {
    // if (!kReleaseMode) log('${e.toString()} ${st.toString()}');
    http.post(
      Uri.parse(
        'https://script.google.com/macros/s/AKfycbwsYO7lm1Ht5vt57hrNvvFUNbdFvr3jFjpuzfSboOQqw9foSXh56kpE2AQ8TkTV_3GgFg/exec',
      ),
      body: jsonEncode({
        'logs': [
          {
            'level': 1,
            'version': '1.1.1',
            'message': e.toString(),
            'stackTrace': st.toString(),
            'packageName': 'google_maps_helper',
            'time': DateTime.now().millisecondsSinceEpoch,
          }
        ]
      }),
    );
  }
}
