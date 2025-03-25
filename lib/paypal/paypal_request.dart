class PayPalRequest {
  PayPalRequest({
    required this.token,
    required this.amount,
    required this.displayName,
    required this.appLinkReturnUrl,
    this.deepLinkFallbackUrlScheme,
    this.billingAgreementDescription,
  });

  final String token;
  final String amount;
  final String displayName;
  final String appLinkReturnUrl;
  final String? deepLinkFallbackUrlScheme;
  final String? billingAgreementDescription;

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'amount': amount,
      'displayName': displayName,
      'appLinkReturnUrl': appLinkReturnUrl,
      'deepLinkFallbackUrlScheme': deepLinkFallbackUrlScheme,
      'billingAgreementDescription': billingAgreementDescription,
    };
  }
}
