// lib/probe_tristate.dart
// 清单 15-7 回执探针入口（自驱动：六条断言打完即 exit(0)，禁交互挂起）
// windows debug 直跑：flutter build windows --debug -t lib/probe_tristate.dart
// MockScenario 依次置 success/empty/serverError 逐一回归，四态渲染断言 P01-P06
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:riverpod_lab/core/feed_providers.dart';
import 'package:riverpod_lab/features/article_feed_page.dart';

final GlobalKey pageKey = GlobalKey();

void probe(String msg) => debugPrint('PROBE-F: $msg');

/// 头像 NetworkImage 指向不存在域名，失败转储会污染 stdout capture；
/// 探针断言只看组件树形态，图像错误在此静默吞掉
void _swallowImageErrors(FlutterErrorDetails details) {}

void _collectElements(Element element, List<Element> out) {
  out.add(element);
  element.visitChildElements((Element child) => _collectElements(child, out));
}

/// 从页面 GlobalKey 出发收集整棵子树元素
List<Element> pageElements() {
  final List<Element> out = <Element>[];
  final BuildContext? context = pageKey.currentContext;
  if (context != null) {
    _collectElements(context as Element, out);
  }
  return out;
}

bool hasWidgetType(Type t) =>
    pageElements().any((Element e) => e.widget.runtimeType == t);

int countWidgetType(Type t) =>
    pageElements().where((Element e) => e.widget.runtimeType == t).length;

bool hasText(String s) {
  for (final Element e in pageElements()) {
    final Widget w = e.widget;
    if (w is Text && w.data != null && w.data!.contains(s)) {
      return true;
    }
  }
  return false;
}

/// 按钮标签找 ElevatedButton，返回其 onPressed（探针模拟按下）
void Function()? findButtonAction(String label) {
  for (final Element e in pageElements()) {
    final Widget w = e.widget;
    if (w is ElevatedButton &&
        w.child is Text &&
        (w.child as Text).data == label) {
      return w.onPressed;
    }
  }
  return null;
}

String? firstTileTitle() {
  for (final Element e in pageElements()) {
    final Widget w = e.widget;
    if (w is ListTile && w.title is Text) {
      return (w.title as Text).data;
    }
  }
  return null;
}

Future<void> waitUntil(String describe, bool Function() test) async {
  final Stopwatch sw = Stopwatch()..start();
  while (!test()) {
    if (sw.elapsed > const Duration(seconds: 10)) {
      throw StateError('探针超时: $describe');
    }
    await Future<void>.delayed(const Duration(milliseconds: 25));
  }
}

/// 数据态没有「重新加载」按钮（按钮只在空态/错误态出场），
/// 数据态回拉经容器直呼 notifier.load()——与按钮 onPressed 同一条调用路径
void triggerLoadFromContainer() {
  final BuildContext? context = pageKey.currentContext;
  if (context == null) {
    throw StateError('页面 context 不存在');
  }
  ProviderScope.containerOf(context)
      .read(feedNotifierProvider.notifier)
      .load();
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterError.onError = _swallowImageErrors;
  MockFeedRepository.scenario = MockScenario.success;
  runApp(ProviderScope(
    child: MaterialApp(home: ArticleFeedPage(key: pageKey)),
  ));
  SchedulerBinding.instance.scheduleForcedFrame();

  try {
    await _runProbe();
  } catch (e) {
    // 断言失败也必须自退：探针禁交互挂起
    probe('探针异常退出: $e');
    await Future<void>.delayed(const Duration(milliseconds: 300));
    exit(1);
  }
  // 给 stdout 一个排空间隙，确保全部探针行落盘后再退出
  await Future<void>.delayed(const Duration(milliseconds: 300));
  exit(0);
}

Future<void> _runProbe() async {
  // [P01] success 场景：首拉完成落 data 态，ListView 渲染 2 条，首条 title 含「拦截器」
  await waitUntil(
      'P01 data 态',
      () =>
          hasWidgetType(ListView) &&
          countWidgetType(ListTile) == 2 &&
          (firstTileTitle()?.contains('拦截器') ?? false));
  probe('P01 success 场景: status=data, ListView 渲染 2 条, ListTile 首条 title 含「拦截器」');

  // [P02] 数据态回拉：重新加载 → loading → 回到 data（经容器直呼，同按钮路径）
  triggerLoadFromContainer();
  await waitUntil('P02 loading 转场', () => hasWidgetType(CircularProgressIndicator));
  await waitUntil(
      'P02 回到 data',
      () => hasWidgetType(ListView) && countWidgetType(ListTile) == 2);
  probe('P02 success 场景: 按下「重新加载」→ loading 态 → 回到 data 态');

  // [P03] 切 empty 场景重新加载：空态分支命中（数据态无按钮，经容器触发）
  MockFeedRepository.scenario = MockScenario.empty;
  triggerLoadFromContainer();
  await waitUntil(
      'P03 empty 态', () => hasText('暂无文章') && findButtonAction('重新加载') != null);
  probe('P03 empty 场景: status=empty, 「暂无文章」可见');

  // [P04] 空态回拉：重新加载 → loading → 回到 empty
  findButtonAction('重新加载')!();
  await waitUntil('P04 loading 转场', () => hasWidgetType(CircularProgressIndicator));
  await waitUntil('P04 回到 empty', () => hasText('暂无文章'));
  probe('P04 empty 场景: 按下「重新加载」→ loading 态 → 回到 empty 态');

  // [P05] 切 serverError 场景重新加载：错误态分支命中
  MockFeedRepository.scenario = MockScenario.serverError;
  findButtonAction('重新加载')!();
  await waitUntil(
      'P05 error 态', () => hasText('加载失败，请稍后重试') && findButtonAction('重试') != null);
  probe('P05 serverError 场景: status=error, 错误文案可见');

  // [P06] 错误态回拉：重试 → loading → 回到 error
  findButtonAction('重试')!();
  await waitUntil('P06 loading 转场', () => hasWidgetType(CircularProgressIndicator));
  await waitUntil('P06 回到 error', () => hasText('加载失败，请稍后重试'));
  probe('P06 serverError 场景: 按下「重试」→ loading 态 → 回到 error 态');
}
