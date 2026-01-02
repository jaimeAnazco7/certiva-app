import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Retrasar el registro de plugins para evitar crash en path_provider
    // Los plugins se registran después de que iOS esté completamente inicializado
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
      GeneratedPluginRegistrant.register(with: self)
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
