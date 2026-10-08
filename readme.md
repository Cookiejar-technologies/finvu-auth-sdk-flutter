# Finvu Auth SDK — Flutter

**Package:** `finvu_authentication_sdk`  
**Version:** `1.0.3` · **Flutter:** 3.32+ · **iOS:** 16.0+ · **Android:** API 25+

Silent Network Authentication (SNA) and device binding SDK for Flutter, with WebView bridge support for web-based authentication flows.

> SNA verifies the number over the carrier's mobile data connection, so it requires **mobile data ON** and **Wi-Fi OFF**. If those conditions are not met, the flow falls back to OTP automatically.

---

## Installation

```bash
flutter pub add finvu_authentication_sdk
```

Add `webview_flutter` as well if you use the WebView integration:

```bash
flutter pub add webview_flutter
```

No additional native configuration is needed — the plugin is autolinked, and the native binaries are fetched at build time (Maven Central on Android, the iOS xcframework via the podspec).

---

## Platform Setup

### Android

#### 1. Internet & Network Permissions

Add to your `AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
<uses-permission android:name="android.permission.CHANGE_NETWORK_STATE" />
```

#### 2. Network Security Config

Add to your `<application>` tag in `AndroidManifest.xml`:

```xml
<application
    android:networkSecurityConfig="@xml/finvu_silent_network_authentication_network_security_config"
    ...>
</application>
```

> Required for Silent Network Authentication (SNA) to make carrier-specific HTTP calls. The config file ships inside the SDK — you only reference it.

#### 3. FlutterFragmentActivity (device binding)

Device binding shows the system device-lock prompt, which needs a `FragmentActivity`. Make your `MainActivity` extend `FlutterFragmentActivity` instead of `FlutterActivity`:

```kotlin
import io.flutter.embedding.android.FlutterFragmentActivity

class MainActivity : FlutterFragmentActivity()
```

---

### iOS

Run pod install after `flutter pub get`:

```bash
cd ios && pod install --repo-update
```

> **Minimum deployment target is iOS 16.0.** Set `platform :ios, '16.0'` in your `Podfile` and match it under "Minimum Deployments" in Xcode, otherwise `pod install` fails to resolve the SDK.

#### Info.plist — Network Security

Add the following to your `Info.plist`:

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSExceptionDomains</key>
    <dict>
        <key>80.in.safr.sekuramobile.com</key>
        <dict>
            <key>NSExceptionAllowsInsecureHTTPLoads</key><true/>
            <key>NSIncludesSubdomains</key><true/>
        </dict>
        <key>api-csp.airtel.in</key>
        <dict>
            <key>NSExceptionAllowsInsecureHTTPLoads</key><true/>
            <key>NSIncludesSubdomains</key><true/>
        </dict>
        <key>in-vil.ipification.com</key>
        <dict>
            <key>NSExceptionAllowsInsecureHTTPLoads</key><true/>
            <key>NSIncludesSubdomains</key><true/>
        </dict>
        <key>partnerapi.jio.com</key>
        <dict>
            <key>NSExceptionAllowsInsecureHTTPLoads</key><true/>
            <key>NSIncludesSubdomains</key><true/>
        </dict>
    </dict>
</dict>
```

#### Info.plist — Face ID (device binding)

Device binding confirms the user with Face ID, Touch ID or the device passcode. Add a usage description to your `Info.plist`:

```xml
<key>NSFaceIDUsageDescription</key>
<string>Confirms it is you before signing in with this device.</string>
```

---

## Integration

### Option A — WebView App

Use this if your app loads a web page inside a Flutter `WebView` and the web app drives the authentication flow.

```dart
import 'package:finvu_authentication_sdk/finvu_authentication_sdk.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  late final WebViewController _controller;
  late final IFinvuWebViewWrapper _wrapper;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted);
    _wrapper = FinvuAuthSdk.webViewBridge();
    _setup();
  }

  Future<void> _setup() async {
    await _wrapper.setupWebView(
      env: Environment.production, // or Environment.development
      controller: _controller,
    );
    await _controller.loadRequest(Uri.parse('https://your-web-app-url'));
  }

  @override
  void dispose() {
    _wrapper.cleanupAll();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(controller: _controller);
  }
}
```

Your web app communicates with the SDK through the `finvu_authentication_bridge` JS channel. Flutter's channel only exposes `postMessage(String)`, so each call goes as a JSON envelope:

```js
window.finvu_authentication_bridge.postMessage(JSON.stringify({
  method: 'startAuth',
  snaLink: snaLink,
  callback: 'handleStartAuthResponse',
}));

