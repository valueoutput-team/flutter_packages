The pip_mode plugin allows developers to send any widget into PiP mode, providing a seamless way to keep content visible while users navigate to other apps.

## Features

- **Customizable Content:** Encapsulate any widget and display it in PiP mode.
- **Video Conversion Support:** Automatically converts widgets into a video for PiP.

![pip_mode screenshot](https://github.com/valueoutput-team/flutter_packages/blob/main/assets/images/pip_mode_1.png?raw=true)

## Getting started

### Android

1. Open `android > app > build.gradle` and set `minSDK` to 24 or higher.
2. Enable PiP support for `MainActivity` in `AndroidManifest.xml`.

```xml
<activity
    android:name=".MainActivity"
    ...
    android:supportsPictureInPicture="true"
    ...>
```

### iOS

1. Set minimum deployment target to 12.1 or higher.
2. Open `ios > Runner > Info.plist` and add below lines inside root `<dict>` to add `Background Modes` capability & enable `Audio, Airplay, and Picture`.

```plist
<key>UIBackgroundModes</key>
<array>
	<string>audio</string>
	<string>AirPlay</string>
	<string>picture-in-picture</string>
</array>
```

3. For iOS, test on real device

## Usage

```dart
final _controller = PipController();

GestureDetector(
    onTap: _controller.startPipMode,
    child: PipWidget(
        controller: _controller,
        onInitialized: (success) => log('Pip Widget Initialized: $success'),
        child: Container(
            width: 200,
            height: 200,
            color: Colors.red,
            alignment: Alignment.center,
            child: Text('Hello World!'),
        ),
    ),
),
```

## Additional information

Think you've found a bug, or would like to see a new feature? We'd love to hear about it! Visit the [Issues](https://github.com/valueoutput-team/flutter_packages/issues) section of the git repository.
