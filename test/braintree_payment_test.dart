import 'package:braintree_payment/braintree_payment.dart';
import 'package:braintree_payment/braintree_payment_method_channel.dart';
import 'package:braintree_payment/braintree_payment_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockBraintreePaymentPlatform
    with MockPlatformInterfaceMixin
    implements BraintreePaymentPlatform {
  @override
  Future<VenmoAccountNonce?> venmoPayment(VenmoRequest request) async {
    expect(request.token, "TOKEN");
    expect(request.androidAppLinkReturnUrl, "ANDROID_APP_LINK_RETURN_URL");
    expect(request.androidDeepLinkFallbackUrlScheme,
        "ANDROID_DEEP_LINK_FALLBACK_URL_SCHEME");
    expect(request.iosUniversalLinkReturnUrl, "IOS_UNIVERSAL_LINK_RETURN_URL");
    expect(request.displayName, "EXAMPLE");
    expect(request.amount, "10.0");

    return VenmoAccountNonce(
      isDefault: true,
      nonce: "VENMO_NONCE",
      username: "USERNAME",
      email: "EMAIL",
      phoneNumber: "PHONE_NUMBER",
      firstName: "FIRST_NAME",
      lastName: "LAST_NAME",
      externalId: "EXTERNAL_ID",
    );
  }

  @override
  Future<PayPalAccountNonce?> paypalPayment(PayPalRequest request) async {
    expect(request.token, "TOKEN");
    expect(request.displayName, "EXAMPLE");
    expect(request.amount, "10.0");
    expect(request.currencyCode, "USD");
    expect(request.androidAppLinkReturnUrl, "ANDROID_APP_LINK_RETURN_URL");
    expect(request.androidDeepLinkFallbackUrlScheme,
        "ANDROID_DEEP_LINK_FALLBACK_URL_SCHEME");
    expect(
        request.billingAgreementDescription, "BILLING_AGREEMENT_DESCRIPTION");

    return PayPalAccountNonce(
      isDefault: true,
      nonce: "PAYPAL_NONCE",
      firstName: "FIRST_NAME",
      lastName: "LAST_NAME",
      email: "EMAIL",
      phone: "PHONE",
      payerId: "PAYER_ID",
      authenticateUrl: "AUTHENTICATE_URL",
      clientMetadataId: "CLIENT_METADATA_ID",
    );
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

    expect(result?.isDefault, true);
    expect(result?.nonce, "VENMO_NONCE");
    expect(result?.username, "USERNAME");
    expect(result?.email, "EMAIL");
    expect(result?.phoneNumber, "PHONE_NUMBER");
    expect(result?.firstName, "FIRST_NAME");
    expect(result?.lastName, "LAST_NAME");
    expect(result?.externalId, "EXTERNAL_ID");
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

    expect(result?.isDefault, true);
    expect(result?.nonce, "PAYPAL_NONCE");
    expect(result?.email, "EMAIL");
    expect(result?.phone, "PHONE");
    expect(result?.firstName, "FIRST_NAME");
    expect(result?.lastName, "LAST_NAME");
    expect(result?.clientMetadataId, "CLIENT_METADATA_ID");
    expect(result?.authenticateUrl, "AUTHENTICATE_URL");
    expect(result?.payerId, "PAYER_ID");
  });
}
