/// How a PayPal or Venmo payment ended, when it did not fail.
///
/// A failure still throws a `PlatformException` with code `error`.
sealed class BraintreeResult<T> {
  const BraintreeResult();
}

/// The user approved the payment. Send [nonce] to your server to charge it.
final class BraintreeSuccess<T> extends BraintreeResult<T> {
  const BraintreeSuccess(this.nonce);

  final T nonce;
}

/// The payment ended without a nonce. This is not an error.
final class BraintreeCancelled<T> extends BraintreeResult<T> {
  const BraintreeCancelled(this.reason);

  final BraintreeCancelReason reason;
}

/// Why a payment ended without a nonce.
enum BraintreeCancelReason {
  /// The user cancelled in PayPal or Venmo.
  userCanceled,

  /// PayPal or Venmo returned to the app without a result.
  noResult,

  /// Android only: the app was restarted while the user was in PayPal or
  /// Venmo, and the original request was lost with it.
  requestLost,
}
