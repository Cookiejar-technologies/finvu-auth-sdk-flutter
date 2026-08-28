# Finvu Auth SDK — Flutter

**Package:** `finvu_authentication_sdk`  
**Version:** `1.0.0` · **Flutter:** 3.32+ · **iOS:** 16.0+ · **Android:** API 25+

Silent Network Authentication (SNA) SDK for Flutter, with WebView bridge support for web-based authentication flows.

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

Your web app communicates with the SDK through the `finvu_authentication_bridge` JS channel.

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
// auth complete — use authResult.data?.token

// 4. Cleanup — call when done or user exits
await native.cleanupAll();
```

Calls return a `FinvuAuthResult` rather than throwing: check `status`, then read `data` or `error`.

## Demo App

See [`demo_app/`](./demo_app) for a complete working Flutter example that consumes the published package from pub.dev.

## Support

support@cookiejar.co.in · [finvu.in](https://finvu.in)
