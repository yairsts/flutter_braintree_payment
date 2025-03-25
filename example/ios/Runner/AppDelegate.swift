import Flutter
import Braintree

@main
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        debugPrint("\(Bundle.main.bundleIdentifier ?? "").payments")
        BTAppContextSwitcher.sharedInstance.returnURLScheme = "\(Bundle.main.bundleIdentifier ?? "").payments"
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        debugPrint("url.scheme: \(url.scheme)")

        if url.scheme?.localizedCaseInsensitiveCompare("\(Bundle.main.bundleIdentifier ?? "").payments") == .orderedSame {
            return BTAppContextSwitcher.sharedInstance.handleOpen(url)
        }
        return false
    }
     
}
