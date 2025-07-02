enum PaymentIntent { sale, order, authorize }

enum PaymentUserAction { commit }

class PayPalRequest {
  PayPalRequest({
    required this.token,
    required this.amount,
    this.currencyCode = "USD",
    required this.displayName,
    required this.androidAppLinkReturnUrl,
    this.androidDeepLinkFallbackUrlScheme,
    this.billingAgreementDescription,
    this.paymentIntent,
    this.userAction,
  });

  final String token;
  final String amount;
  final String currencyCode;
  final String displayName;
  final String androidAppLinkReturnUrl;
  final String? androidDeepLinkFallbackUrlScheme;
  final String? billingAgreementDescription;
  final PaymentIntent? paymentIntent;
  final PaymentUserAction? userAction;

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'amount': amount,
      'currencyCode': currencyCode,
      'displayName': displayName,
      'androidAppLinkReturnUrl': androidAppLinkReturnUrl,
      'androidDeepLinkFallbackUrlScheme': androidDeepLinkFallbackUrlScheme,
      'billingAgreementDescription': billingAgreementDescription,
      'paymentIntent': paymentIntent?.name,
      'userAction': userAction?.name,
    };
  }
}