// The callback must be a global function on window. It receives a JSON string.
window.handleStartAuthResponse = function (json) {
  const res = JSON.parse(json);
};
```

| `method` | Payload key |
|---|---|
| `initAuth` / `initSNA` | `initConfig` (object or JSON string) |
| `startAuth` / `startSNA` | `snaLink` |
| `getDeviceBindingState`, `enrollDeviceBinding`, `signDeviceBindingChallenge` | `config` (object or JSON string, passed to the native SDK unchanged) |
| `getCapabilities` | none |

Call `setupWebView` before `loadRequest`, so the channel exists when the page loads. An unknown `method` gets an `UNSUPPORTED_METHOD` failure.

---

### Option B — Native App

Use this if your app handles the authentication flow entirely in Dart, without a WebView.

```dart
import 'package:finvu_authentication_sdk/finvu_authentication_sdk.dart';

final native = FinvuAuthSdk.nativeWrapper();

// 1. Setup — call once
await native.setEnvironment(Environment.production);

// 2. Init — call with requestId from your backend
final initResult = await native.initAuth(
  const InitConfig(requestId: 'YOUR_REQUEST_ID'),
);

// 3. Start SNA — call with the SNA URL returned by your backend
final authResult = await native.startAuth('SNA_URL');
if (authResult['status'] == 'FAILURE') {
  print('${authResult['errorCode']}: ${authResult['errorMessage']}');
} else {
  final snaToken = authResult['snaToken'];
}

// 4. Cleanup — call when done or user exits
await native.cleanupAll();
```

Every call returns a `Map<String, dynamic>`: the native Android/iOS SDK's own JSON response, unchanged. Calls don't throw. A failure is `{"status": "FAILURE", "errorCode": ..., "errorMessage": ...}`.

#### Device binding

Each config is a plain map, passed to the native SDK unchanged.

```dart
// Is the key from an earlier enrollment still usable? Local only, no prompt.
final state = await native.getDeviceBindingState({'keyId': savedKeyId});
// state['state']: NOT_ENROLLED, ENROLLED, INVALIDATED, UNSUPPORTED or NO_SCREEN_LOCK

// Prompt for the device lock and create a key pair.
// Store enrolled['keyId'] and enrolled['publicKey'] on your backend.
final enrolled = await native.enrollDeviceBinding({
  'requestId': requestId,
  'attestationChallenge': serverNonce, // optional, used on Android only
});

// Prompt for the device lock and sign a server-issued challenge
// with whichever of the user's keys exists on this device.
final signed = await native.signDeviceBindingChallenge({
  'allowedKeyIds': [savedKeyId],
  'challenge': serverChallenge,
  'requestId': requestId,
});
// Send signed['keyId'] and signed['signature'] to your backend to verify.

// What this installed SDK build supports.
final caps = await native.getCapabilities();
```

`enrollDeviceBinding` and `signDeviceBindingChallenge` also accept `entityId`, `promptTitle` and `promptSubtitle`.

---

## Upgrading from 1.0.2

- Failures now come back flat as `{"status": "FAILURE", "errorCode", "errorMessage"}` instead of `{"error": {...}}`. Check `result['status'] == 'FAILURE'`.
- For device binding, add `FlutterFragmentActivity` on Android and `NSFaceIDUsageDescription` on iOS (see Platform Setup).
- The native SDKs are now Android `1.1.4` and iOS `1.1.3`. Run `cd ios && pod install --repo-update` after upgrading.

## Demo App

See [`demo_app/`](./demo_app) for a complete working Flutter example that consumes the published package from pub.dev.

## Support

support@cookiejar.co.in · [finvu.in](https://finvu.in)
