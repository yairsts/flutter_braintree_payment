class BraintreePaymentConstants {
  static const String venmoPaymentMethodKey = "venmoPayment";
  static const String paypalPaymentMethodKey = "paypalPayment";

  // Reply keys: the native side replies with exactly one of them.
  static const String nonceKey = "nonce";
  static const String canceledKey = "canceled";
}
