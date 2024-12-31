import 'package:deeplynks/src/api_constants.dart';

/// App Meta Data
/// This data will be used for link preview
class MetaInfo {
  /// App name
  final String name;

  /// App description
  final String description;

  /// An image URL for link preview, typically an App Logo
  /// Make sure to disable CORS for deeplynks.web.app to allow access
  final String? imageURL;

  MetaInfo({
    this.imageURL,
    required this.name,
    required this.description,
  })  : assert(name.trim().length <= 50, 'Name can be max. 50 characters'),
        assert(
          description.trim().length <= 150,
          'Description can be max. 150 characters',
        ),
        assert(
          imageURL == null || Uri.tryParse(imageURL) != null,
          'Invalid image URL',
        );

  /// Map representation of the model
  Map<String, dynamic> toMap() {
    return {
      ApiKeys.name: name.trim(),
      ApiKeys.imageURL: imageURL,
      ApiKeys.description: description.trim(),
    };
  }
}

/// Android App Information
class AndroidInfo {
  /// Play Store download URL of your app
  /// Give an empty string if your app is not live yet
  final String playStoreURL;

  /// Application Id (Package Name)
  final String applicationId;

  /// List of Release SHA256 keys
  /// Give an empty list if your app doesn't have release keys yet
  final List<String> sha256;

  AndroidInfo({
    required this.sha256,
    required this.playStoreURL,
    required this.applicationId,
  })  : assert(applicationId.trim().isNotEmpty, 'applicationId is required'),
        assert(
          playStoreURL.trim().isEmpty || Uri.tryParse(playStoreURL) != null,
          'Invalid playStoreURL',
        );

  /// Map representation of the model
  Map<String, dynamic> toMap() {
    return {
      ApiKeys.sha256: sha256,
      ApiKeys.playStoreURL: playStoreURL,
      ApiKeys.applicationId: applicationId.trim(),
    };
  }
}

/// iOS App Information
class IOSInfo {
  /// You Apple Team Id
  /// Give an empty string if you don't have an App Store account yet
  final String teamId;

  /// iOS Bundle Id
  final String bundleId;

  /// App Store download URL of your app
  /// Give an empty string if your app is not live yet
  final String appStoreURL;

  IOSInfo({
    required this.teamId,
    required this.bundleId,
    required this.appStoreURL,
  })  : assert(bundleId.trim().isNotEmpty, 'bundleId is required'),
        assert(
          appStoreURL.trim().isEmpty || Uri.tryParse(appStoreURL) != null,
          'Invalid appStoreURL',
        );

  /// Map representation of the model
  Map<String, dynamic> toMap() {
    return {
      ApiKeys.teamId: teamId,
      ApiKeys.bundleId: bundleId,
      ApiKeys.appStoreURL: appStoreURL,
    };
  }
}
