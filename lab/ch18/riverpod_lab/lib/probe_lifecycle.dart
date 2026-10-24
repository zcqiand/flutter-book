// lib/probe_lifecycle.dart
// 清单 15-5 回执探针入口（自驱动：跑完 probeLifecycle 即 exit(0)，禁交互挂起）
// windows debug 直跑：flutter build windows --debug -t lib/probe_lifecycle.dart
import 'dart:io';

import 'package:riverpod_lab/features/article_detail_providers.dart';

Future<void> main() async {
  await probeLifecycle();
  // 给 stdout 一个排空间隙，确保全部探针行落盘后再退出
  await Future<void>.delayed(const Duration(milliseconds: 300));
  exit(0);
}
