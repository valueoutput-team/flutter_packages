import 'package:deeplynks/models/deeplynks_model.dart';
import 'package:deeplynks/utils/api_constants.dart';

/// AppInfo
class AppModel {
  final String? id;
  final IOSInfo? iosInfo;
  final MetaInfo metaData;
  final AndroidInfo? androidInfo;

  const AppModel({
    this.id,
    this.iosInfo,
    this.androidInfo,
    required this.metaData,
  });

  /// Generate model from JSON
  factory AppModel.fromJSON(Map<String, dynamic> data) {
    return AppModel(
      id: data[ApiKeys.id],
      metaData: MetaInfo(
        name: data[ApiKeys.meta][ApiKeys.name],
        imageURL: data[ApiKeys.meta][ApiKeys.imageURL],
        description: data[ApiKeys.meta][ApiKeys.description],
      ),
      androidInfo: data[ApiKeys.android] == null
          ? null
          : AndroidInfo(
              playStoreURL: data[ApiKeys.android][ApiKeys.playStoreURL],
              applicationId: data[ApiKeys.android][ApiKeys.applicationId],
              sha256: List<String>.from(data[ApiKeys.android][ApiKeys.sha256]),
            ),
      iosInfo: data[ApiKeys.iOS] == null
          ? null
          : IOSInfo(
              teamId: data[ApiKeys.iOS][ApiKeys.teamId],
              bundleId: data[ApiKeys.iOS][ApiKeys.bundleId],
              appStoreURL: data[ApiKeys.iOS][ApiKeys.appStoreURL],
            ),
    );
  }

  /// Map representation of the model
  Map<String, dynamic> toMap() {
    return {
      ApiKeys.id: id,
      ApiKeys.meta: metaData.toMap(),
      if (iosInfo != null) ApiKeys.iOS: iosInfo?.toMap(),
      if (androidInfo != null) ApiKeys.android: androidInfo?.toMap(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    // DO NOT add id check, as initially id will be unknown
    return other is AppModel &&
        other.metaData == metaData &&
        other.iosInfo == iosInfo &&
        other.androidInfo == androidInfo;
  }

  @override
  int get hashCode =>
      metaData.hashCode ^ iosInfo.hashCode ^ androidInfo.hashCode;
}
