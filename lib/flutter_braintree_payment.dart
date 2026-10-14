import 'braintree_payment_platform_interface.dart';
import 'braintree_result.dart';
import 'paypal/paypal_account_nonce.dart';
import 'paypal/paypal_request.dart';
import 'venmo/venmo_account_nonce.dart';
import 'venmo/venmo_request.dart';

export 'braintree_result.dart';
export 'paypal/paypal_account_nonce.dart';
export 'paypal/paypal_request.dart';
export 'venmo/venmo_account_nonce.dart';
export 'venmo/venmo_request.dart';

class BraintreePayment {
  /// Completes with [BraintreeSuccess] or [BraintreeCancelled].
  /// Throws a [PlatformException] with code `error` if the payment failed.
  Future<BraintreeResult<VenmoAccountNonce>> venmoPayment(
      VenmoRequest request) async {
    return BraintreePaymentPlatform.instance.venmoPayment(request);
  }

  /// Completes with [BraintreeSuccess] or [BraintreeCancelled].
  /// Throws a [PlatformException] with code `error` if the payment failed.
  Future<BraintreeResult<PayPalAccountNonce>> paypalPayment(
      PayPalRequest request) async {
    return BraintreePaymentPlatform.instance.paypalPayment(request);
  }
}
