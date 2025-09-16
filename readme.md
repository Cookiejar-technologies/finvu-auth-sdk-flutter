# Finvu Auth SDK — Flutter

The Finvu Auth SDK for Flutter is a headless authentication solution that provides seamless integration with Finvu's authentication services.

## 📝 Overview

The SDK offers two integration approaches:
1. **WebView Integration**: Embed your web authentication flow using Flutter WebView
2. **Native UI Integration**: Build custom native UIs using the SDK's Dart APIs

Being headless by design, the SDK gives you complete control over the UI implementation while handling all the complex authentication logic internally. It provides built-in support for Silent Network Authentication (SNA), allowing for a seamless authentication experience when conditions are met.

## ✨ Features

- 🎯 **Headless Design**: Full control over UI implementation
- 🌐 **Dual Integration Options**: WebView or Native UI
- 🔄 **Silent Authentication**: Automatic SIM-based authentication
- 📱 **Cross-Platform**: iOS and Android support
- 🚀 **Flutter Compatible**: Works with latest Flutter versions

## 🛠 Development Setup

### Prerequisites

- Flutter (Latest stable version)
- [Android Studio](https://developer.android.com/studio) (for Android development)
- [Xcode](https://apps.apple.com/us/app/xcode/id497799835) (for iOS development)
- A physical device or emulator for testing

## 📦 Package Information

```markdown
Package:     finvu_auth_sdk_flutter
Platforms:   iOS 16.0+ · Android API 25+ (7.1)
Flutter:     3.0+ (tested on latest)
Dependencies: webview_flutter* (for WebView integration)

* Required only for WebView integration
```

---

## 📋 Requirements

* **Flutter**: Latest stable version
* **iOS**: 16.0+, Xcode 14+
* **Android**: API 25+
* **WebView**: `webview_flutter` package

---

## 📦 Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  finvu_auth_sdk_flutter: ^latest_version
  webview_flutter: ^latest_version  # Required only for WebView integration
```

Then run:
```bash
flutter pub get
```

> Note: latest flutter-sdk-version is 1.0.0

### Platform Setup

#### Android Configuration

1. Add GitHub Packages Repository — add to your project-level `build.gradle` or `settings.gradle.kts`:

```gradle
maven {
    url = uri("https://maven.pkg.github.com/Cookiejar-technologies/finvu-auth-sdk-android")
    credentials {
        username = project.findProperty("gpr.user") as String? ?: System.getenv("USERNAME")
        password = project.findProperty("gpr.key") as String? ?: System.getenv("TOKEN")
    }
}
```

2. Add GitHub Credentials — create or edit `~/.gradle/gradle.properties` (do not commit this file):

```properties
gpr.user=YOUR_GITHUB_USERNAME
gpr.key=YOUR_GITHUB_PAT
```

> To create a GitHub Personal Access Token (PAT):
> 1. Visit GitHub's Token Settings
> 2. Generate a new token with `read:packages` scope
> 3. Copy and save the token securely

3. Configure Network Security — add to your `AndroidManifest.xml` inside the `<application>` tag:

```xml
<application
    ...
    android:networkSecurityConfig="@xml/finvu_silent_network_authentication_network_security_config"
    ... >
</application>
```

> This configuration is required for Silent Network Authentication (SNA). [Learn more about SNA configuration](https://docs.google.com/document/d/1TQndJJ1IvKAEt5aZxJE-EL156-Zw3e2RfhS7K-NgXHk/edit?usp=sharing).

After setup on Android: Gradle sync will pick it up.

#### iOS Configuration

1. Update your `Podfile`:

```ruby
# Set minimum iOS version
platform :ios, '16.0'
    
# Add Finvu SDK dependency
pod 'FinvuAuthenticationSDK', :git => 'https://github.com/Cookiejar-technologies/finvu-auth-sdk-ios.git', :tag => 'latest-ios-sdk-version'
```

> Note: latest-ios-sdk-version is 1.0.1

2. Install pods:

```bash
cd ios && pod install --repo-update
```

3. Configure `Info.plist` — add the following to enable Silent Network Authentication:

```xml
<key>NSAllowsArbitraryLoads</key>
<true/>
<key>NSExceptionDomains</key>
<dict>
    <key>80.in.safr.sekuramobile.com</key>
    <dict>
        <key>NSIncludesSubdomains</key>
        <true/>
        <key>NSTemporaryExceptionAllowsInsecureHTTPLoads</key>
        <true/>
        <key>NSTemporaryExceptionMinimumTLSVersion</key>
        <string>TLSv1.1</string>
    </dict>
    <key>partnerapi.jio.com</key>
    <dict>
        <key>NSIncludesSubdomains</key>
        <true/>
        <key>NSTemporaryExceptionAllowsInsecureHTTPLoads</key>
        <true/>
        <key>NSTemporaryExceptionMinimumTLSVersion</key>
        <string>TLSv1.1</string>
    </dict>
</dict>
```

> This configuration is required for Silent Network Authentication (SNA). [Learn more about SNA configuration](https://docs.google.com/document/d/1TQndJJ1IvKAEt5aZxJE-EL156-Zw3e2RfhS7K-NgXHk/edit?usp=sharing).

After setup:

* iOS: `cd ios && pod install`
* Android: Gradle sync will pick it up

---

## 🧭 Code Guidelines

### 1. 🚫 Avoid Third-Party Imports in Authentication Flow

```dart
// ❌ Avoid mixing unrelated logic in auth widgets
@override
void initState() {
  super.initState();
  // ThirdPartyAnalytics.track('auth_started'); // ❌ Not allowed
  // UnrelatedService.fetch();                   // ❌ Not allowed
  // ✅ Only authentication setup here (e.g., create wrapper, set env, register WebView)
}
```

### 2. 🔐 Do Not Store Sensitive Data in Local Storage

```dart
// ❌ Do not persist sensitive data
// await SharedPreferences.getInstance()
//   ..setString('auth_token', token);

// ✅ Pass upwards via state/navigation
navigatorKey.currentState?.pushNamed('/home', arguments: token);
```

### 3. 🧹 Clean Data and Instances at End of Authentication Journey

```dart
@override
void dispose() {
  // Reset any temporary state you keep locally
  // phoneNumberController.clear();
  try {
    // Call cleanup on the wrapper you're using
    native.cleanupAll(); // or: wrapper.cleanupAll()
  } catch (_) {}
  super.dispose();
}
```

### 4. 🔁 Avoid Redundant Authentication Method Calls

```dart
bool isAuthInProgress = false;

Future<void> startAuthOnce() async {
  if (isAuthInProgress) return;
  isAuthInProgress = true;
  try {
    await startAuth(); // your method that calls SDK
  } finally {
    isAuthInProgress = false;
  }
}
```

### 5. 📲 Cleanup When User Exits Authentication Journey

```dart
@override
void deactivate() {
  // Called when widget is removed from the tree (e.g., navigating back)
  try {
    // Call cleanup on the wrapper you're using
    native.cleanupAll(); // or: wrapper.cleanupAll()
  } catch (_) {}
  super.deactivate();
}
```

---

## 🚀 Usage

### 1. WebView Integration

1. Create a `WebViewController` and set JavaScript mode.
2. Create a wrapper via `FinvuAuthSdk.webViewBridge()`.
3. Call `setupWebView(env, controller)` to register the bridge and channel.
4. Load your web app URL.
5. Ensure your web page includes the bridge polyfill (see WebView/JavaScript API below).
6. Call `cleanupAll()` on dispose.

```dart
import 'package:finvu_auth_sdk_flutter/finvu_auth_sdk.dart';
import 'package:webview_flutter/webview_flutter.dart';

late final WebViewController controller;
late final IFinvuWebViewWrapper wrapper;

@override
void initState() {
  super.initState();
  controller = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted);
  wrapper = FinvuAuthSdk.webViewBridge();
  _init();
}

Future<void> _init() async {
  await wrapper.setupWebView(
    env: Environment.development,
    controller: controller,
  );
  await controller.loadRequest(Uri.parse('https://your-web-app'));
}

@override
void dispose() {
  wrapper.cleanupAll();
  super.dispose();
}
```

> The web page loaded in the WebView must include the bridge polyfill. See the WebView/JavaScript API section for the code.

### 2. Native UI Integration

1. Create a wrapper via `FinvuAuthSdk.nativeWrapper()`.
2. Set environment using `setEnvironment(Environment.development)`.
3. Initialize with `initAuth(InitConfig)`.
4. Start authentication with `startAuth(phoneNumber)`.
5. Handle success/error responses.
6. Call `cleanupAll()` on dispose and when user exits the flow.

```dart
import 'package:finvu_auth_sdk_flutter/finvu_auth_sdk.dart';

late final IFinvuNativeWrapper native = FinvuAuthSdk.nativeWrapper();

@override
void initState() {
  super.initState();
  native.setEnvironment(Environment.development);
}

Future<bool> initializeSDK() async {
  final init = await native.initAuth(
    InitConfig(
      appId: 'YOUR_APP_ID', // will be given in logingOtp response as authMeta object's property,
      requestId: 'REQUEST_ID', // will be given in logingOtp response as authMeta object's property,
    ),
  );
  return init.status == FinvuStatus.success;
}

Future<void> startAuthentication(String phoneNumber) async {
  final res = await native.startAuth(phoneNumber);
  if (res.status == FinvuStatus.failure) {
    // handle error in res.error
    return;
  }
  // use res.data?.token
}

@override
void dispose() {
  native.cleanupAll();
  super.dispose();
}
```

## Environment Configuration

The SDK provides two environment configurations:

```dart
// Development: Use during development for verbose logs
finvuAuth.setEnvironment(Environment.development); or 
await wrapper.setupWebView(
    env: Environment.development,
    controller: controller,
  ); // for webview setup

// Production: Use for release builds
finvuAuth.setEnvironment(Environment.production); or 
await wrapper.setupWebView(
    env: Environment.production,
    controller: controller,
  ); // for webview setup
```

> Always use `Environment.development` while building and debugging. Switch to `Environment.production` for release.

---

## 🌐 WebView/JavaScript API

### Bridge Polyfill Setup

Add this minimal Flutter-only bridge to your web app. It posts messages to the Flutter JavaScript channel named `finvu_authentication_bridge`:

```javascript
// Finvu bridge for Flutter WebView (Flutter JSChannel only)
(function () {
  if (typeof window === "undefined") return;
  var CH = "finvu_authentication_bridge";

  if (!window.finvuHelpers) window.finvuHelpers = {};

  function send(msg) {
    try {
      var asString = JSON.stringify(msg);
      var flutterChan = window[CH];
      if (flutterChan && typeof flutterChan.postMessage === "function") {
        flutterChan.postMessage(asString);
        return;
      }
      console.warn("[Finvu] Flutter JSChannel not available");
    } catch (e) {
      console.error("[Finvu] send error", e);
    }
  }

  function attachHelpers(target) {
    if (typeof target.initAuth !== "function") {
      target.initAuth = function (initConfig, callback) {
        send({ method: "initAuth", initConfig: initConfig, callback: callback });
      };
    }
    if (typeof target.startAuth !== "function") {
      target.startAuth = function (phoneNumber, callback) {
        send({ method: "startAuth", phoneNumber: phoneNumber, callback: callback });
      };
    }
    if (typeof target.verifyOtp !== "function") {
      target.verifyOtp = function (phoneNumber, otp, callback) {
        send({ method: "verifyOtp", phoneNumber: phoneNumber, otp: otp, callback: callback });
      };
    }
  }

  attachHelpers(window.finvuHelpers);
})();
```

### Response Handlers Setup

Setup response handlers to receive callbacks from the native SDK (Flutter will invoke these with stringified JSON):

```javascript
// react example of web code for communicating to native flutter channel.
import { useState, useEffect } from "react";

function AuthenticationComponent() {
  const [status, setStatus] = useState("");
  
  useEffect(() => {
    // Init Auth Response Handler
    window.handleInitAuthResponse = (response) => {
      try {
        const data = JSON.parse(response);
        if (data && data.error) {
          console.error('Init Auth Error:', data.error);
          setStatus(`Init Failed: ${data.error.errorMessage || ''}`);
        } else {
          console.log('Init Success:', data);
          setStatus('Initialized');
        }
      } catch (error) {
        console.error('Init Parse Error:', error);
      }
    };

    // Start Auth Response Handler
    window.handleStartAuthResponse = (response) => {
      try {
        const data = JSON.parse(response);
        if (data && data.error) {
          console.error('Auth Error:', data.error);
          setStatus(`Auth Failed: ${data.error.errorMessage || ''}`);
        } else {
          console.log('Auth Success:', data);
          setStatus(`Authenticated: ${data.token || ''}`);
        }
      } catch (error) {
        console.error('Auth Parse Error:', error);
      }
    };

    // Verify OTP Response Handler (optional)
    window.handleVerifyOtpResponse = (response) => {
      try {
        const data = JSON.parse(response);
        if (data && data.error) {
          console.error('Verify OTP Error:', data.error);
          setStatus(`Verify OTP Failed: ${data.error.errorMessage || ''}`);
        } else {
          console.log('Verify OTP Success:', data);
          setStatus('OTP Verified');
        }
      } catch (error) {
        console.error('Verify OTP Parse Error:', error);
      }
    };

    // Cleanup handlers on unmount
    return () => {
      delete window.handleInitAuthResponse;
      delete window.handleStartAuthResponse;
      delete window.handleVerifyOtpResponse;
    };
  }, []);

  return <div>{status}</div>;
}
```

### Using the Bridge in web app

Example usage with the helpers in web app (works across Flutter/React Native):

```javascript
function AuthenticationFlow() {
  const startAuthentication = () => {
    try {
      // 1. Initialize SDK
      const initConfig = {
        appId: "YOUR_APP_ID",
        requestId: "REQUEST_ID"
      };
      window.finvuHelpers.initAuth(
        JSON.stringify(initConfig),
        "handleInitAuthResponse"
      );
    } catch (error) {
      console.error("Init failed:", error);
    }
  };

  const handlePhoneSubmit = (phoneNumber) => {
    try {
      // 2. Start authentication
      window.finvuHelpers.startAuth(
        String(phoneNumber || ''),
        "handleStartAuthResponse"
      );
    } catch (error) {
      console.error("Auth failed:", error);
    }
  };

  return (
    <div>
      <button onClick={startAuthentication}>
        Initialize SDK
      </button>
      <input 
        type="tel" 
        onChange={(e) => handlePhoneSubmit(e.target.value)} 
      />
    </div>
  );
}
```

### Bridge Communication Flow

1. Message Format
   - All messages must be stringified JSON
   - Each method call requires a callback function name
   - Responses are delivered to the registered global callback functions

2. Bridge Detection
   - The polyfill checks for multiple runtimes: Flutter JSChannel, RN WebView, iOS WKWebView, Android @JavascriptInterface
   - Prefers `window.finvu_authentication_bridge.postMessage` for Flutter
   - Falls back gracefully with a console warning if no native bridge is available

3. Response Handling
   - All responses are received as stringified JSON
   - Success response format: `{ status: 'SUCCESS', token?, ... }`
   - Error response format: `{ error: { status: 'FAILURE', errorCode?, errorMessage? } }`
   - Always use try-catch when parsing responses

4. Cleanup
   - Remove response handlers when component unmounts
   - Clear any auth-related state
   - Handle error cases appropriately

---

## 📤 Types Reference

```dart
enum Environment { production, development }

enum FinvuStatus { success, failure }

class FinvuAuthSuccess {
  final String? token;
  final String? authType;
  final Map<String, Object?> extra;
  FinvuAuthSuccess({this.token, this.authType, this.extra = const {}});
}

class FinvuAuthFailure {
  final String? errorCode;
  final String? errorMessage;
  final Map<String, Object?> details;
  FinvuAuthFailure({this.errorCode, this.errorMessage, this.details = const {}});
}

class FinvuAuthResult {
  final FinvuStatus status;
  final FinvuAuthSuccess? data;
  final FinvuAuthFailure? error;
  FinvuAuthResult({required this.status, this.data, this.error});
}

class InitConfig {
  final String appId;
  final String requestId;
  InitConfig({required this.appId, required this.requestId});
}
```

### Status Types

| Status  | Description                     | Next Action              |
|---------|---------------------------------|--------------------------|
| SUCCESS | Authentication successful        | Use token for API calls  |
| FAILURE | Authentication failed           | Handle error, retry      |

### Error Codes

| Code | Meaning            | Common Causes                           |
|------|--------------------|-----------------------------------------|
| 1001 | Invalid parameter  | Missing appId/requestId, bad phone/OTP  |
| 1002 | Generic failure    | Network issues, SNA failure             |

---

## ❓ FAQ & Troubleshooting

### Silent Network Authentication (SNA)

For SNA to work properly:
- Mobile data enabled (SIM internet ON)
- WiFi disabled
- SIM supports required network protocols
- Active mobile network connectivity

### Common Issues

1. **Android Setup**
   - Verify networkSecurityConfig is added to `AndroidManifest.xml`
   - Ensure the XML file exists under `res/xml/`
   - Run `flutter clean` after setup changes

2. **iOS Setup**
   - Run `pod install --repo-update` after changes
   - Verify ATS exceptions in `Info.plist`
   - Ensure minimum iOS 16.0 deployment target

3. **WebView Integration**
   - Confirm JS channel name matches: `finvu_authentication_bridge`
   - Ensure JavaScript is enabled in the WebView
   - Test with `Environment.development` for verbose logs

4. **Flutter Specific**
   - Clear build cache: `flutter clean`
   - Reinstall deps: `flutter pub get`
   - Re-run app: `flutter run`

### Error 1001 Checklist
- Verify appId and requestId are provided
- Check phone number format (10 digits, no leading zero)
- Ensure all parameters are strings

### Error 1002 Troubleshooting
1. Check network connectivity
2. Verify SIM card status
3. Toggle mobile data
4. Check service availability

---

Need help? Contact support@cookiejar.co
