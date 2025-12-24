package com.braintree.payment

import android.app.Activity.RESULT_CANCELED
import android.app.Activity.RESULT_OK
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.util.Log
import androidx.activity.ComponentActivity
import com.braintreepayments.api.paypal.PayPalCheckoutRequest
import com.braintreepayments.api.paypal.PayPalClient
import com.braintreepayments.api.paypal.PayPalLauncher
import com.braintreepayments.api.paypal.PayPalPaymentAuthRequest
import com.braintreepayments.api.paypal.PayPalPaymentAuthResult
import com.braintreepayments.api.paypal.PayPalPaymentIntent
import com.braintreepayments.api.paypal.PayPalPaymentUserAction
import com.braintreepayments.api.paypal.PayPalPendingRequest
import com.braintreepayments.api.paypal.PayPalResult
import org.json.JSONObject

class PayPalActivity : ComponentActivity() {
    private lateinit var paypalClient: PayPalClient
    private lateinit var paypalLauncher: PayPalLauncher

    private var storedPendingRequest: PayPalPendingRequest.Started? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val intent = getIntent();
        Log.d(
            "BraintreePaymentPlugin", "PayPalActivity, onCreate, intent: ${intent}"
        )
        val token: String = intent.getStringExtra(Constants.TOKEN_KEY) as String
        val displayName: String = intent.getStringExtra(Constants.DISPLAY_NAME_KEY) as String
        val amount: String = intent.getStringExtra(Constants.AMOUNT_KEY) as String
        val currencyCode: String = intent.getStringExtra(Constants.CURRENCY_CODE_KEY) as String

        val appLinkReturnUrl: String =
            intent.getStringExtra(Constants.ANDROID_APP_LINK_RETURN_URL) as String
        val deepLinkFallbackUrlScheme: String? =
            intent.getStringExtra(Constants.ANDROID_DEEP_LINK_FALLBACK_URL_SCHEME)
        val billingAgreementDescription: String? =
            intent.getStringExtra(Constants.BILLING_AGREEMENT_DESCRIPTION)
        val paymentIntent: String? =
            intent.getStringExtra(Constants.PAYMENT_INTENT)
        val userAction: String? =
            intent.getStringExtra(Constants.USER_ACTION)

        paypalLauncher = PayPalLauncher()
        paypalClient = PayPalClient(
            context = this,
            authorization = token,
            appLinkReturnUrl = resolveAppLinkReturnUrl(appLinkReturnUrl, "paypal"),
            deepLinkFallbackUrlScheme = resolveFallbackScheme(deepLinkFallbackUrlScheme, "paypal"),
        )

        val payPalRequest = PayPalCheckoutRequest(
            displayName = displayName,
            amount = amount,
            currencyCode = currencyCode,
            hasUserLocationConsent = true,
            billingAgreementDescription = billingAgreementDescription,
            intent = when (paymentIntent) {
                "sale" -> PayPalPaymentIntent.SALE
                "order" -> PayPalPaymentIntent.ORDER
                else -> PayPalPaymentIntent.AUTHORIZE
            },
            userAction = when (userAction) {
                "commit" -> PayPalPaymentUserAction.USER_ACTION_COMMIT
                else -> PayPalPaymentUserAction.USER_ACTION_DEFAULT
            }
        )

