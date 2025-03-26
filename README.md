# **Flutter Braintree Payment Plugin**

This Flutter plugin integrates **Braintree** payments into your Flutter app. It allows you to
initiate payments via Venmo and PayPal using **Braintree SDK** for both Android and iOS platforms.

## **Features**

- Venmo and Paypal payments via **Braintree SDK**.
- Easy integration with **Flutter**.
- Supports both **Android** and **iOS** platforms.

## Installation

1. **Add Dependency:** Add the `braintree_payment` package to your `pubspec.yaml` file:

   ```yaml
   dependencies:
     flutter:
       sdk: flutter
     braintree_payment: <latest_version> # Replace <latest_version> with the current version
   ```

2. **Install Packages:** Run `flutter pub get` in your terminal.

## Platform-Specific Setup

### Android Integration

**Add Activities to `AndroidManifest.xml`:** Declare the required Braintree activities in your
`android/app/src/main/AndroidManifest.xml` file:

    ```xml
    <activity android:exported="true" android:name="com.braintree.payment.PayPalActivity"/>
    <activity android:exported="true" android:name="com.braintree.payment.VenmoActivity"/>
    ```

### iOS Integration

1. **Configure URL Schemes in `Info.plist`:** Add URL schemes to your `ios/Runner/Info.plist` file
   for Braintree and your app:

   ```xml
   <key>CFBundleURLTypes</key>
   <array>
       <dict>
           <key>CFBundleTypeRole</key>
           <string>Editor</string>
           <key>CFBundleURLSchemes</key>
           <array>
               <string>your.bundle.id.payments</string> </array>
       </dict>
   </array>
   <key>LSApplicationQueriesSchemes</key>
   <array>
       <string>com.venmo.touch.v2</string> </array>
   ```

   Replace `your.bundle.id` with your app's actual bundle identifier.

2. **Handle Payment Redirect in `AppDelegate.swift`:** Modify your `ios/Runner/AppDelegate.swift`
   file to handle the URL scheme callback:

   ```swift
   import Flutter
   import Braintree

   @main
   @objc class AppDelegate: FlutterAppDelegate {
       override func application(
           _ application: UIApplication,
           didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
       ) -> Bool {
           BTAppContextSwitcher.sharedInstance.returnURLScheme = "\(Bundle.main.bundleIdentifier ?? "").payments"
           GeneratedPluginRegistrant.register(with: self)
           return super.application(application, didFinishLaunchingWithOptions: launchOptions)
       }
   }
   ```
   

## Usage

1. **Import the Package:**

   ```dart
   import 'package:braintree_payment/braintree_payment.dart';
   import 'package:package_info_plus/package_info_plus.dart';
   ```

2. **Initialize and Process Payments:**

   **Venmo Payment:**

   ```dart
   final BraintreePayment braintreePayment = BraintreePayment();
   final String token = "YOUR_BRAINTREE_CLIENT_TOKEN"; // Replace with your Braintree client token
   final PackageInfo packageInfo = await PackageInfo.fromPlatform();

   try {
     final VenmoResult? result = await braintreePayment.venmoPayment(
       VenmoRequest(
         token: token,
         amount: "10.00",
         displayName: "My Store",
         appLinkReturnUrl: packageInfo.packageName,
         deepLinkFallbackUrlScheme: packageInfo.packageName,
       ),
     );

     if (result != null && result.status == VenmoPaymentStatus.success) {
       print("Venmo Payment Success: ${result.nonce}");
       // Process the payment with your backend using the nonce
     } else {
       print("Venmo Payment Failed or Cancelled: ${result?.status}");
     }
   } catch (e) {
     print("Error during Venmo Payment: $e");
   }
   ```

   **PayPal Payment:**

   ```dart
   final BraintreePayment braintreePayment = BraintreePayment();
   final String token = "YOUR_BRAINTREE_CLIENT_TOKEN"; // Replace with your Braintree client token
   final PackageInfo packageInfo = await PackageInfo.fromPlatform();

   try {
       final PayPalResult? result = await braintreePayment.paypalPayment(
           PayPalRequest(
               token: token,
               amount: "10",
               displayName: "My Store",
               billingAgreementDescription: "Payment Description",
               appLinkReturnUrl: packageInfo.packageName,
               deepLinkFallbackUrlScheme: packageInfo.packageName,
           ),
       );

       if (result != null && result.status == PayPalPaymentStatus.success) {
           print("PayPal Payment Success: ${result.nonce}");
           // Process the payment with your backend using the nonce
       } else {
           print("PayPal Payment Failed or Cancelled: ${result?.status}");
       }
   } catch (e) {
       print("Error during PayPal Payment: $e");
   }

   ```

   **Important:** Replace `"YOUR_BRAINTREE_CLIENT_TOKEN"` with your actual Braintree client token.

## License

This plugin is released under the MIT License. See the `LICENSE` file for more details.