import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_braintree_payment/braintree_payment_constants.dart';
import 'package:flutter_braintree_payment/braintree_payment_method_channel.dart';
import 'package:flutter_braintree_payment/flutter_braintree_payment.dart';
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
            return {BraintreePaymentConstants.nonceKey: jsonEncode(result)};
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
            return {BraintreePaymentConstants.nonceKey: jsonEncode(result)};
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
    final result = await platform.paypalPayment(
      PayPalRequest(
        token: "TOKEN",
        displayName: "EXAMPLE",
        currencyCode: "USD",
        amount: "10.0",
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

  group('result contract', () {
    final request = PayPalRequest(
      token: "TOKEN",
      displayName: "EXAMPLE",
      amount: "10.0",
      androidAppLinkReturnUrl: "ANDROID_APP_LINK_RETURN_URL",
      androidDeepLinkFallbackUrlScheme: "ANDROID_DEEP_LINK_FALLBACK_URL_SCHEME",
    );
    void reply(Future<Object?> Function() handler) {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (_) => handler());
    }

    for (final reason in BraintreeCancelReason.values) {
      test('a cancel completes with its reason: ${reason.name}', () async {
        reply(() async => {BraintreePaymentConstants.canceledKey: reason.name});
        expect(
          await platform.paypalPayment(request),
          isA<BraintreeCancelled<PayPalAccountNonce>>()
              .having((r) => r.reason, 'reason', reason),
        );
      });
    }

    test('an empty reply is a cancel with no result', () async {
      reply(() async => null);
      expect(
        await platform.paypalPayment(request),
        isA<BraintreeCancelled<PayPalAccountNonce>>().having(
            (r) => r.reason, 'reason', BraintreeCancelReason.noResult),
      );
    });

    test('a failure throws a PlatformException with code error', () async {
      reply(() async => throw PlatformException(code: 'error', message: 'boom'));
      await expectLater(
        platform.paypalPayment(request),
        throwsA(isA<PlatformException>().having((e) => e.code, 'code', 'error')),
      );
    });
  });
}
