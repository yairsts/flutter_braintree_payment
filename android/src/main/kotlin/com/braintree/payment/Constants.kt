package com.braintree.payment

object Constants {
    const val VENMO_PAYMENT_METHOD_KEY = "venmoPayment"
    const val PAYPAL_PAYMENT_METHOD_KEY = "paypalPayment"

    const val VENMO_REQUEST_CODE = 1001
    const val PAYPAL_REQUEST_CODE = 1002

    //Request keys
    const val TOKEN_KEY = "token"
    const val AMOUNT_KEY = "amount"
    const val DISPLAY_NAME_KEY = "displayName"
    const val CURRENCY_CODE_KEY = "currencyCode"
    const val ANDROID_APP_LINK_RETURN_URL = "androidAppLinkReturnUrl"
    const val ANDROID_DEEP_LINK_FALLBACK_URL_SCHEME = "androidDeepLinkFallbackUrlScheme"
    const val IOS_UNIVERSAL_LINK_RETURN_URL = "iosUniversalLinkReturnUrl"
    const val BILLING_AGREEMENT_DESCRIPTION = "billingAgreementDescription"
    const val PAYMENT_INTENT = "paymentIntent"
    const val USER_ACTION = "userAction"

    //Response keys
    const val NONCE_KEY = "nonce"
    const val CANCELED_KEY = "canceled"
    const val ERROR_KEY = "error"
}