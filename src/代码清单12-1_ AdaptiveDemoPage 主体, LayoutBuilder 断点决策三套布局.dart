import 'package:flutter/material.dart';

void main() => runApp(const ResponsiveLabApp());

class ResponsiveLabApp extends StatelessWidget {
  const ResponsiveLabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'responsive_lab',
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: const AdaptiveDemoPage(),
    );
  }
}

// 断点集中声明, 三套布局分支引用同一份, 避免各处魔法数字各自漂移
// 取值依据: Material 3 官方窗口宽度分档, 600 以下 compact(典型手机竖屏),
// 600 到 840 之间 medium(平板双栏), 840 以上 expanded(桌面窗口)
const double kMediumBreakpoint = 600;
const double kExpandedBreakpoint = 840;

class AdaptiveDemoPage extends StatelessWidget {
  const AdaptiveDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('一页三套布局')),
      // 用 LayoutBuilder 而不是 MediaQuery 拿宽度做断点:
      // 本页决策依据是「父级给本页的约束」, 不是屏幕尺寸,
      // 窗口拖拽缩放时约束实时变化, build 随之重跑, 三套布局同页实时切换
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double width = constraints.maxWidth;
          if (width >= kExpandedBreakpoint) {
            return const _ThreeColumnLayout();
          }
          if (width >= kMediumBreakpoint) {
            return const _TwoColumnLayout();
          }
          return const _SingleColumnLayout();
        },
      ),
    );
  }
}

// 手机竖屏单列: 纵向滚动, 信息按优先级从上到下排
class _SingleColumnLayout extends StatelessWidget {
  const _SingleColumnLayout();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        _SectionCard(title: '今日概览', detail: '单列布局, 竖向滚动优先'),
        _SectionCard(title: '消息流', detail: '宽度有限, 一屏只讲一件事'),
        _SectionCard(title: '设置入口', detail: '次要操作沉底'),
      ],
    );
  }
}

// 平板双栏: 左窄导航右宽内容, 视线先定位再阅读
class _TwoColumnLayout extends StatelessWidget {
  const _TwoColumnLayout();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        SizedBox(
          width: 220,
          child: _NavRail(items: ['概览', '消息', '设置']),
        ),
        VerticalDivider(width: 1),
        Expanded(
          child: _SectionCard(title: '内容区', detail: '双栏: 左导航右内容'),
        ),
      ],
    );
  }
}

// 桌面窗口三栏: 侧栏加列表加详情, 鼠标键盘场景一次看全
class _ThreeColumnLayout extends StatelessWidget {
  const _ThreeColumnLayout();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        SizedBox(width: 200, child: _NavRail(items: ['概览', '消息', '设置'])),
        VerticalDivider(width: 1),
        SizedBox(width: 280, child: _ItemList()),
        VerticalDivider(width: 1),
        Expanded(
          child: _SectionCard(title: '详情面板', detail: '三栏: 侧栏, 列表, 详情'),
        ),
      ],
    );
  }
}

class _NavRail extends StatelessWidget {
  const _NavRail({required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final String item in items)
          ListTile(
            dense: true,
            leading: const Icon(Icons.circle_outlined, size: 16),
            title: Text(item),
          ),
      ],
    );
  }
}

class _ItemList extends StatelessWidget {
  const _ItemList();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 30,
      // 集合项配 ValueKey, Element 复用按身份比对, 口径回指 6.3
      itemBuilder: (BuildContext context, int index) => ListTile(
        key: ValueKey<String>('item-$index'),
        dense: true,
        title: Text('列表项 $index'),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.detail});

  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(detail, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}