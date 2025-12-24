package com.braintree.payment


import android.app.Activity
import android.content.Intent
import android.content.Intent.getIntent
import android.net.Uri
import android.os.Bundle
import android.util.Log
import androidx.activity.ComponentActivity

import com.braintreepayments.api.venmo.VenmoClient
import com.braintreepayments.api.venmo.VenmoLauncher
import com.braintreepayments.api.venmo.VenmoPaymentAuthRequest
import com.braintreepayments.api.venmo.VenmoPaymentAuthResult
import com.braintreepayments.api.venmo.VenmoPaymentMethodUsage
import com.braintreepayments.api.venmo.VenmoPendingRequest
import com.braintreepayments.api.venmo.VenmoRequest
import com.braintreepayments.api.venmo.VenmoResult
import org.json.JSONObject
import kotlin.toString

class VenmoActivity : ComponentActivity() {
    private lateinit var venmoClient: VenmoClient
    private lateinit var venmoLauncher: VenmoLauncher
    private var storedPendingRequest: VenmoPendingRequest.Started? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val intent = getIntent();
        Log.d(
            "BraintreePaymentPlugin",
            "VenmoActivity, onCreate, intent: ${intent}"
        )
        val token: String = intent.getStringExtra(Constants.TOKEN_KEY) as String
        val displayName: String = intent.getStringExtra(Constants.DISPLAY_NAME_KEY) as String
        val amount: String = intent.getStringExtra(Constants.AMOUNT_KEY) as String
        val appLinkReturnUrl: String =
            intent.getStringExtra(Constants.ANDROID_APP_LINK_RETURN_URL) as String
        val deepLinkFallbackUrlScheme: String? =
            intent.getStringExtra(Constants.ANDROID_DEEP_LINK_FALLBACK_URL_SCHEME)

        venmoLauncher = VenmoLauncher()
        venmoClient = VenmoClient(
            context = this,
            authorization = token,
            appLinkReturnUrl = resolveAppLinkReturnUrl(appLinkReturnUrl, "venmo"),
            deepLinkFallbackUrlScheme = resolveFallbackScheme(deepLinkFallbackUrlScheme, "venmo"),
        )

        val venmoRequest = VenmoRequest(
            VenmoPaymentMethodUsage.SINGLE_USE,
            totalAmount = amount,
            displayName = displayName,
            )
        startVenmoFlow(venmoRequest)

    }

    private fun startVenmoFlow(venmoRequest: VenmoRequest) {
        Log.d(
            "BraintreePaymentPlugin",
            "startVenmoFlow, intent: $intent, venmoRequest: $venmoRequest"
        )
        try {
            venmoClient.createPaymentAuthRequest(
                context = this,
                request = venmoRequest
            ) { paymentAuthRequest ->
                when (paymentAuthRequest) {
                    is VenmoPaymentAuthRequest.Failure -> {
                        val error = paymentAuthRequest.error
                        handleErrorResult(error)
                    }

                    is VenmoPaymentAuthRequest.ReadyToLaunch -> {
                        Log.d(
                            "BraintreePaymentPlugin",
                            "VenmoActivity, Venmo Auth Request ReadyToLaunch, requestParams: ${paymentAuthRequest.requestParams}"
                        )
                        launch(paymentAuthRequest)
                    }
                }
            }
        } catch (error: Exception) {
            handleErrorResult(error)
        }
    }

    private fun launch(paymentAuthResult: VenmoPaymentAuthRequest.ReadyToLaunch) {
        try {
            val pendingRequest: VenmoPendingRequest = venmoLauncher.launch(
                activity = this,
                paymentAuthRequest = paymentAuthResult
            )
            Log.d(
                "BraintreePaymentPlugin",
                "launch, pendingRequest: $pendingRequest"
            )
            when (pendingRequest) {
                is VenmoPendingRequest.Started -> {
                    storedPendingRequest = pendingRequest
                }

                is VenmoPendingRequest.Failure -> {
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

    private fun handleReturnToApp(intent: Intent) {
        super.onResume()
        val pendingRequest = storedPendingRequest
        Log.d("BraintreePaymentPlugin", "handleReturnToApp, pendingRequest: $pendingRequest")

        pendingRequest?.let {
            val paymentAuthResult: VenmoPaymentAuthResult =
                venmoLauncher.handleReturnToApp(
                    pendingRequest = it,
                    intent = intent
                )
            when (paymentAuthResult) {
                is VenmoPaymentAuthResult.Success -> {
                    Log.d(
                        "BraintreePaymentPlugin",
                        "handleReturnToApp, paymentAuthResult Success, paymentAuthResult: $paymentAuthResult"
                    )
                    completeVenmoFlow(paymentAuthResult)
                }

                is VenmoPaymentAuthResult.Failure -> {
                    val error = paymentAuthResult.error
                    handleErrorResult(error)
                }

                is VenmoPaymentAuthResult.NoResult -> {
                    handleCancelResult(paymentAuthResult.toString())
                }
            }
            storedPendingRequest = null
        }
    }

    private fun completeVenmoFlow(paymentAuthResult: VenmoPaymentAuthResult.Success) {
        Log.d(
            "BraintreePaymentPlugin",
            "completeVenmoFlow, intent: $intent, paymentAuthResult: $paymentAuthResult"
        )

        venmoClient.tokenize(paymentAuthResult) { result: VenmoResult ->
            this.handleVenmoResult(result)
        }
    }

    private fun handleVenmoResult(result: VenmoResult) {
        Log.d("BraintreePaymentPlugin", "handleVenmoResult, intent: $intent, result: $result")

        when (result) {
            is VenmoResult.Success -> {
                handleSuccessResult(result)
            }

            is VenmoResult.Failure -> {
                val error = result.error
                handleErrorResult(error)
            }

            is VenmoResult.Cancel -> {
                handleCancelResult(result.toString())
            }
        }
    }

    private fun handleSuccessResult(result: VenmoResult.Success) {
        Log.d(
            "BraintreePaymentPlugin",
            "handleSuccessResult, VenmoResult Success, result: $result"
        )
        val nonce = result.nonce
        val nonceJson = JSONObject().apply {
            put("nonce", nonce.string)
            put("isDefault", nonce.isDefault)
            put("email", nonce.email ?: JSONObject.NULL)
            put("externalId", nonce.externalId ?: JSONObject.NULL)
            put("firstName", nonce.firstName ?: JSONObject.NULL)
            put("lastName", nonce.lastName ?: JSONObject.NULL)
            put("phoneNumber", nonce.phoneNumber ?: JSONObject.NULL)
            put("username", nonce.username)
        }

        val resultIntent = Intent().apply {
            putExtra(Constants.NONCE_KEY, nonceJson.toString())
        }
        setResult(Activity.RESULT_OK, resultIntent)
        finish()
    }

    private fun handleErrorResult(error: Exception) {
        Log.e(
            "BraintreePaymentPlugin",
            "VenmoActivity, handleErrorResult: ${error.localizedMessage}",
            error
        )
        val resultIntent = Intent().apply {
            putExtra(Constants.ERROR_KEY, error.toString())
        }
        setResult(Activity.RESULT_CANCELED, resultIntent)
        finish()
    }

    private fun handleCancelResult(message: String) {
        Log.d(
            "BraintreePaymentPlugin",
            "handleCancelResult, message: $message"
        )
        val resultIntent = Intent().apply {
            putExtra(Constants.CANCELED_KEY, message.toString())
        }
        setResult(Activity.RESULT_CANCELED, resultIntent)
        finish()
    }
}
