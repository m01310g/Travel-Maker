import UIKit
import Flutter
import GoogleMaps // Google Maps import

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Google Maps API 키를 제공합니다. "YOUR_API_KEY"를 실제 API 키로 교체하세요.
    GMSServices.provideAPIKey("***REMOVED***")

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
