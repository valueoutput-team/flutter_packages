import 'package:deeplynks/utils/api_constants.dart';

class AndroidInfo {
  /// Play Store download URL of your app
  final String playStoreURL;

  /// Application Id (Package Name)
  final String applicationId;

  /// List of Release SHA256 keys
  final List<String> sha256;

  const AndroidInfo({
    required this.sha256,
    required this.playStoreURL,
    required this.applicationId,
  });

  Map<String, dynamic> toMap() {
    return {
      ApiKeys.sha256: sha256,
      ApiKeys.playStoreURL: playStoreURL,
      ApiKeys.applicationId: applicationId,
    };
  }
}

class IOSInfo {
  /// You Apple Team Id
  final String teamId;

  /// iOS Bundle Id
  final String bundleId;

  /// App Store download URL of your app
  final String appStoreURL;

  const IOSInfo({
    required this.teamId,
    required this.bundleId,
    required this.appStoreURL,
  });

  Map<String, dynamic> toMap() {
    return {
      ApiKeys.teamId: teamId,
      ApiKeys.bundleId: bundleId,
      ApiKeys.appStoreURL: appStoreURL,
    };
  }
}
