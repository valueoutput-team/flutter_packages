import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:deeplynks/deeplynks.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _deeplynks = Deeplynks();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _init());
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Builder(builder: (context) {
        return Scaffold(
          appBar: AppBar(title: const Text('Deeplynks Demo')),
          body: Center(
            child: ElevatedButton(
              onPressed: _createLink,
              child: const Text('Refer'),
            ),
          ),
        );
      }),
    );
  }

  /// Initialize deeplynks & listen for link data
  Future<void> _init() async {
    final appId = await _deeplynks.init(
      context: context,
      metaData: MetaInfo(
        name: 'Deeplynks Demo',
        description:
            'This app is a working demo for showcasing Deeplynks features',
      ),
      androidInfo: AndroidInfo(
        sha256: [],
        playStoreURL: '',
        applicationId: 'com.example.deeplynks',
      ),
      iosInfo: IOSInfo(
        teamId: '',
        appStoreURL: '',
        bundleId: 'com.example.deeplynks',
      ),
    );

    // Use this appId for Android platform setup
    log('Deeplynks App Id: $appId');

    // Listen for link data
    _deeplynks.stream.listen((data) {
      // Handle link data
      log('Deeplynks Data: $data');

      // After using the link data, mark it as completed
      // to prevant it from being processed again
      _deeplynks.markCompleted();
    });
  }

  /// Create a new deep link
  Future<void> _createLink() async {
    final link = await _deeplynks.createLink(jsonEncode({
      'referredBy': '12345',
      'referralCode': 'WELCOME50',
    }));
    log('Deeplynks Link: $link');
  }
}
