import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:free_map/free_map.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  FMData? _selectedValue;
  late final TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Builder(builder: (context) {
        return GestureDetector(
          onTap: FocusScope.of(context).unfocus,
          child: Scaffold(
            appBar: AppBar(title: const Text('Free Map Demo')),
            floatingActionButton: FloatingActionButton(
              onPressed: _getCurrentAddress,
              child: const Icon(Icons.location_searching_rounded),
            ),
            body: Column(
              children: [
                _searchFieldOnly,
                ElevatedButton(
                  onPressed: () => _goToMapWidget(context),
                  child: const Text('Go to Map'),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  /// Use search field only (without map)
  Widget get _searchFieldOnly {
    return FMSearchField(
      initialValue: _selectedValue,
      textController: _textController,
      margin: const EdgeInsets.all(20),
      textFieldBuilder: _searchTextFieldBuilder,
      onSelected: (v) => setState(() => _selectedValue = v),
    );
  }

  /// Create customized search text field
  TextFormField _searchTextFieldBuilder(
    FocusNode focusNode,
    TextEditingController controller,
    Function(String)? onChanged,
  ) {
    return TextFormField(
      focusNode: focusNode,
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        filled: true,
        border: _border,
        errorBorder: _border,
        enabledBorder: _border,
        focusedBorder: _border,
        disabledBorder: _border,
        hintText: 'Search Address',
        focusedErrorBorder: _border,
        fillColor: Colors.grey[100],
      ),
    );
  }

  InputBorder get _border => OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.grey),
      );

  /// go to map widget
  void _goToMapWidget(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) {
        return Scaffold(
          body: SafeArea(
            child: FMWidget(
              initialValue: _selectedValue,
              searchTextFieldBuilder: _searchTextFieldBuilder,
              onSelected: (v) {
                _selectedValue = v;
                Navigator.pop(context);
              },
            ),
          ),
        );
      }),
    );
  }

  /// Get address from coordinates (Reverse geocoding)
  Future<void> _getCurrentAddress() async {
    try {
      // Get current coordinates
      final pos = await FMService().getCurrentPosition();

      // Get address from current coordinates (Reverse geocoding)
      final data = await FMService().getAddress(
        lat: pos.latitude,
        lng: pos.longitude,
      );

      log(data?.address ?? 'Failed to find the address');
    } catch (e) {
      log(e.toString());
    }
  }
}
