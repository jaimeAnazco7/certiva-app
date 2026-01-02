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
    // Aumentado a 2.0 segundos porque 0.5s no era suficiente (crash en compilación 5)
    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
      GeneratedPluginRegistrant.register(with: self)
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
