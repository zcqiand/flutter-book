// MainActivity.kt
// Android 侧电量实现：注册通道、接方法名、读系统服务、按协议回传
// 申报：本机无 Android SDK，此侧未编译未实测，代码走读兑现（与第 20 章 Android 失败申报同口径）
package com.example.channel_lab

import android.content.Context
import android.os.BatteryManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

// 通道名与 Dart 侧逐字一致：这是两端唯一的握手凭据，改一端必同步改另一端
private const val CHANNEL = "samples.channel_lab/battery"

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // messenger 是 Dart 与宿主之间的信使：通道实例必须挂在它身上
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    // 读电量属系统信息查询，不需要运行时权限声明
                    "getBatteryLevel" -> {
                        val bm = getSystemService(Context.BATTERY_SERVICE)
                            as BatteryManager
                        val level =
                            bm.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY)
                        if (level > 0) {
                            result.success(level)
                        } else {
                            // 缺值回 error 而非 success(null)：
                            // null 回传在 Dart 侧难以与「成功但为空」区分
                            result.error("UNAVAILABLE", "电量值不可用", null)
                        }
                    }
                    // 未注册的方法名显式回 notImplemented，
                    // 让 Dart 侧拿到明确信号而不是静默挂起
                    else -> result.notImplemented()
                }
            }
    }
}