        startPayPalFlow(payPalRequest)

    }

    private fun startPayPalFlow(request: PayPalCheckoutRequest) {
        Log.d(
            "BraintreePaymentPlugin",
            "startPayPalFlow, intent: $intent, PayPalVaultRequest: $request"
        )
        try {

            paypalClient.createPaymentAuthRequest(
                this, request
            ) { paymentAuthRequest ->
                when (paymentAuthRequest) {
                    is PayPalPaymentAuthRequest.Failure -> {
                        val error = paymentAuthRequest.error
                        handleErrorResult(error)
                    }

                    is PayPalPaymentAuthRequest.ReadyToLaunch -> {
                        Log.d(
                            "BraintreePaymentPlugin",
                            "PayPalActivity, PayPal Auth Request ReadyToLaunch, requestParams: ${paymentAuthRequest.requestParams}"
                        )
                        launch(paymentAuthRequest)
                    }

                }
            }
        } catch (error: Exception) {
            handleErrorResult(error)
        }
    }

    private fun launch(paymentAuthResult: PayPalPaymentAuthRequest.ReadyToLaunch) {
        try {
            val pendingRequest: PayPalPendingRequest = paypalLauncher.launch(
                this, paymentAuthResult
            )
            Log.d(
                "BraintreePaymentPlugin", "launch, pendingRequest: $pendingRequest"
            )
            when (pendingRequest) {
                is PayPalPendingRequest.Started -> {
                    storedPendingRequest = pendingRequest
                }

                is PayPalPendingRequest.Failure -> {
                    val error = pendingRequest.error
                    handleErrorResult(error)
                }
            }
        } catch (error: Exception) {
            handleErrorResult(error)
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        Log.d("BraintreePaymentPlugin", "onNewIntent, intent: $intent")
        handleReturnToApp(intent)
    }

    override fun onResume() {
        super.onResume()
        Log.d("BraintreePaymentPlugin", "onResume, intent: $intent")
        handleReturnToApp(intent)
    }

    private fun handleReturnToApp(intent: Intent) {
        super.onResume()
        val pendingRequest = storedPendingRequest
        Log.d("BraintreePaymentPlugin", "handleReturnToApp, pendingRequest: $pendingRequest")

        pendingRequest?.let {
            val paymentAuthResult: PayPalPaymentAuthResult = paypalLauncher.handleReturnToApp(
                pendingRequest = it, intent = intent
            )
            when (paymentAuthResult) {
                is PayPalPaymentAuthResult.Success -> {
                    Log.d(
                        "BraintreePaymentPlugin",
                        "handleReturnToApp, paymentAuthResult Success, paymentAuthResult: $paymentAuthResult"
                    )
                    completePayPalFlow(paymentAuthResult)
                }

                is PayPalPaymentAuthResult.Failure -> {
                    val error = paymentAuthResult.error
                    handleErrorResult(error)
                }

                is PayPalPaymentAuthResult.NoResult -> {
                    handleCancelResult(paymentAuthResult.toString())
                }
            }
            storedPendingRequest = null
        }
    }

    private fun resolveAppLinkReturnUrl(raw: String, suffix: String): Uri {
        val value = raw.trim()
        if (value.contains("://")) {
            return Uri.parse(value)
        }
        val scheme = if (value.endsWith(".$suffix")) value else "$value.$suffix"
        return Uri.parse(scheme)
    }

    private fun resolveFallbackScheme(raw: String?, suffix: String): String {
        val value = raw?.trim().orEmpty()
        if (value.isEmpty()) {
            return value
        }
        val scheme = if (value.contains("://")) {
            Uri.parse(value).scheme ?: value
        } else {
            value
        }
        return if (scheme.endsWith(".$suffix")) scheme else "$scheme.$suffix"
    }

    private fun completePayPalFlow(paymentAuthResult: PayPalPaymentAuthResult.Success) {
        Log.d(
            "BraintreePaymentPlugin",
            "completePayPalFlow, intent: $intent, paymentAuthResult: $paymentAuthResult"
        )

        paypalClient.tokenize(paymentAuthResult) { result: PayPalResult ->
            this.handlePayPalResult(result)
        }
    }

    private fun handlePayPalResult(result: PayPalResult) {
        Log.d("BraintreePaymentPlugin", "handlePayPalResult, intent: $intent, result: $result")

        when (result) {
            is PayPalResult.Success -> {
                handleSuccessResult(result)
            }

            is PayPalResult.Failure -> {
                val error = result.error
                handleErrorResult(error)
            }

            is PayPalResult.Cancel -> {
                handleCancelResult(result.toString())
            }
        }
    }

    private fun handleSuccessResult(result: PayPalResult.Success) {
        Log.d(
            "BraintreePaymentPlugin", "handleSuccessResult, PayPalResult Success, result: $result"
        )
        val nonce = result.nonce
        val nonceJson = JSONObject().apply {
            put("nonce", nonce.string)
            put("isDefault", nonce.isDefault)
            put("clientMetadataId", nonce.clientMetadataId ?: JSONObject.NULL)
            put("firstName", nonce.firstName)
            put("lastName", nonce.lastName)
            put("phone", nonce.phone)
            put("email", nonce.email ?: JSONObject.NULL)
            put("payerId", nonce.payerId)
            put("authenticateUrl", nonce.authenticateUrl ?: JSONObject.NULL)
        }
        val resultIntent = Intent().apply {
            putExtra(Constants.NONCE_KEY, nonceJson.toString())
        }
        setResult(RESULT_OK, resultIntent)
        finish()
    }

    private fun handleErrorResult(error: Exception) {
        Log.e(
            "BraintreePaymentPlugin",
            "PayPalActivity, handleErrorResult: ${error.localizedMessage}",
            error
        )
        val resultIntent = Intent().apply {
            putExtra(Constants.ERROR_KEY, error.toString())
        }
        setResult(RESULT_CANCELED, resultIntent)
        finish()
    }

    private fun handleCancelResult(message: String) {
        Log.d(
            "BraintreePaymentPlugin", "handleCancelResult, message: $message"
        )
        val resultIntent = Intent().apply {
            putExtra(Constants.CANCELED_KEY, message.toString())
        }
        setResult(RESULT_CANCELED, resultIntent)
        finish()
    }
}
