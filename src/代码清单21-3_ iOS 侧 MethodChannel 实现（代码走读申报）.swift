// AppDelegate.swift
// 申报：本机无 macOS，此侧未编译未实测，代码走读兑现（与第 20 章 Android 失败申报同口径）
import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // 通道名与 Dart/Kotlin 两侧逐字一致；messenger 从自带的 FlutterViewController 取
    guard let controller = window?.rootViewController as? FlutterViewController else {
      return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    let channel = FlutterMethodChannel(
      name: "samples.channel_lab/battery",
      binaryMessenger: controller.binaryMessenger
    )
    channel.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) in
      switch call.method {
      case "getBatteryLevel":
        // 监测启用必须前置：未启用监测时 batteryState 恒为 .unknown、batteryLevel 恒为 -1，
        // 以状态当启用判据的写法判据恒假，电量永远读不出
        UIDevice.current.isBatteryMonitoringEnabled = true
        let level = Int(UIDevice.current.batteryLevel)
        if level >= 0 {
          result(level)
        } else {
          // level -1（state .unknown）是未启用监测或无电池的信号：
          // 模拟器与无电池设备自然落入本失败面
          result(FlutterError(code: "UNAVAILABLE",
                              message: "电量值不可用",
                              details: nil))
        }
      default:
        // 与 Kotlin 侧同约定：未注册的方法名回明确信号
        result(FlutterMethodNotImplemented)
      }
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}