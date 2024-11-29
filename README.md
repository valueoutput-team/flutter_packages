# DeepLynks

A Flutter package for implementing deep links. It facilitates seamless redirection to the Play Store or App Store for app downloads if the app isn't installed. Otherwise, it opens the app directly and remembers the link throughout the installation process.

---

## Features

- **Deferred Deep Links**: Track clicked links across installation.
- **Easy Setup**: Quick integration with minimal configuration.
- **Platform Support**: App links for Android and universal links for iOS (optional but recommended).
- **Free to Use**: Open-source and free.

---

## Installation

1. Add this package to your `pubspec.yaml`:

   ```yaml
   dependencies:
     deeplynks: <latest_version>
   ```

2. Run `flutter pub get` to install the package.

---

## Usage

### 1. Initialize DeepLynks Service

Initialize the service at the start of your app. This generates a unique app ID that persists unless the application ID or bundle ID changes.

```dart
final appId = await DeeplynksService().init(
  context: context,
  androidInfo: const AndroidInfo(
    sha256: [],
    playStoreURL: '',
    applicationId: 'com.example.deeplynks',
  ),
  iosInfo: const IOSInfo(
    teamId: '',
    appStoreURL: '',
    bundleId: 'com.example.deeplynks',
  ),
);
print(appId);
```

#### Arguments

| **Argument**                | **Type**       | **Description**                                     |
| --------------------------- | -------------- | --------------------------------------------------- |
| `context`                   | `BuildContext` | The build context.                                  |
| `androidInfo`               | `AndroidInfo`  | Android-specific configuration.                     |
| `androidInfo.sha256`        | `List<String>` | List of release SHA-256 keys for Android App Links. |
| `androidInfo.playStoreURL`  | `String`       | The Play Store URL for your app.                    |
| `androidInfo.applicationId` | `String`       | The application ID (package name) of your app.      |
| `iosInfo`                   | `IOSInfo`      | iOS-specific configuration.                         |
| `iosInfo.teamId`            | `String`       | Your Apple Developer Team ID.                       |
| `iosInfo.appStoreURL`       | `String`       | The App Store URL for your app.                     |
| `iosInfo.bundleId`          | `String`       | The bundle ID of your app.                          |

### 2. Listen to incoming deep link data

```dart
DeeplynksService().stream.listen((data) {
    print(data);
});
```

### 3. Create a Deep Link

Generate a deep link with your custom data, which can include absolute URLs, relative URLs, query parameters, JSON objects, plain text, or any other format you want to retrieve later.

```dart
final link = await DeeplynksService().createLink(jsonEncode({
  'referredBy': '12345',
  'referralCode': 'WELCOME50',
}));
print('Generated link: $link');
```

### 3. Mark Link Data as Used

Mark the link data as completed to prevent future triggers.

```dart
DeeplynksService().markCompleted();
```

---

## Platform Setup

### Android

1. Open `android/app/src/main/AndroidManifest.xml`.
2. Add the following `<meta-data>` tag and `<intent-filter>` inside the `<activity>` tag with `.MainActivity`.
   Replace `<app_id>` with the unique app ID generated during the first `DeepLynksService.init()` call.

```xml
<meta-data android:name="flutter_deeplinking_enabled" android:value="true" />
<intent-filter android:autoVerify="true">
  <action android:name="android.intent.action.VIEW" />
  <category android:name="android.intent.category.DEFAULT" />
  <category android:name="android.intent.category.BROWSABLE" />
  <data android:scheme="https"
  android:host="deeplynks.web.app"
  android:pathPrefix="/<app_id>/" />
</intent-filter>
```

3. Update `MainActivity` to handle deep links:

#### Java

```java
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "app.web.deeplynks";
    private String initialLink = null;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        Intent intent = getIntent();
        if (Intent.ACTION_VIEW.equals(intent.getAction())) {
            Uri data = intent.getData();
            if (data != null) {
                initialLink = data.toString();
            }
        }
    }

    @Override
    public void configureFlutterEngine(FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
            .setMethodCallHandler((call, result) -> {
                if (call.method.equals("getInitialLink")) {
                    result.success(initialLink);
                    initialLink = null;
                } else {
                    result.notImplemented();
                }
            });
    }

    @Override
    protected void onNewIntent(Intent intent) {
        super.onNewIntent(intent);
        if (Intent.ACTION_VIEW.equals(intent.getAction())) {
            Uri data = intent.getData();
            if (data != null) {
                new MethodChannel(getFlutterEngine().getDartExecutor().getBinaryMessenger(), CHANNEL)
                    .invokeMethod("onLink", data.toString());
            }
        }
    }
}
```

#### Kotlin

```kotlin
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "app.web.deeplynks"
    private var initialLink: String? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        intent?.let {
            if (Intent.ACTION_VIEW == it.action) {
                initialLink = it.data.toString()
            }
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "onLink") {
                result.success(initialLink)
                initialLink = null
            } else {
                result.notImplemented()
            }
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        intent.data?.let {
            MethodChannel(flutterEngine?.dartExecutor?.binaryMessenger, CHANNEL).invokeMethod("onLink", it.toString())
        }
    }
}
```

---

### iOS

#### 1. Open the iOS Project

1. Navigate to the `ios` folder of your Flutter project.
2. Open the `Runner.xcworkspace` file in Xcode.

#### 2. Add `FlutterDeepLinkingEnabled` Key in `Info.plist`

1. Open `Info.plist` in Xcode.
2. Add the following key-value pair:
   ```xml
   <key>FlutterDeepLinkingEnabled</key>
   <true/>
   ```

#### 3. Add Associated Domains

1. In Xcode, select the top-level `Runner` project in the Navigator.
2. Go to the **Signing & Capabilities** tab.
3. Click the **+ Capability** button.
4. Select **Associated Domains**.
5. In the **Associated Domains** section, click the **+** button.
6. Add the domain: `applinks:deeplynks.web.app`.

#### 4. Update `AppDelegate.swift`

Modify `AppDelegate.swift` to handle incoming deep links:

```swift
import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        continue userActivity: NSUserActivity,
        restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
    ) -> Bool {
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb,
           let url = userActivity.webpageURL,
           let flutterViewController = window?.rootViewController as? FlutterViewController {
            let channel = FlutterMethodChannel(name: "app.web.deeplynks", binaryMessenger: flutterViewController.binaryMessenger)
            channel.invokeMethod("onLink", arguments: url.absoluteString)
        }
        return true;
    }
}
```

---

## Additional information

Think you've found a bug, or would like to see a new feature? We'd love to hear about it! Visit the [Issues](https://github.com/valueoutput-team/flutter_packages/issues) section of the git repository. DO NOT FORGOT TO MENTION THE PACKAGE NAME "deeplynks" IN THE TITLE.
