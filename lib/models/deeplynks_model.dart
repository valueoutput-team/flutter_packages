import 'package:deeplynks/utils/api_constants.dart';

/// App Meta Data
/// This data will be used for link preview
class MetaInfo {
  /// App name
  final String name;

  /// App description
  final String description;

  /// An image URL for link preview, typically an App Logo
  final String? imageURL;

  MetaInfo({
    this.imageURL,
    required this.name,
    required this.description,
  }) {
    assert(name.trim().length <= 50, 'Name can be max. 50 characters');
    assert(
      description.trim().length <= 150,
      'Description can be max. 150 characters',
    );
    assert(
      imageURL == null || Uri.tryParse(imageURL!) != null,
      'Invalid image URL',
    );
  }

  /// Map representation of the model
  Map<String, dynamic> toMap() {
    return {
      ApiKeys.name: name,
      ApiKeys.imageURL: imageURL,
      ApiKeys.description: description,
    };
  }
}

/// Android App Information
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

  /// Map representation of the model
  Map<String, dynamic> toMap() {
    return {
      ApiKeys.sha256: sha256,
      ApiKeys.playStoreURL: playStoreURL,
      ApiKeys.applicationId: applicationId,
    };
  }
}

/// iOS App Information
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

  /// Map representation of the model
  Map<String, dynamic> toMap() {
    return {
      ApiKeys.teamId: teamId,
      ApiKeys.bundleId: bundleId,
      ApiKeys.appStoreURL: appStoreURL,
    };
  }
}
