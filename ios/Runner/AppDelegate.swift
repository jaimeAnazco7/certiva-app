import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // SOLUCIÓN CRASH path_provider_foundation en iOS 18.7.1
    // Retrasar el registro de plugins para evitar EXC_BAD_ACCESS (SIGSEGV)
    // Delay reducido a 1.0s (Compromiso Gemini + Mac Virtual)
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
      GeneratedPluginRegistrant.register(with: self)
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
