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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MetaInfo &&
        other.name == name &&
        other.imageURL == imageURL &&
        other.description == description;
  }

  @override
  int get hashCode => name.hashCode ^ imageURL.hashCode ^ description.hashCode;
}

/// Android App Information
class AndroidInfo {
  /// Play Store download URL of your app
  final String playStoreURL;

  /// Application Id (Package Name)
  final String applicationId;

  /// List of Release SHA256 keys
  final List<String> sha256;

  AndroidInfo({
    required this.sha256,
    required this.playStoreURL,
    required this.applicationId,
  }) {
    if (applicationId.trim().isEmpty) throw Exception('applicationId required');
  }

  /// Map representation of the model
  Map<String, dynamic> toMap() {
    return {
      ApiKeys.sha256: sha256,
      ApiKeys.playStoreURL: playStoreURL,
      ApiKeys.applicationId: applicationId,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AndroidInfo &&
        _compareLists(sha256, other.sha256) &&
        other.playStoreURL == playStoreURL &&
        other.applicationId == applicationId;
  }

  @override
  int get hashCode =>
      _listHashCode(sha256) ^ playStoreURL.hashCode ^ applicationId.hashCode;

  /// Helper method to compare two lists irrespective of their order
  bool _compareLists(List<String> list1, List<String> list2) {
    if (list1.length != list2.length) return false;

    // Sort both lists and then compare them
    List<String> sortedList1 = List.from(list1)..sort();
    List<String> sortedList2 = List.from(list2)..sort();

    for (int i = 0; i < sortedList1.length; i++) {
      if (sortedList1[i] != sortedList2[i]) {
        return false;
      }
    }

    return true;
  }

  /// Helper method to compute hashCode for a list
  int _listHashCode(List<String> list) {
    list.sort();
    return list.fold(0, (a, b) => a ^ b.hashCode);
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

  IOSInfo({
    required this.teamId,
    required this.bundleId,
    required this.appStoreURL,
  }) {
    if (bundleId.trim().isEmpty) throw Exception('bundleId required');
  }

  /// Map representation of the model
  Map<String, dynamic> toMap() {
    return {
      ApiKeys.teamId: teamId,
      ApiKeys.bundleId: bundleId,
      ApiKeys.appStoreURL: appStoreURL,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is IOSInfo &&
        other.teamId == teamId &&
        other.bundleId == bundleId &&
        other.appStoreURL == appStoreURL;
  }

  @override
  int get hashCode =>
      teamId.hashCode ^ bundleId.hashCode ^ appStoreURL.hashCode;
}
