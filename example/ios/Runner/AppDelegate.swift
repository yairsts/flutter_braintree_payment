import Braintree
import Flutter

@main
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication, continue userActivity: NSUserActivity,
        restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
    ) -> Bool {
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb {
            if let url = userActivity.webpageURL {
                print("Received Universal Link: \(url)")
                print("scheme: \(url.scheme)")
                print("url.path: \(url.path)")
                if url.scheme == "https" && url.host == "example.braintree.com"
                    && url.path.contains("/braintree-payments")
                {
                    print("Processing Universal Link: \(url)")
                    BTAppContextSwitcher.sharedInstance.handleOpen(url)

                }
            }
        }
        return true
    }
}
