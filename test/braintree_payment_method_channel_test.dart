import 'dart:convert';

import 'package:braintree_payment/braintree_payment.dart';
import 'package:braintree_payment/braintree_payment_constants.dart';
import 'package:braintree_payment/braintree_payment_method_channel.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelBraintreePayment platform = MethodChannelBraintreePayment();
  const MethodChannel channel = MethodChannel('braintree_payment');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        switch (methodCall.method) {
          case BraintreePaymentConstants.venmoPaymentMethodKey:
            final result = VenmoAccountNonce(
              isDefault: true,
              nonce: "VENMO_NONCE",
              username: "USERNAME",
              email: "EMAIL",
              phoneNumber: "PHONE_NUMBER",
              firstName: "FIRST_NAME",
              lastName: "LAST_NAME",
              externalId: "EXTERNAL_ID",
            );
            return jsonEncode(result);
          case BraintreePaymentConstants.paypalPaymentMethodKey:
            final result = PayPalAccountNonce(
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
            return jsonEncode(result);
        }
        return null;
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('venmoPayment', () async {
    final result = await platform.venmoPayment(
      VenmoRequest(
        token: "TOKEN",
        displayName: "EXAMPLE",
        amount: "10.0",
        appLinkReturnUrl: "APP_LINK_RETURN_URL",
        deepLinkFallbackUrlScheme: "DEEP_LINK_FALLBACK_URL_SCHEME",
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
    final result = await platform.paypalPayment(
      PayPalRequest(
        token: "TOKEN",
        displayName: "EXAMPLE",
        amount: "10.0",
        appLinkReturnUrl: "APP_LINK_RETURN_URL",
        deepLinkFallbackUrlScheme: "DEEP_LINK_FALLBACK_URL_SCHEME",
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
