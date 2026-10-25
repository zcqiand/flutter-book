// lib/main.dart
// 载体应用全件：一个按钮向宿主要电量，Dart 侧只发方法名，实现在原生侧
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(const ChannelLabApp());

// 通道名与 Android/iOS 两侧注册的字符串逐字一致：
// 两端任何一端多一个字符，调用就在对端落空，这是平台通道的第一纪律
const MethodChannel _batteryChannel =
    MethodChannel('samples.channel_lab/battery');

class ChannelLabApp extends StatelessWidget {
  const ChannelLabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'channel_lab',
      home: const BatteryPage(),
    );
  }
}

class BatteryPage extends StatefulWidget {
  const BatteryPage({super.key});

  @override
  State<BatteryPage> createState() => _BatteryPageState();
}

class _BatteryPageState extends State<BatteryPage> {
  String _message = '尚未读取';

  // 读电量是宿主能力：Dart 侧无参调用、回传 int，
  // 编解码走 StandardMethodCodec 默认档，零自定义编解码器
  Future<void> _readBatteryLevel() async {
    try {
      final int? level =
          await _batteryChannel.invokeMethod<int>('getBatteryLevel');
      // 原生侧约定「缺值回 error」：null 回传属协议违规，按失败面处理
      if (level == null) {
        setState(() => _message = '读取失败：宿主回传为空');
        return;
      }
      setState(() => _message = '当前电量：$level%');
    } on PlatformException catch (e) {
      // 宿主在、读失败：原生侧的 code 与 message 原样传回，按宿主口径展示
      setState(() => _message = '读取失败：${e.message ?? e.code}');
    } on MissingPluginException {
      // 宿主侧无实现时抛出，Windows desktop 载体即此形态：
      // 通道在 Dart 侧已声明，但该平台没有任何原生实现注册
      setState(() => _message = '当前平台未实现电量通道');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('电量通道')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_message),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _readBatteryLevel,
              child: const Text('读取电量'),
            ),
          ],
        ),
      ),
    );
  }
}