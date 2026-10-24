// lib/main.dart
// 工程默认入口：ProviderScope 挂根 + 三态页（清单 15-6）。
// 实测探针入口另有专件：lib/probe_lifecycle.dart（清单 15-5）、
// lib/probe_tristate.dart（清单 15-7 三场景回归）
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:riverpod_lab/features/article_feed_page.dart';

void main() {
  runApp(const ProviderScope(child: MaterialApp(home: ArticleFeedPage())));
}
