import Braintree
import Flutter
import Foundation

public class BraintreePaymentPlugin: NSObject, FlutterPlugin {

    private var flutterResult: FlutterResult?

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "braintree_payment", binaryMessenger: registrar.messenger())
        let instance = BraintreePaymentPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        debugPrint("BraintreePaymentPlugin registered successfully")
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        debugPrint("Method called: \(call.method)")

        self.flutterResult = result

        switch call.method {
        case Constants.VENMO_PAYMENT_METHOD_KEY:
            handleVenmoPayment(call.arguments)
        case Constants.PAYPAL_PAYMENT_METHOD_KEY:
            handlePayPalPayment(call.arguments)
        default:
            debugPrint("Method not implemented: \(call.method)")
            result(FlutterMethodNotImplemented)
        }
    }

    // MARK: - Venmo Payment Flow
    private func handleVenmoPayment(_ arguments: Any?) {
        guard let args = arguments as? [String: Any] else { return }

        // Extract parameters
        guard let token = args[Constants.TOKEN_KEY] as? String else {
            flutterResult?(
                FlutterError(code: Constants.ERROR_KEY, message: "Token is missing", details: nil))
            return
        }

        guard
            let iosUniversalLinkReturnUrl = args[Constants.IOS_UNIVERSAL_LINK_RETURN_URL] as? String
        else {
            flutterResult?(
                FlutterError(
                    code: Constants.IOS_UNIVERSAL_LINK_RETURN_URL,
                    message: "Universal Link Return URL is missing", details: nil))
            return
        }

        let displayName = args[Constants.DISPLAY_NAME_KEY] as? String
        let amountString = args[Constants.AMOUNT_KEY] as? String

        debugPrint(
            "Starting Venmo flow with displayName: \(displayName ?? "N/A"), amount: \(amountString ?? "0")"
        )

        let universalLink = URL(string: iosUniversalLinkReturnUrl)

        let apiClient = BTAPIClient(authorization: token)
        let venmoClient = BTVenmoClient(
            apiClient: apiClient!,
            universalLink: universalLink!
        )

        let venmoRequest = BTVenmoRequest(paymentMethodUsage: .multiUse)
        venmoRequest.displayName = displayName
        venmoRequest.totalAmount = amountString

        //        venmoRequest.fallbackToWeb = true

        venmoClient.tokenize(venmoRequest) { venmoAccount, error in
            if let error = error {
                debugPrint("venmoClient.tokenize: error: \(error)")
                self.handleError(error)
            } else if let venmoAccount = venmoAccount {
                debugPrint("venmoClient.tokenize: venmoAccount: \(venmoAccount)")
                self.handleSuccess(venmoAccount: venmoAccount)
            } else {
                debugPrint("venmoClient.tokenize: cancel")
                self.handleCancellation()
            }
        }
    }

    // MARK: - PayPal Payment Flow
    private func handlePayPalPayment(_ arguments: Any?) {
        guard let args = arguments as? [String: Any] else { return }
        guard let token = args[Constants.TOKEN_KEY] as? String,
            let amountString = args[Constants.AMOUNT_KEY] as? String

        else {
            flutterResult?(
                FlutterError(
                    code: Constants.ERROR_KEY, message: "Missing required parameters", details: nil)
            )
            return
        }
        let currencyCode = args[Constants.CURRENCY_CODE_KEY] as? String

        // Initialize Braintree API Client
        guard let apiClient = BTAPIClient(authorization: token) else {
            flutterResult?(
                FlutterError(
                    code: Constants.ERROR_KEY, message: "Invalid Braintree token", details: nil))
            return
        }

        let payPalClient = BTPayPalClient(apiClient: apiClient)
        let request = BTPayPalCheckoutRequest(amount: amountString, currencyCode: currencyCode)

        // Tokenize PayPal payment
        payPalClient.tokenize(request) { tokenizedPayPalAccount, error in
            if let error = error {
                self.handleError(error)
            } else if let tokenizedPayPalAccount = tokenizedPayPalAccount {
                self.handleSuccess(payPalAccount: tokenizedPayPalAccount)
            } else {
                self.handleCancellation()
            }
        }
    }

    // MARK: - Common Handlers
    private func handleError(_ error: Error) {
        debugPrint("ERROR: \(error.localizedDescription)")
        flutterResult?(
            FlutterError(
                code: Constants.ERROR_KEY, message: error.localizedDescription, details: nil))
    }

    private func handleCancellation() {
        debugPrint("Payment was canceled")
        flutterResult?(
            FlutterError(
                code: Constants.CANCELED_KEY, message: "Payment was canceled", details: nil))
    }

    private func handleSuccess(venmoAccount: BTVenmoAccountNonce) {
        debugPrint("VENMO_SUCCESS: Nonce - \(venmoAccount.nonce)")

        let nonceJson: [String: Any?] = [
            "nonce": venmoAccount.nonce,
            "isDefault": venmoAccount.isDefault,
            "firstName": venmoAccount.firstName ?? nil,
            "lastName": venmoAccount.lastName ?? nil,
            "phoneNumber": venmoAccount.phoneNumber ?? nil,
            "email": venmoAccount.email ?? nil,
            "externalId": venmoAccount.externalID ?? nil,
        ]

        sendSuccessResponse(nonceJson: nonceJson)
    }

    private func handleSuccess(payPalAccount: BTPayPalAccountNonce) {
        debugPrint("PAYPAL_SUCCESS: Nonce - \(payPalAccount.nonce)")

        let nonceJson: [String: Any?] = [
            "nonce": payPalAccount.nonce,
            "isDefault": payPalAccount.isDefault,
            "clientMetadataId": payPalAccount.clientMetadataID ?? nil,
            "firstName": payPalAccount.firstName ?? nil,
            "lastName": payPalAccount.lastName ?? nil,
            "phone": payPalAccount.phone ?? nil,
            "email": payPalAccount.email ?? nil,
            "payerId": payPalAccount.payerID ?? nil,
        ]

        sendSuccessResponse(nonceJson: nonceJson)
    }

    private func sendSuccessResponse(nonceJson: [String: Any?]) {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: nonceJson, options: [])
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                flutterResult?(jsonString)
            } else {
                flutterResult?(
                    FlutterError(
                        code: "ERROR", message: "Failed to convert JSON to string", details: nil))
            }
        } catch {
            flutterResult?(
                FlutterError(
                    code: "ERROR", message: "Failed to serialize JSON",
                    details: error.localizedDescription))
        }
    }
}

public struct Constants {
    static let VENMO_PAYMENT_METHOD_KEY = "venmoPayment"
    static let PAYPAL_PAYMENT_METHOD_KEY = "paypalPayment"

    // Request keys
    static let TOKEN_KEY = "token"
    static let AMOUNT_KEY = "amount"
    static let CURRENCY_CODE_KEY = "currencyCode"
    static let IOS_UNIVERSAL_LINK_RETURN_URL = "iosUniversalLinkReturnUrl"
    static let DISPLAY_NAME_KEY = "displayName"

    // Response keys
    static let NONCE_KEY = "nonce"
    static let CANCELED_KEY = "canceled"
    static let ERROR_KEY = "error"
}
