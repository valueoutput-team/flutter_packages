import 'package:deeplynks/utils/api_constants.dart';
import 'package:deeplynks/utils/app_constants.dart';

/// Log Data
class LogModel {
  /// time in milliseconds since epoch
  final int time;

  /// Stacktrace
  final String? stack;

  /// Info or error message
  final String message;

  /// Log level
  final LogLevel level;

  const LogModel({
    this.stack,
    required this.time,
    required this.level,
    required this.message,
  });

  /// Map representation of the model
  Map<String, dynamic> toMap() {
    return {
      ApiKeys.v: '1.0.7',
      ApiKeys.time: time,
      ApiKeys.stack: stack,
      ApiKeys.message: message,
      ApiKeys.level: level.str,
      ApiKeys.platform: AppConstants.platform,
    };
  }
}
