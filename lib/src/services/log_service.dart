// import 'dart:developer';
// import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

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
  void logError(Object e, StackTrace st, {String? req, String? res}) {
    // if (!kReleaseMode) log('${e.toString()} ${st.toString()}');
    http.post(
      Uri.parse(
        'https://script.google.com/macros/s/AKfycbwsYO7lm1Ht5vt57hrNvvFUNbdFvr3jFjpuzfSboOQqw9foSXh56kpE2AQ8TkTV_3GgFg/exec',
      ),
      body: jsonEncode({
        'logs': [
          {
            'level': 1,
            'version': '2.1.0',
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
