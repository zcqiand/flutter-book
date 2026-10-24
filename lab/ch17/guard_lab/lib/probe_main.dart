// lib/probe_main.dart
// 验证臂专用自驱探针入口（验证臂工程件，不属正文清单，正文清单 17-3 为 lib/main.dart 保持逐字原样）。
// 用途：windows debug 直跑实抓清单 17-2 三层捕获日志与清单 17-9 存储三件套回执。
// 缝位逻辑逐字拷贝自清单 17-3（仅 debugPrint 被劫持为「文件+debugPrint 双通道」，
// GUI 子系统 stdout 收不到 print，capture 件以文件通道为唯一真相）。
// 驱动方式：exe 同目录放 GUARD_PROBE.flag 后直跑 exe；跑完 flush 落盘后 exit(0)。
//   flutter build windows --debug -t lib/probe_main.dart
import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'demo/exception_lab.dart';
import 'storage/settings_store.dart';
import 'storage/token_store.dart';

late IOSink _traceSink;
late IOSink _storeSink;

void main() {
  final Directory exeDir = File(Platform.resolvedExecutable).parent;
  _traceSink =
      File('${exeDir.path}\\three_layers_capture.log').openWrite(mode: FileMode.writeOnly);
  _storeSink = File('${exeDir.path}\\stores_capture.log').openWrite(mode: FileMode.writeOnly);

  // debugPrint 劫持为双通道：真异常日志经它原样入 capture（含 main 缝位同款标签行）
  final void Function(String?, {int? wrapWidth}) rawDebugPrint = debugPrint;
  debugPrint = (String? message, {int? wrapWidth}) {
    _traceSink.writeln(message);
    rawDebugPrint(message, wrapWidth: wrapWidth);
  };

  // ===== 以下三缝位逐字同清单 17-3（lib/main.dart），仅宿主换成探针 =====
  FlutterError.onError = (FlutterErrorDetails details) {
    debugPrint('[guard_lab][framework] ${details.exception}');
    FlutterError.presentError(details);
  };

  ErrorWidget.builder = (FlutterErrorDetails details) {
    if (kReleaseMode) {
      return const ColoredBox(
        color: Color(0xFF9E9E9E),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                '页面出了点问题，我们正在修复',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
      );
    }
    return ErrorWidget(details.exception);
  };

  runZonedGuarded(() {
    runApp(const _ProbeApp());
  }, (Object error, StackTrace stackTrace) {
    debugPrint('[guard_lab][zone] $error');
  });
}

class _ProbeApp extends StatefulWidget {
  const _ProbeApp();

  @override
  State<_ProbeApp> createState() => _ProbeAppState();
}

class _ProbeAppState extends State<_ProbeApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _run().then((_) {}, onError: (Object e, StackTrace st) {
        _traceSink.writeln('GUARD_PROBE|FATAL|$e');
        _finish(1);
      });
    });
  }

  Future<void> _run() async {
    _traceSink.writeln('GUARD_PROBE|BEGIN|清单17-2 三层捕获');
    await _settle();

    // 层一「同步」：直接调触发函数，try-catch 就地捕获（标签行入 capture）
    _traceSink.writeln('GUARD_PROBE|LAYER|sync');
    triggerSyncException();
    await _settle();

    // 层二「异步逃逸」：不 await 不 catch，异常落到 runZonedGuarded 回调
    _traceSink.writeln('GUARD_PROBE|LAYER|async-escape');
    triggerAsyncEscape();
    await _settle();

    // 层三「框架层」：按正文按钮（Element 树定位 onPressed），build 抛出归 FlutterError
    _traceSink.writeln('GUARD_PROBE|LAYER|framework');
    _pressByText('触发框架层异常（build 内抛出）');
    await _settle();
    await _settle();

    _traceSink.writeln('GUARD_PROBE|END|清单17-2 三层捕获');

    await _driveStores();

    _storeSink.writeln('GUARD_STORE|ALL_DONE');
    await _finish(0);
  }

  /// 清单 17-9 存储三件套实测（settings/token 走 Windows 真插件；
  /// cache 的 sqflite 在 Windows 无基础包平台实现，回执由 ffi widget test 提供）
  Future<void> _driveStores() async {
    void step(String scheme, String label, String actual, String expected) {
      final bool ok = actual == expected;
      _storeSink.writeln(
          'GUARD_STORE|$scheme|$label|actual=$actual|expected=$expected|${ok ? 'PASS' : 'FAIL'}');
    }

    _storeSink.writeln('GUARD_STORE|BEGIN|settings(shared_preferences)');
    final SettingsStore settings = SettingsStore();
    await settings.saveThemeMode(1);
    final int mode = await settings.loadThemeMode();
    step('settings', 'step1-写theme_mode=1再读', '$mode', '1');
    await settings.saveNoticeEnabled(false);
    final bool notice = await settings.loadNoticeEnabled();
    step('settings', 'step2-写notice=false再读', '$notice', 'false');
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('guard_lab.settings.theme_mode');
    await prefs.remove('guard_lab.settings.notice_enabled');
    final int modeAfterDelete = await settings.loadThemeMode();
    final bool noticeAfterDelete = await settings.loadNoticeEnabled();
    step('settings', 'step3-删键后读回默认',
        'theme_mode=$modeAfterDelete,notice=$noticeAfterDelete', 'theme_mode=0,notice=true');

    _storeSink.writeln('GUARD_STORE|BEGIN|token(flutter_secure_storage)');
    const TokenStore token = TokenStore();
    const String demoToken = 'demo-token-0123456789abcdef';
    final String? initial = await token.read();
    step('token', 'step1-未写先读', initial ?? 'null', 'null');
    await token.write(demoToken);
    final String? stored = await token.read();
    step('token', 'step2-写后读', stored ?? 'null', demoToken);
    await token.delete();
    final String? afterDelete = await token.read();
    step('token', 'step3-删后读', afterDelete ?? 'null', 'null');

    _storeSink.writeln('GUARD_STORE|BEGIN|cache(sqflite)');
    _storeSink.writeln('GUARD_STORE|cache|SKIPPED|sqflite 基础包 Windows 无平台实现，'
        'cache 段回执由 sqflite_common_ffi widget test 提供（test/receipts/17_9_cache.txt）');
  }

  Future<void> _finish(int code) async {
    await _traceSink.flush();
    await _storeSink.flush();
    await _traceSink.close();
    await _storeSink.close();
    exit(code);
  }

  // Element 树按文案定位 FilledButton 并直接调 onPressed（cart_lab 同款工艺）
  void _pressByText(String label) {
    void visit(Element el) {
      final Widget w = el.widget;
      if (w is Text && w.data == label) {
        Element? ancestor = el;
        while (ancestor != null && ancestor.widget is! FilledButton) {
          Element? next;
          ancestor.visitAncestorElements((Element e) {
            next = e;
            return false;
          });
          ancestor = next;
        }
        if (ancestor != null) {
          final FilledButton button = ancestor.widget as FilledButton;
          button.onPressed?.call();
        }
        return;
      }
      el.visitChildren(visit);
    }
    visit((context as Element));
  }

  Future<void> _settle() async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
  }

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: ExceptionLabPage());
  }
}
