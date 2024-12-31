import 'package:deeplynks/src/api_constants.dart';

class IpLookupModel {
  final String url;
  final List<String> resPath;

  const IpLookupModel({required this.url, required this.resPath});

  factory IpLookupModel.fromJSON(Map<String, dynamic> data) {
    return IpLookupModel(
      url: data[ApiKeys.url],
      resPath: List<String>.from(data[ApiKeys.resPath] ?? []),
    );
  }
}
