// import 'package:flutter_test/flutter_test.dart';
// import 'package:pip_mode/pip_mode.dart';
// import 'package:pip_mode/pip_mode_platform_interface.dart';
// import 'package:pip_mode/pip_mode_method_channel.dart';
// import 'package:plugin_platform_interface/plugin_platform_interface.dart';

// class MockPipModePlatform
//     with MockPlatformInterfaceMixin
//     implements PipModePlatform {

//   @override
//   Future<String?> getPlatformVersion() => Future.value('42');
// }

// void main() {
//   final PipModePlatform initialPlatform = PipModePlatform.instance;

//   test('$MethodChannelPipMode is the default instance', () {
//     expect(initialPlatform, isInstanceOf<MethodChannelPipMode>());
//   });

//   test('getPlatformVersion', () async {
//     PipMode pipModePlugin = PipMode();
//     MockPipModePlatform fakePlatform = MockPipModePlatform();
//     PipModePlatform.instance = fakePlatform;

//     expect(await pipModePlugin.getPlatformVersion(), '42');
//   });
// }
