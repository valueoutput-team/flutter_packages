import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:pip_mode/pip_mode.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final _controller1 = PipController();
  final _controller2 = PipController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('PiP Demo')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: _controller1.startPipMode,
                child: PipWidget(
                  controller: _controller1,
                  onInitialized: (success) {
                    log('Pip Widget 1 Initialized: $success');
                  },
                  child: Container(
                    width: 200,
                    height: 200,
                    color: Colors.red,
                    alignment: Alignment.center,
                    child: Text('Hello World!'),
                  ),
                ),
              ),
              GestureDetector(
                onTap: _controller2.startPipMode,
                child: PipWidget(
                  controller: _controller2,
                  onInitialized: (success) {
                    log('Pip Widget 2 Initialized: $success');
                  },
                  child: Container(
                    width: 200,
                    height: 200,
                    color: Colors.green,
                    alignment: Alignment.center,
                    child: Text('World Hello!'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
