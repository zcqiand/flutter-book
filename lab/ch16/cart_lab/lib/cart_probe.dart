// lib/cart_probe.dart
// 自驱动探针：四方案逐一切换挂载，每组跑同一份七步脚本——
// 加购（重复加购数量+1）、逐项+1/-1（减到 0 移除）、结算行实时数、一键清空，
// 每步 debugPrint 标签行（CART_PROBE|方案|步骤|actual|expected|PASS/FAIL），跑完 exit(0)。
// 驱动方式：遍历 Element 树按图标/文案定位按钮并直接调用 onPressed，无任何交互等待。
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'versions/bloc_version.dart';
import 'versions/inherited_version.dart';
import 'versions/riverpod_version.dart';
import 'versions/setstate_version.dart';

class CartProbeApp extends StatefulWidget {
  const CartProbeApp({super.key, required this.logPath});
  final String logPath;
  @override
  State<CartProbeApp> createState() => _CartProbeAppState();
}

class _CartProbeAppState extends State<CartProbeApp> {
  Widget _scenario = const SizedBox.shrink();
  final GlobalKey _scenarioKey = GlobalKey();
  late final IOSink _logSink =
      File(widget.logPath).openWrite(mode: FileMode.writeOnly);

  void _log(String line) {
    debugPrint(line);
    _logSink.writeln(line);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _run().then((_) {}, onError: (Object e, StackTrace st) {
        _log('CART_PROBE|FATAL|$e');
        _logSink.close();
        exit(1);
      });
    });
  }

  Future<void> _run() async {
    final List<(String, Widget)> scenarios = <(String, Widget)>[
      ('setState', const SetStateCartPage()),
      ('inherited', const CartContainer(child: InheritedCartPage())),
      ('riverpod', const ProviderScope(child: RiverpodCartPage())),
      ('bloc', const BlocCartPage()),
    ];
    for (final (String name, Widget page) in scenarios) {
      await _drive(name, page);
    }
    _log('CART_PROBE|ALL_DONE');
    await _logSink.flush();
    await _logSink.close();
    exit(0);
  }

  Future<void> _drive(String name, Widget page) async {
    _log('CART_PROBE|BEGIN|$name');
    setState(() {
      _scenario = KeyedSubtree(key: _scenarioKey, child: page);
    });
    await _settle();
    for (final _ProbeStep step in _script) {
      await step.act(_Tree(_scenarioElement));
      await _settle();
      final String actual = _settlement();
      final bool ok = actual == step.expected;
      _log('CART_PROBE|$name|${step.label}|actual=$actual|expected=${step.expected}|${ok ? 'PASS' : 'FAIL'}');
    }
    _log('CART_PROBE|END|$name');
  }

  /// 四组断言七步脚本：所有方案逐字同一份（同题共答）
  static final List<_ProbeStep> _script = <_ProbeStep>[
    _ProbeStep('step1-加购键盘', (tree) => tree.tapShelfAdd('键盘'), '共 1 种，合计 199.00 元'),
    _ProbeStep('step2-重复加购键盘(数量+1)', (tree) => tree.tapShelfAdd('键盘'), '共 1 种，合计 398.00 元'),
    _ProbeStep('step3-加购鼠标与显示器', (tree) async {
      await tree.tapShelfAdd('鼠标');
      await tree.tapShelfAdd('显示器');
    }, '共 3 种，合计 1486.00 元'),
    _ProbeStep('step4-键盘-1', (tree) => tree.tapRow('键盘', Icons.remove_circle_outline), '共 3 种，合计 1287.00 元'),
    _ProbeStep('step5-键盘再-1(减到0移除)', (tree) => tree.tapRow('键盘', Icons.remove_circle_outline), '共 2 种，合计 1088.00 元'),
    _ProbeStep('step6-鼠标+1', (tree) => tree.tapRow('鼠标', Icons.add_circle_outline), '共 2 种，合计 1177.00 元'),
    _ProbeStep('step7-一键清空', (tree) => tree.tapClear(), '共 0 种，合计 0.00 元'),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: Scaffold(body: _scenario));
  }

  Element get _scenarioElement =>
      _scenarioKey.currentContext as Element;

  String _settlement() {
    String found = '';
    void visit(Element el) {
      final Widget w = el.widget;
      if (w is Text && (w.data ?? '').startsWith('共 ')) found = w.data!;
      el.visitChildren(visit);
    }
    _scenarioElement.visitChildren(visit);
    return found;
  }

  Future<void> _settle() async {
    await Future<void>.delayed(const Duration(milliseconds: 80));
  }
}

class _ProbeStep {
  const _ProbeStep(this.label, this.act, this.expected);
  final String label;
  final Future<void> Function(_Tree tree) act;
  final String expected;
}

/// Element 树驱动器：按图标与文案定位按钮，直接调 onPressed
class _Tree {
  const _Tree(this.root);
  final Element root;

  Future<void> tapShelfAdd(String name) async {
    final Element tile = _ancestor(_text(name), (Widget w) => w is ListTile);
    _invoke(_iconIn(tile, Icons.add_shopping_cart));
  }

  Future<void> tapRow(String name, IconData icon) async {
    final Element row =
        _ancestor(_textContaining('$name '), (Widget w) => w is Row);
    _invoke(_iconIn(row, icon));
  }

  Future<void> tapClear() async {
    final Element tile = _ancestor(
        _text('清空购物车'), (Widget w) => w is ListTile);
    final Element btn = _descendant(tile, (Widget w) => w is TextButton);
    _invoke(btn);
  }

  // —— 内部 ——
  Element _text(String data) => _first(root, (Element el) =>
      el.widget is Text && (el.widget as Text).data == data);
  Element _textContaining(String prefix) => _first(root, (Element el) =>
      el.widget is Text && ((el.widget as Text).data ?? '').startsWith(prefix));

  Element _iconIn(Element scope, IconData icon) => _first(
      scope,
      (Element el) {
        final Widget? w = el.widget is IconButton
            ? (el.widget as IconButton).icon
            : null;
        return w is Icon && w.icon == icon;
      });
  Element _descendant(Element scope, bool Function(Widget) test) =>
      _first(scope, (Element el) => test(el.widget));
  Element _ancestor(Element start, bool Function(Widget) test) {
    Element? found;
    start.visitAncestorElements((Element el) {
      if (test(el.widget)) {
        found = el;
        return false;
      }
      return true;
    });
    if (found == null) throw StateError('ancestor not found');
    return found!;
  }

  Element _first(Element scope, bool Function(Element) test) {
    if (test(scope)) return scope;
    Element? found;
    final List<Element> queue = <Element>[];
    scope.visitChildren(queue.add);
    while (queue.isNotEmpty && found == null) {
      final Element el = queue.removeAt(0);
      if (test(el)) {
        found = el;
        break;
      }
      el.visitChildren(queue.add);
    }
    if (found == null) throw StateError('element not found');
    return found;
  }

  void _invoke(Element buttonEl) {
    final Widget w = buttonEl.widget;
    if (w is IconButton) {
      w.onPressed?.call();
    } else if (w is TextButton) {
      w.onPressed?.call();
    } else {
      throw StateError('not a button: ${w.runtimeType}');
    }
  }
}
