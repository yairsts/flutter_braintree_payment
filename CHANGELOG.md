# Changelog

## [1.0.0] - 2025-04-03
- Initial release.
## [1.1.0] - 2025-07-01
- Add PayPal Payment Intent and User Action Support
## [1.2.0] - 2025-12-30
- Fix android app link scheme
## [1.3.0] - 2025-12-30
- Handle cancellation flow in iOS
## [1.3.1] - 2026-09-23
- Returning from PayPal or Venmo no longer crashes when Android reclaimed the app while the payment was open; the payment is reported as cancelled instead.
- Drop the unused drop-in dependency, which was adding its own externally reachable screen to every app using this plugin.
## [2.0.0] - 2026-10-14
- **Breaking (iOS):** a cancelled PayPal or Venmo payment now completes with `null`, as it always did on Android. It used to throw a `PlatformException` with code `canceled`. A failed payment still throws a `PlatformException` with code `error` on both platforms.
- Android: an activity result with no nonce, error or cancel extra now completes with `null` instead of leaving the call waiting forever, and a second activity result can no longer reply to a call that was already answered.
## [2.0.1] - 2026-10-14
- iOS: a cancelled Venmo payment now completes with `null`, like PayPal. It used to throw a `PlatformException` with code `error`.
