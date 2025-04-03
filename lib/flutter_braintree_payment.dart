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
  Future<VenmoAccountNonce?> venmoPayment(VenmoRequest request) async {
    return BraintreePaymentPlatform.instance.venmoPayment(request);
  }

  Future<PayPalAccountNonce?> paypalPayment(PayPalRequest request) async {
    return BraintreePaymentPlatform.instance.paypalPayment(request);
  }
}
