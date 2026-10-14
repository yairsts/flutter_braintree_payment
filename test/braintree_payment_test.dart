import 'package:flutter_braintree_payment/braintree_payment_method_channel.dart';
import 'package:flutter_braintree_payment/braintree_payment_platform_interface.dart';
import 'package:flutter_braintree_payment/flutter_braintree_payment.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockBraintreePaymentPlatform
    with MockPlatformInterfaceMixin
    implements BraintreePaymentPlatform {
  @override
  Future<BraintreeResult<VenmoAccountNonce>> venmoPayment(
      VenmoRequest request) async {
    expect(request.token, "TOKEN");
    expect(request.androidAppLinkReturnUrl, "ANDROID_APP_LINK_RETURN_URL");
    expect(request.androidDeepLinkFallbackUrlScheme,
        "ANDROID_DEEP_LINK_FALLBACK_URL_SCHEME");
    expect(request.iosUniversalLinkReturnUrl, "IOS_UNIVERSAL_LINK_RETURN_URL");
    expect(request.displayName, "EXAMPLE");
    expect(request.amount, "10.0");

    return BraintreeSuccess(VenmoAccountNonce(
      isDefault: true,
      nonce: "VENMO_NONCE",
      username: "USERNAME",
      email: "EMAIL",
      phoneNumber: "PHONE_NUMBER",
      firstName: "FIRST_NAME",
      lastName: "LAST_NAME",
      externalId: "EXTERNAL_ID",
    ));
  }

  @override
  Future<BraintreeResult<PayPalAccountNonce>> paypalPayment(
      PayPalRequest request) async {
    expect(request.token, "TOKEN");
    expect(request.displayName, "EXAMPLE");
    expect(request.amount, "10.0");
    expect(request.currencyCode, "USD");
    expect(request.androidAppLinkReturnUrl, "ANDROID_APP_LINK_RETURN_URL");
    expect(request.androidDeepLinkFallbackUrlScheme,
        "ANDROID_DEEP_LINK_FALLBACK_URL_SCHEME");
    expect(
        request.billingAgreementDescription, "BILLING_AGREEMENT_DESCRIPTION");

    return BraintreeSuccess(PayPalAccountNonce(
      isDefault: true,
      nonce: "PAYPAL_NONCE",
      firstName: "FIRST_NAME",
      lastName: "LAST_NAME",
      email: "EMAIL",
      phone: "PHONE",
      payerId: "PAYER_ID",
      authenticateUrl: "AUTHENTICATE_URL",
      clientMetadataId: "CLIENT_METADATA_ID",
    ));
  }
}

void main() {
  final BraintreePaymentPlatform initialPlatform =
      BraintreePaymentPlatform.instance;

  test('$MethodChannelBraintreePayment is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelBraintreePayment>());
  });

  test('venmoPayment', () async {
    BraintreePayment braintreePaymentPlugin = BraintreePayment();
    MockBraintreePaymentPlatform fakePlatform = MockBraintreePaymentPlatform();
    BraintreePaymentPlatform.instance = fakePlatform;
    final result = await braintreePaymentPlugin.venmoPayment(
      VenmoRequest(
        token: "TOKEN",
        displayName: "EXAMPLE",
        amount: "10.0",
        androidAppLinkReturnUrl: "ANDROID_APP_LINK_RETURN_URL",
        androidDeepLinkFallbackUrlScheme:
            "ANDROID_DEEP_LINK_FALLBACK_URL_SCHEME",
        iosUniversalLinkReturnUrl: "IOS_UNIVERSAL_LINK_RETURN_URL",
      ),
    );
    final nonce = (result as BraintreeSuccess<VenmoAccountNonce>).nonce;

    expect(nonce.isDefault, true);
    expect(nonce.nonce, "VENMO_NONCE");
    expect(nonce.username, "USERNAME");
    expect(nonce.email, "EMAIL");
    expect(nonce.phoneNumber, "PHONE_NUMBER");
    expect(nonce.firstName, "FIRST_NAME");
    expect(nonce.lastName, "LAST_NAME");
    expect(nonce.externalId, "EXTERNAL_ID");
  });

  test('paypalPayment', () async {
    BraintreePayment braintreePaymentPlugin = BraintreePayment();
    MockBraintreePaymentPlatform fakePlatform = MockBraintreePaymentPlatform();
    BraintreePaymentPlatform.instance = fakePlatform;
    final result = await braintreePaymentPlugin.paypalPayment(
      PayPalRequest(
        token: "TOKEN",
        displayName: "EXAMPLE",
        amount: "10.0",
        currencyCode: "USD",
        androidAppLinkReturnUrl: "ANDROID_APP_LINK_RETURN_URL",
        androidDeepLinkFallbackUrlScheme:
            "ANDROID_DEEP_LINK_FALLBACK_URL_SCHEME",
        billingAgreementDescription: "BILLING_AGREEMENT_DESCRIPTION",
      ),
    );
    final nonce = (result as BraintreeSuccess<PayPalAccountNonce>).nonce;

    expect(nonce.isDefault, true);
    expect(nonce.nonce, "PAYPAL_NONCE");
    expect(nonce.email, "EMAIL");
    expect(nonce.phone, "PHONE");
    expect(nonce.firstName, "FIRST_NAME");
    expect(nonce.lastName, "LAST_NAME");
    expect(nonce.clientMetadataId, "CLIENT_METADATA_ID");
    expect(nonce.authenticateUrl, "AUTHENTICATE_URL");
    expect(nonce.payerId, "PAYER_ID");
  });
}
