import 'package:deeplynks/utils/api_constants.dart';
import 'package:deeplynks/utils/app_constants.dart';

class LogModel {
  final int time;
  final String? stack;
  final String message;
  final LogLevel level;

  const LogModel({
    this.stack,
    required this.time,
    required this.level,
    required this.message,
  });

  Map<String, dynamic> toMap() {
    return {
      ApiKeys.time: time,
      ApiKeys.stack: stack,
      ApiKeys.message: message,
      ApiKeys.level: level.str,
      ApiKeys.platform: AppConstants.platform,
    };
  }
}
