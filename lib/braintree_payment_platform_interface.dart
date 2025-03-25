import 'package:braintree_payment/paypal/paypal_account_nonce.dart';
import 'package:braintree_payment/paypal/paypal_request.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'braintree_payment_method_channel.dart';
import 'venmo/venmo_account_nonce.dart';
import 'venmo/venmo_request.dart';

abstract class BraintreePaymentPlatform extends PlatformInterface {
  /// Constructs a BraintreePaymentPlatform.
  BraintreePaymentPlatform() : super(token: _token);

  static final Object _token = Object();

  static BraintreePaymentPlatform _instance = MethodChannelBraintreePayment();

  /// The default instance of [BraintreePaymentPlatform] to use.
  ///
  /// Defaults to [MethodChannelBraintreePayment].
  static BraintreePaymentPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [BraintreePaymentPlatform] when
  /// they register themselves.
  static set instance(BraintreePaymentPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<VenmoAccountNonce?> venmoPayment(VenmoRequest request) {
    throw UnimplementedError('venmoPayment() has not been implemented.');
  }

  Future<PayPalAccountNonce?> paypalPayment(PayPalRequest request) {
    throw UnimplementedError('paypalPayment() has not been implemented.');
  }
}
