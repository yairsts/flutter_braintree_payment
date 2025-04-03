# **Flutter Braintree Payment Plugin**

This Flutter plugin integrates **Braintree** payments into your Flutter app. It allows you to
initiate payments via Venmo and PayPal using **Braintree SDK** for both Android and iOS platforms.

## Features

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

#### Venmo integration

##### Configure URL Schemes in `Info.plist`: Add this query scheme to your `ios/Runner/Info.plist` file
for Braintree and your app:

   ```xml
   <key>LSApplicationQueriesSchemes</key>
   <array>
       <string>com.venmo.touch.v2</string> 
    </array>
   ```

##### To allow Venmo app redirect to your application, you should configure a universal link.
#### Setting Up Universal Links for iOS

#### 1.1. Set up Associated Domains

##### 1. Open your Xcode project.
##### 2. Go to the Signing & Capabilities tab.
##### 3. Under the Associated Domains section, add the following:
   ```
   applinks:<YOUR_DOMAIN>
   ```
Replace `<YOUR_DOMAIN>` with your Universal Link domain. This domain should match the one you are using for Braintree callbacks.

#### 1.2. Create and Configure the Apple App Site Association (AASA) File

The AASA file is required to associate your app with your website to handle Universal Links. It should be placed on your HTTPS web server at the following path:
```
/.well-known/apple-app-site-association
```

Here's an example AASA file:
```json
{
   "applinks": {
      "details": [
         {
            "appID": "<TEAM_ID>.<BUNDLE_ID>",
            "paths": ["*/braintree_payments*"]
         }
      ]
   }
}
```

- Replace `<TEAM_ID>` with your Apple Developer Team ID.
- Replace `<BUNDLE_ID>` with your app's bundle identifier.
- Ensure that the paths array contains the pattern that matches your Universal Link.

The AASA file must be:
- Served over HTTPS
- Without any redirects
- With the content type of `application/json`

## Usage

#### 1. Import the Package:

   ```dart
   import 'package:braintree_payment/braintree_payment.dart';
import 'package:package_info_plus/package_info_plus.dart';
   ```

#### 2. Initialize and Process Payments:

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
            androidAppLinkReturnUrl: FlavorManager.packageName,
            androidDeepLinkFallbackUrlScheme: FlavorManager.packageName,
            iosUniversalLinkReturnUrl: 'YOUR_VENMO_UNIVERSAL_LINK',
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
                  androidAppLinkReturnUrl: FlavorManager.packageName,
                  androidDeepLinkFallbackUrlScheme: FlavorManager.packageName,
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

      **Important:** 

      Replace `"YOUR_BRAINTREE_CLIENT_TOKEN"` with your actual Braintree client token.
      Replace `"YOUR_VENMO_UNIVERSAL_LINK"` with your venmo universal link.

## License

This plugin is released under the MIT License. See the `LICENSE` file for more details.