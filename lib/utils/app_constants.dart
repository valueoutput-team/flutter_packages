/// Operating System
enum OS { android, iOS }

/// Log level
enum LogLevel { info, error }

/// API request method type
enum ApiMethod { get, post, delete }

/// Extension on [LogLevel]
extension LogLevelData on LogLevel {
  String get str {
    switch (this) {
      case LogLevel.info:
        return 'INFO';
      case LogLevel.error:
        return 'ERROR';
    }
  }
}

/// Extension on [OS]
extension OSData on OS {
  String get str {
    switch (this) {
      case OS.android:
        return 'android';
      case OS.iOS:
        return 'iOS';
    }
  }
}

/// Error Messages
abstract class ErrorStrings {
  static const errorOccured = 'An error occured';
  static const noInternet = 'No internet connection';
  static const noResponse = 'Server did not respond';
  static const appInfoMissing =
      'At least one of the androidInfo and iosInfo must be non-null';
  static const serviceUninitialized =
      'Ensure that service is initialized first. Call init() at the start.';
}

/// App constants used across the package
abstract class AppConstants {
  static const platform = 'APP';
  static const onLinkMethod = 'onLink';
  static const channelName = 'app.web.deeplynks';
  static const getInitialLinkMethod = 'getInitialLink';
}
