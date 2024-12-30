import 'dart:convert';

/// API response data
class ResModel {
  /// response body
  final dynamic data;

  /// status code
  final int statusCode;

  /// response message
  final String? message;

  const ResModel({this.data, this.statusCode = 200, this.message});

  /// Generate model from raw response body
  factory ResModel.fromJSON(dynamic data, {int? statusCode}) {
    try {
      if (data is String) data = jsonDecode(data);
    } catch (e) {
      //
    }
    return ResModel(data: data, statusCode: statusCode ?? 200);
  }

  /// Whether response is a success
  bool get success => RegExp(r'20\d').hasMatch('$statusCode');
}
