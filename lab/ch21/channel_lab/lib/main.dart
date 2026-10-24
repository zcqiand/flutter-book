// lib/main.dart
// 载体应用全件：一个按钮向宿主要电量，Dart 侧只发方法名，实现在原生侧
// 实测臂注：本实物 = 清单 21-1 全件 ＋ 清单 21-5 段一（API_BASE_URL 回显）
//           ＋ 清单 21-8 接线增量（l10n 中英切换）；
//           另为回执抓取加 debugPrint 锚点行与读取按钮 autofocus（键盘 SPACE 可触发），
//           与清单 21-1 的差异逐条登记于 chapter-021.verify.md 缺陷单 D 系列。
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// 实测臂注：Flutter 3.47.6 已移除 synthetic package（package:flutter_gen/gen_l10n/
// 形态不可用），生成物直接落 lib/l10n/，import 按实物路径写（差异登记缺陷单）
import 'package:channel_lab/l10n/app_localizations.dart';

// 通道名与 Android/iOS 两侧注册的字符串逐字一致：
// 两端任何一端多一个字符，调用就在对端落空，这是平台通道的第一纪律
const MethodChannel _batteryChannel =
    MethodChannel('samples.channel_lab/battery');

// --dart-define 在编译期注入键值：const 保证它在编译期定值，运行期零查找开销
// 用法：flutter run --dart-define=API_BASE_URL=https://dev.example.com
const String apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'https://dev.example.com',
);

void main() => runApp(const ChannelLabApp());

class ChannelLabApp extends StatefulWidget {
  const ChannelLabApp({super.key});

  @override
  State<ChannelLabApp> createState() => _ChannelLabAppState();
}

class _ChannelLabAppState extends State<ChannelLabApp> {
  // State 里持一个 Locale 字段，切换即重建（清单 21-8 接线增量）
  Locale _locale = const Locale('zh');

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) =>
          AppLocalizations.of(context)!.title,
      locale: _locale,
      // delegates 把取词能力接进控件树；supportedLocales 声明支持清单
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const BatteryPage(),
    );
  }

  void toggleLocale() {
    setState(() {
      _locale = _locale == const Locale('zh')
          ? const Locale('en')
          : const Locale('zh');
    });
    debugPrint('ACTION localeToggled -> $_locale'); // 实测抓取锚点
  }
}

class BatteryPage extends StatefulWidget {
  const BatteryPage({super.key});

  @override
  State<BatteryPage> createState() => _BatteryPageState();
}

class _BatteryPageState extends State<BatteryPage> {
  String _message = '';

  // 读电量是宿主能力：Dart 侧无参调用、回传 int，
  // 编解码走 StandardMethodCodec 默认档，零自定义编解码器
  Future<void> _readBatteryLevel() async {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    debugPrint('ACTION readBattery invoked'); // 实测抓取锚点
    try {
      final int? level =
          await _batteryChannel.invokeMethod<int>('getBatteryLevel');
      // 原生侧约定「缺值回 error」：null 回传属协议违规，按失败面处理
      if (level == null) {
        setState(() => _message = l10n.hostNull);
        debugPrint('RESULT batteryLevel=null (protocol violation path)');
        return;
      }
      setState(() => _message = l10n.batteryLevel(level));
      debugPrint('RESULT batteryLevel=$level');
    } on PlatformException catch (e) {
      // 宿主在、读失败：原生侧的 code 与 message 原样传回，按宿主口径展示
      setState(() => _message = l10n.failWith(e.message ?? e.code));
      debugPrint(
          'RESULT PlatformException code=${e.code} message=${e.message}');
    } on MissingPluginException {
      // 宿主侧无实现时抛出，Windows desktop 载体即此形态：
      // 通道在 Dart 侧已声明，但该平台没有任何原生实现注册
      setState(() => _message = l10n.channelMissing);
      debugPrint('RESULT MissingPluginException: '
          'no implementation registered for samples.channel_lab/battery');
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('API_BASE_URL: $apiBaseUrl'), // 清单 21-5 段一回显
            const SizedBox(height: 16),
            Text(_message.isEmpty ? l10n.notReadYet : _message),
            const SizedBox(height: 16),
            ElevatedButton(
              autofocus: true, // 实测臂注：键盘 SPACE 可触发读取（抓回执用）
              onPressed: _readBatteryLevel,
              child: Text(l10n.helloButton),
            ),
            const SizedBox(height: 16),
            // 切换按钮示意：点按在 zh 与 en 之间翻转，MaterialApp 承接重建
            ElevatedButton(
              onPressed: () =>
                  context.findAncestorStateOfType<_ChannelLabAppState>()
                      ?.toggleLocale(),
              child: Text(
                  l10n.localeName == 'zh' ? 'English' : '中文'),
            ),
          ],
        ),
      ),
    );
  }
}
