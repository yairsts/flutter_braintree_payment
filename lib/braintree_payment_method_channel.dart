import 'dart:convert';
import 'dart:io';

import 'package:braintree_payment/paypal/paypal_request.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'braintree_payment_constants.dart';
import 'braintree_payment_platform_interface.dart';
import 'paypal/paypal_account_nonce.dart';
import 'venmo/venmo_account_nonce.dart';
import 'venmo/venmo_request.dart';

/// An implementation of [BraintreePaymentPlatform] that uses method channels.
class MethodChannelBraintreePayment extends BraintreePaymentPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('braintree_payment');

  @override
  Future<VenmoAccountNonce?> venmoPayment(VenmoRequest request) async {
    if (Platform.isAndroid) {
      assert(request.androidAppLinkReturnUrl != null,
          "androidAppLinkReturnUrl is required");
    } else if (Platform.isIOS) {
      assert(request.iosUniversalLinkReturnUrl != null,
          "iosUniversalLinkReturnUrl is required");
    }

    final String? res = await methodChannel.invokeMethod<String>(
        BraintreePaymentConstants.venmoPaymentMethodKey, request.toJson());
    if (res != null) {
      final json = jsonDecode(res);
      return VenmoAccountNonce.fromJson(json);
    } else {
      return null;
    }
  }

  @override
  Future<PayPalAccountNonce?> paypalPayment(PayPalRequest request) async {
    final String? res = await methodChannel.invokeMethod<String>(
        BraintreePaymentConstants.paypalPaymentMethodKey, request.toJson());
    if (res != null) {
      final json = jsonDecode(res);
      return PayPalAccountNonce.fromJson(json);
    } else {
      return null;
    }
  }
}
