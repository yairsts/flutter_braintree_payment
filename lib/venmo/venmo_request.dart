class VenmoRequest {
  VenmoRequest({
    required this.token,
    required this.amount,
    required this.displayName,
    required this.iosUniversalLinkReturnUrl,
    required this.androidAppLinkReturnUrl,
    required this.androidDeepLinkFallbackUrlScheme,
  });

  final String token;
  final String amount;
  final String displayName;
  final String iosUniversalLinkReturnUrl;
  final String androidAppLinkReturnUrl;
  final String androidDeepLinkFallbackUrlScheme;

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'amount': amount,
      'displayName': displayName,
      'iosUniversalLinkReturnUrl': iosUniversalLinkReturnUrl,
      'androidAppLinkReturnUrl': androidAppLinkReturnUrl,
      'androidDeepLinkFallbackUrlScheme': androidDeepLinkFallbackUrlScheme,
    };
  }
}
