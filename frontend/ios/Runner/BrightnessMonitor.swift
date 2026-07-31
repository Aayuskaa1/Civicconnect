import UIKit

/// Observes the *system* screen brightness on iOS.
///
/// iOS does **not** expose ambient light sensor lux values to third-party apps
/// (there is no public equivalent of Android's `Sensor.TYPE_LIGHT`).
/// Instead this class reads `UIScreen.main.brightness` and listens for
/// `UIScreen.brightnessDidChangeNotification`, which fires when the system's
/// own auto-brightness (driven by the hardware sensor), Control Center, or
/// Settings changes the screen brightness.
///
/// Callers should only use the value to adapt **in-app** UI — never to override
/// the system brightness.
final class BrightnessMonitor {
  static let shared = BrightnessMonitor()

  /// UserDefaults key for the Adaptive Brightness feature toggle (default: on).
  static let adaptiveEnabledKey = "adaptive_brightness_enabled"

  /// Closure invoked on the main queue whenever system brightness changes.
  var onBrightnessChanged: ((CGFloat) -> Void)?

  private var observer: NSObjectProtocol?

  private init() {}

  /// Current system brightness in the range `0.0...1.0`.
  var systemBrightness: CGFloat {
    UIScreen.main.brightness
  }

  /// Whether in-app Adaptive Brightness reactions are enabled (UserDefaults).
  var isAdaptiveEnabled: Bool {
    get {
      if UserDefaults.standard.object(forKey: Self.adaptiveEnabledKey) == nil {
        return true
      }
      return UserDefaults.standard.bool(forKey: Self.adaptiveEnabledKey)
    }
    set {
      UserDefaults.standard.set(newValue, forKey: Self.adaptiveEnabledKey)
    }
  }

  /// Starts observing `UIScreen.brightnessDidChangeNotification`.
  /// Safe to call repeatedly — previous observers are removed first.
  func start() {
    stop()

    observer = NotificationCenter.default.addObserver(
      forName: UIScreen.brightnessDidChangeNotification,
      object: UIScreen.main,
      queue: .main
    ) { [weak self] _ in
      guard let self else { return }
      self.onBrightnessChanged?(UIScreen.main.brightness)
    }

    // Emit the current value so listeners have an initial reading.
    onBrightnessChanged?(systemBrightness)
  }

  /// Removes the NotificationCenter observer.
  func stop() {
    if let observer {
      NotificationCenter.default.removeObserver(observer)
      self.observer = nil
    }
  }

  deinit {
    stop()
  }
}
