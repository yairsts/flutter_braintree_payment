import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_braintree_payment/paypal/paypal_request.dart';

import 'braintree_payment_constants.dart';
import 'braintree_payment_platform_interface.dart';
import 'braintree_result.dart';
import 'paypal/paypal_account_nonce.dart';
import 'venmo/venmo_account_nonce.dart';
import 'venmo/venmo_request.dart';

/// An implementation of [BraintreePaymentPlatform] that uses method channels.
class MethodChannelBraintreePayment extends BraintreePaymentPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('braintree_payment');

  @override
  Future<BraintreeResult<VenmoAccountNonce>> venmoPayment(
      VenmoRequest request) {
    return _pay(BraintreePaymentConstants.venmoPaymentMethodKey,
        request.toJson(), VenmoAccountNonce.fromJson);
  }

  @override
  Future<BraintreeResult<PayPalAccountNonce>> paypalPayment(
      PayPalRequest request) {
    return _pay(BraintreePaymentConstants.paypalPaymentMethodKey,
        request.toJson(), PayPalAccountNonce.fromJson);
  }

  Future<BraintreeResult<T>> _pay<T>(
    String method,
    Map<String, dynamic> request,
    T Function(Map<String, dynamic> json) fromJson,
  ) async {
    final reply = await methodChannel.invokeMethod<Object?>(method, request);
    return switch (reply) {
      {BraintreePaymentConstants.nonceKey: final String json} =>
        BraintreeSuccess(fromJson(jsonDecode(json) as Map<String, dynamic>)),
      {BraintreePaymentConstants.canceledKey: final String reason} =>
        BraintreeCancelled(BraintreeCancelReason.values.byName(reason)),
      _ => const BraintreeCancelled(BraintreeCancelReason.noResult),
    };
  }
}
