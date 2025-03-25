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
    const val APP_LINK_RETURN_URL = "appLinkReturnUrl"
    const val DEEP_LINK_FALLBACK_URL_SCHEME = "deepLinkFallbackUrlScheme"
    const val BILLING_AGREEMENT_DESCRIPTION = "billingAgreementDescription"



    //Response keys
    const val NONCE_KEY = "nonce"
    const val CANCELED_KEY = "canceled"
    const val ERROR_KEY = "error"
}