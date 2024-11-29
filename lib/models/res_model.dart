import 'dart:convert';

class ResModel {
  final dynamic data;
  final int statusCode;
  final String? message;
  const ResModel({this.data, this.statusCode = 200, this.message});

  factory ResModel.fromJSON(dynamic data, {int? statusCode}) {
    if (data is String) data = jsonDecode(data);
    return ResModel(data: data, statusCode: statusCode ?? 200);
  }

  bool get success => RegExp(r'20\d').hasMatch('$statusCode');
}
