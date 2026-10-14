import 'braintree_payment_platform_interface.dart';
import 'paypal/paypal_account_nonce.dart';
import 'paypal/paypal_request.dart';
import 'venmo/venmo_account_nonce.dart';
import 'venmo/venmo_request.dart';

export 'paypal/paypal_account_nonce.dart';
export 'paypal/paypal_request.dart';
export 'venmo/venmo_account_nonce.dart';
export 'venmo/venmo_request.dart';

class BraintreePayment {
  /// Returns the nonce, or null if the user cancelled.
  /// Throws a [PlatformException] with code `error` if the payment failed.
  Future<VenmoAccountNonce?> venmoPayment(VenmoRequest request) async {
    return BraintreePaymentPlatform.instance.venmoPayment(request);
  }

  /// Returns the nonce, or null if the user cancelled.
  /// Throws a [PlatformException] with code `error` if the payment failed.
  Future<PayPalAccountNonce?> paypalPayment(PayPalRequest request) async {
    return BraintreePaymentPlatform.instance.paypalPayment(request);
  }
}
