import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  private var screenshotChannel: FlutterMethodChannel?
  private var isCapturedObserver: NSKeyValueObservation?
  
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    screenshotChannel = FlutterMethodChannel(name: "com.teentalk.app/screenshot",
                                              binaryMessenger: controller.binaryMessenger)
    
    screenshotChannel?.setMethodCallHandler({ [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
      if call.method == "startScreenCaptureDetection" {
        self?.startScreenCaptureDetection()
        result(nil)
      } else {
        result(FlutterMethodNotImplemented)
      }
    })
    
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(didTakeScreenshot),
      name: UIApplication.userDidTakeScreenshotNotification,
      object: nil
    )
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  private func startScreenCaptureDetection() {
    if #available(iOS 11.0, *) {
      isCapturedObserver = UIScreen.main.observe(\.isCaptured, options: [.new]) { [weak self] (screen, change) in
        if let isCaptured = change.newValue {
          self?.screenshotChannel?.invokeMethod("onScreenCaptureChanged", arguments: isCaptured)
        }
      }
    }
  }
  
  @objc private func didTakeScreenshot() {
    screenshotChannel?.invokeMethod("onScreenshotDetected", arguments: nil)
  }
  
  override func applicationWillTerminate(_ application: UIApplication) {
    NotificationCenter.default.removeObserver(self)
    isCapturedObserver?.invalidate()
    super.applicationWillTerminate(application)
  }
}
