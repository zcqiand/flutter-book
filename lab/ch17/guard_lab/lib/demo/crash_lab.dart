// lib/demo/crash_lab.dart
// 分区降级边界：只守住自己包住的子树，命中构建异常时渲染降级面板而非让异常上抛。
// 与 main.dart 全局 ErrorWidget.builder 的分工：
// 边界内的构建异常被 try-catch 拦下、局部降级；没被任何边界包住的构建异常才落全局缝位
import 'package:flutter/material.dart';

typedef SubtreeBuilder = Widget Function(BuildContext context);

class CrashBoundary extends StatefulWidget {
  const CrashBoundary({super.key, required this.childBuilder});

  // 传 builder 而非现成 Widget：子树的 build 动作发生在边界的 try 里才拦得住
  final SubtreeBuilder childBuilder;

  @override
  State<CrashBoundary> createState() => _CrashBoundaryState();
}

class _CrashBoundaryState extends State<CrashBoundary> {
  @override
  Widget build(BuildContext context) {
    Widget? subtree;
    try {
      subtree = widget.childBuilder(context);
    } on Object catch (error) {
      debugPrint('[guard_lab][boundary] 分区降级：$error');
      // 重试即重跑一次 childBuilder：若故障源已消失，子树恢复正常渲染
      return _DegradedPanel(onRetry: () {
        setState(() {});
      });
    }
    return subtree;
  }
}

class _DegradedPanel extends StatelessWidget {
  const _DegradedPanel({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Text('该区域暂时不可用，其余功能不受影响'),
            TextButton(onPressed: onRetry, child: const Text('重试')),
          ],
        ),
      ),
    );
  }
}

class CrashLabPage extends StatefulWidget {
  const CrashLabPage({super.key});

  @override
  State<CrashLabPage> createState() => _CrashLabPageState();
}

class _CrashLabPageState extends State<CrashLabPage> {
  bool _breakSubtree = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('分区降级演练')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          FilledButton(
            onPressed: () {
              setState(() {
                _breakSubtree = true;
              });
            },
            child: const Text('人为崩溃：让子树 build 抛异常'),
          ),
          FilledButton(
            onPressed: () {
              // 复位故障源后再点降级面板里的重试，即可看到子树恢复
              setState(() {
                _breakSubtree = false;
              });
            },
            child: const Text('复位故障源（再点重试恢复子树）'),
          ),
          const SizedBox(height: 16),
          // 边界只包住这一小块：命中异常时局部降级，页面其余部分照常活着
          CrashBoundary(
            childBuilder: (BuildContext context) {
              if (_breakSubtree) {
                throw StateError('分区演练：人为崩溃');
              }
              return const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('子树运行正常'),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          const Text('边界外的这行字始终可读：局部崩、全局活'),
        ],
      ),
    );
  }
}
