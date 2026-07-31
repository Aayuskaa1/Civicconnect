import Flutter
import UIKit

/// Flutter bridge for [BrightnessMonitor].
///
/// Channels:
/// - MethodChannel `com.civicconnect/adaptive_brightness`
/// - EventChannel  `com.civicconnect/adaptive_brightness/stream`
///
/// Does not set system brightness — only reports it for in-app UI adaptation.
final class AdaptiveBrightnessPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
  private let monitor = BrightnessMonitor.shared
  private var eventSink: FlutterEventSink?

  static func register(with registrar: FlutterPluginRegistrar) {
    let instance = AdaptiveBrightnessPlugin()

    let methodChannel = FlutterMethodChannel(
      name: "com.civicconnect/adaptive_brightness",
      binaryMessenger: registrar.messenger()
    )
    registrar.addMethodCallDelegate(instance, channel: methodChannel)

    let eventChannel = FlutterEventChannel(
      name: "com.civicconnect/adaptive_brightness/stream",
      binaryMessenger: registrar.messenger()
    )
    eventChannel.setStreamHandler(instance)
  }

  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getSystemBrightness":
      result(Double(monitor.systemBrightness))

    case "getAdaptiveEnabled":
      result(monitor.isAdaptiveEnabled)

    case "setAdaptiveEnabled":
      guard let enabled = call.arguments as? Bool else {
        result(FlutterError(
          code: "bad_args",
          message: "Expected Bool for setAdaptiveEnabled",
          details: nil
        ))
        return
      }
      monitor.isAdaptiveEnabled = enabled
      result(nil)

    default:
      result(FlutterMethodNotImplemented)
    }
  }

  // MARK: - FlutterStreamHandler

  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    eventSink = events
    monitor.onBrightnessChanged = { [weak self] brightness in
      self?.eventSink?(Double(brightness))
    }
    monitor.start()
    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    monitor.stop()
    monitor.onBrightnessChanged = nil
    eventSink = nil
    return nil
  }
}
