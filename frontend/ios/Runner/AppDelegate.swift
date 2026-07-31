import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

    // UIKit Adaptive Brightness bridge (system brightness observer — not lux).
    if let registrar = engineBridge.pluginRegistry.registrar(
      forPlugin: "AdaptiveBrightnessPlugin"
    ) {
      AdaptiveBrightnessPlugin.register(with: registrar)
    }
  }
}
