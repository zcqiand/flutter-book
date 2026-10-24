import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

void main() => runApp(const ResponsiveLabApp());

class ResponsiveLabApp extends StatelessWidget {
  const ResponsiveLabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'responsive_lab',
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      // [探针] 实测臂注: 探测模式(--dart-define=PROBE=all)走 ProbeRunner,
      // 正文默认行为不变, 仍是 AdaptiveDemoPage
      home: const bool.fromEnvironment('PROBE')
          ? ProbeRunner()
          : AdaptiveDemoPage(),
    );
  }
}

// 断点集中声明, 三套布局分支引用同一份, 避免各处魔法数字各自漂移
// 取值依据: Material 3 官方窗口宽度分档, 600 以下 compact(典型手机竖屏),
// 600 到 840 之间 medium(平板竖屏与折叠屏), 840 以上 expanded(平板横屏与桌面窗口)
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
          // [探针] 实测臂注: 档位判定分支打印, 回执 A 数据源
          debugPrint('[探针] AdaptiveDemoPage LayoutBuilder width=$width '
              '命中=${width >= kExpandedBreakpoint
                  ? '_ThreeColumnLayout(桌面三栏)'
                  : width >= kMediumBreakpoint
                      ? '_TwoColumnLayout(平板双栏)'
                      : '_SingleColumnLayout(手机单列)'}');
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
    // [探针] 实测臂注: 布局参数打印, 回执 A 数据源
    debugPrint('[探针] _SingleColumnLayout.build 单列: ListView padding=16, 卡片数=3');
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

// 平板横屏双栏: 左窄导航右宽内容, 视线先定位再阅读
class _TwoColumnLayout extends StatelessWidget {
  const _TwoColumnLayout();

  @override
  Widget build(BuildContext context) {
    // [探针] 实测臂注: 布局参数打印, 回执 A 数据源
    debugPrint('[探针] _TwoColumnLayout.build 双栏: 左导航宽=220, 分隔线=1, 右内容=Expanded');
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
    // [探针] 实测臂注: 布局参数打印, 回执 A 数据源
    debugPrint('[探针] _ThreeColumnLayout.build 三栏: 侧栏=200, 列表=280, 详情=Expanded');
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

// [探针] 以下 12-2 清单代码(演示页), 默认路由不挂载, 探测/体验时换 home
class MultiDeviceDemoPage extends StatelessWidget {
  const MultiDeviceDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    // MediaQuery 读的是窗口级环境信息, 与 LayoutBuilder 的父级约束分工不同
    // 键盘弹出与收起会改变 viewInsets, 依赖它的 build 自动重跑, 无需手动监听
    final MediaQueryData media = MediaQuery.of(context);
    final bool keyboardUp = media.viewInsets.bottom > 0;
    // 指针判别走绑定层: 有鼠标连接说明当前环境存在精确指针,
    // 触屏没有 hover, 同一控件两端的交互反馈要据此分开设计
    final bool hasMouse =
        WidgetsBinding.instance.mouseTracker.mouseIsConnected;

    return Scaffold(
      appBar: AppBar(title: const Text('多端差异适配')),
      // SafeArea 避开状态栏, 刘海与手势条, 手机端必备, 桌面端通常无感
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('键盘是否顶起: ${keyboardUp ? "是" : "否"}'),
              const SizedBox(height: 8),
              Text('底部安全区边距: ${media.padding.bottom}'),
              Text('精确指针(鼠标): ${hasMouse ? "有" : "无"}'),
              const SizedBox(height: 24),
              // 点这里拉起软键盘, 再看上方「键盘是否顶起」的开关
              const TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: '聚焦我拉起键盘',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// [探针] 以下 12-4 清单代码(问题版)
class RebuildLabPage extends StatefulWidget {
  const RebuildLabPage({super.key});

  @override
  State<RebuildLabPage> createState() => _RebuildLabPageState();
}

class _RebuildLabPageState extends State<RebuildLabPage> {
  int _counter = 0;
  // [探针] build 序号, 回执 B/C 重建计数数据源
  static int buildSeq = 0;

  void _bump() {
    // 计数只是顶栏一行文本的状态, setState 却挂在整页 State 上
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    buildSeq++;
    debugPrint('[探针] RebuildLabPage.build #$buildSeq');
    return Scaffold(
      appBar: AppBar(title: const Text('重建实验室, 问题版')),
      body: Column(
        children: [
          // 病灶行: 顶栏计数与下面的重子树同住一个 build,
          // _bump 触发的整页重建把两者一起重跑, 而重子树对计数零依赖
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('点击了 $_counter 次'),
              const SizedBox(width: 12),
              ElevatedButton(onPressed: _bump, child: const Text('再点一次')),
            ],
          ),
          // 病灶同谋行: HeavyListView 不加 const, 父级 build 每跑一次,
          // 这里就换一份新配置, 整棵重子树跟着重跑
          Expanded(child: HeavyListView()),
        ],
      ),
    );
  }
}

// 重子树: 视口外的条目由惰性构建挡住(回指 6.1), 痛点在可视区被反复重跑
class HeavyListView extends StatelessWidget {
  const HeavyListView({super.key});

  static final List<String> _items =
      List<String>.generate(40, (int i) => '条目 ${i + 1}');

  // [探针] build 序号, 回执 B/C 重建计数数据源
  static int buildSeq = 0;

  @override
  Widget build(BuildContext context) {
    buildSeq++;
    // 探针打印: 不借助任何工具, 逐次点按钮就能在控制台看到本 build 被无谓重跑
    debugPrint('HeavyListView.build 执行, 共 ${_items.length} 个条目');
    debugPrint('[探针] HeavyListView.build #$buildSeq');
    return ListView.builder(
      itemCount: _items.length,
      itemBuilder: (BuildContext context, int index) => ListTile(
        key: ValueKey<String>(_items[index]),
        leading: const Icon(Icons.receipt_long),
        title: Text(_items[index]),
      ),
    );
  }
}

// [探针] 以下 12-6 清单代码(判据演示页)
class ConstJudgeDemo extends StatelessWidget {
  const ConstJudgeDemo({super.key});

  @override
  Widget build(BuildContext context) {
    // 昵称模拟运行时数据, 接口返回前不存在编译期形态
    final String nickname = '运行时才拿到的昵称';

    return Scaffold(
      appBar: AppBar(title: const Text('const 化判据')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 正例: 参数全为编译期常量, const 成立,
          // 父级重建时这里拿到同一个规范化实例, Element 判定相同后整体跳过
          const ListTile(
            leading: Icon(Icons.check_circle, color: Colors.green),
            title: Text('正例: 全常量参数'),
            subtitle: Text('字面量加常量样式, 每个参数编译期可求值'),
          ),
          ListTile(
            // 反例一: title 携带运行时值, 尽管其余子件皆可 const,
            // 本体不能 const, 能 const 化的只有 leading 这类纯展示子件
            leading: const Icon(Icons.cancel, color: Colors.red),
            title: const Text('反例一: 混入运行时参数'),
            subtitle: Text('昵称=$nickname, 运行时定值, 本体 const 不成立'),
          ),
          ElevatedButton(
            // 反例二: 闭包捕获 context, 运行时才创建, 按钮本体进不了 const,
            // 优化空间下沉到 child 一层, 那里的 Text 仍然可以 const
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('闭包参数, 本体不能 const')),
            ),
            child: const Text('反例二: 含回调闭包'),
          ),
        ],
      ),
    );
  }
}

// [探针] 以下 12-7 清单代码(修复版)
class RebuildLabFixedPage extends StatelessWidget {
  const RebuildLabFixedPage({super.key});

  // [探针] build 序号, 回执 C 重建计数数据源
  static int buildSeq = 0;

  @override
  Widget build(BuildContext context) {
    buildSeq++;
    debugPrint('[探针] RebuildLabFixedPage.build #$buildSeq');
    return Scaffold(
      appBar: AppBar(title: const Text('重建实验室, 修复版')),
      body: const Column(
        children: [
          // 改动一(对应 12-4 病灶行): 计数文本与按钮下沉进 _CounterSection,
          // setState 不再挂在整页上, 波及面收窄到一行文本加一个按钮,
          // 状态没有被删掉, 只是搬进了最小必要子树
          _CounterSection(),
          // 改动二(对应 12-4 病灶同谋行): 加 const,
          // 本页已是 StatelessWidget 自身无 setState, 重子树配置恒定,
          // 即便父级因主题或路由原因重建, 这里也交出同一实例被 Element 跳过
          Expanded(child: HeavyListView()),
        ],
      ),
    );
  }
}

class _CounterSection extends StatefulWidget {
  const _CounterSection();

  @override
  State<_CounterSection> createState() => _CounterSectionState();
}

class _CounterSectionState extends State<_CounterSection> {
  int _counter = 0;

  // [探针] build 序号, 回执 C 重建计数数据源
  static int buildSeq = 0;

  @override
  Widget build(BuildContext context) {
    buildSeq++;
    debugPrint('[探针] _CounterSection.build #$buildSeq');
    // setState 现在只属于最小子树, 点按钮重跑的只有这一行
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('点击了 $_counter 次'),
        const SizedBox(width: 12),
        ElevatedButton(
          onPressed: () => setState(() => _counter++),
          child: const Text('再点一次'),
        ),
      ],
    );
  }
}

// [探针] ============================================================
// [探针] 实测探针区(重编号前按原样保留 [探针] 前缀): 非正文清单代码,
// [探针] 仅 --dart-define=PROBE=all 时挂载, 编程执行回执 A/B/C 三段场景,
// [探针] 逐段打印 capture 标记行供控制台落盘, 跑完自动退出。
// [探针] ============================================================
class ProbeRunner extends StatefulWidget {
  const ProbeRunner({super.key});

  @override
  State<ProbeRunner> createState() => _ProbeRunnerState();
}

class _ProbeRunnerState extends State<ProbeRunner> {
  // 回执 A: 三档宽度序列(手机竖屏/平板横屏/桌面窗口), 用 SizedBox 约束驱动,
  // 与拖拽窗口同一条 LayoutBuilder 父约束通路
  static const List<double> _widths = [400, 700, 1000];
  int _widthIndex = 0;
  // 回执 B/C 场景: 0=回执A 1=问题版 2=修复版
  int _stage = 0;
  bool _captureOpen = false;
  final List<FrameTiming> _timings = <FrameTiming>[];

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addTimingsCallback(_onTimings);
    WidgetsBinding.instance.addPostFrameCallback((_) => _runStageA());
  }

  void _onTimings(List<FrameTiming> timings) {
    if (_captureOpen) {
      _timings.addAll(timings);
    }
  }

  Future<void> _wait(int ms) async {
    await Future<void>.delayed(Duration(milliseconds: ms));
  }

  // ---- 回执 A: 三档逐级触发 ----
  Future<void> _runStageA() async {
    for (int i = 0; i < _widths.length; i++) {
      await _wait(800); // 先让上一档稳定出帧
      debugPrint('[capture-A] 档位 ${i + 1}: 约束宽度=${_widths[i]}');
      setState(() => _widthIndex = i);
      await _wait(600);
      debugPrint('[capture-A] 档位 ${i + 1} 段结束');
    }
    debugPrint('[回执A] 三档布局分支与布局参数打印完毕(见上方 [capture-A]/[探针] 行)');
    setState(() => _stage = 1);
    await _wait(1500); // 问题版首帧稳定
    await _runRebuildScenario('B', '问题版(清单12-4)');
  }

  // ---- 回执 B/C: 单次按键场景, 问题版与修复版同口径各跑一遍 ----
  Future<void> _runRebuildScenario(String receipt, String label) async {
    _timings.clear();
    debugPrint('[capture-$receipt] begin: $label, 即将编程触发单次按键');
    setState(() => _captureOpen = true);
    _pressFirstButton();
    await _wait(1200);
    debugPrint('[capture-$receipt] end: $label 按键后观察窗关闭');
    setState(() => _captureOpen = false);
    _printSummary(receipt, label);
    if (_stage == 1) {
      setState(() {
        _stage = 2;
      });
      await _wait(1500);
      await _runRebuildScenario('C', '修复版(清单12-7)');
    } else {
      debugPrint('[PROBE-DONE] 三件回执场景执行完毕');
      await _wait(200);
      exit(0);
    }
  }

  // 编程按键: 遍历元素树找到第一个可按的 ElevatedButton 并触发其同一回调,
  // 与手指/鼠标点击走的是同一个 onPressed 通路
  void _pressFirstButton() {
    bool pressed = false;
    void visit(Element element) {
      if (pressed) {
        return;
      }
      final Widget widget = element.widget;
      if (widget is ElevatedButton && widget.onPressed != null) {
        pressed = true;
        debugPrint('[capture] 已编程触发 ElevatedButton.onPressed');
        widget.onPressed!();
        return;
      }
      element.visitChildren(visit);
    }

    (context as Element).visitChildren(visit);
    if (!pressed) {
      debugPrint('[capture] 警告: 未找到可触发按钮');
    }
  }

  void _printSummary(String receipt, String label) {
    int frameCount = _timings.length;
    if (frameCount == 0) {
      debugPrint('[回执$receipt] $label: 观察窗内未收到 FrameTiming(调试模式时序上报缺失)');
      return;
    }
    double meanBuildMs = _mean(_timings.map(
        (FrameTiming t) => t.buildDuration.inMicroseconds.toDouble()));
    double worstBuildMs = _worst(_timings.map(
        (FrameTiming t) => t.buildDuration.inMicroseconds.toDouble()));
    double meanRasterMs = _mean(_timings.map(
        (FrameTiming t) => t.rasterDuration.inMicroseconds.toDouble()));
    double worstRasterMs = _worst(_timings.map(
        (FrameTiming t) => t.rasterDuration.inMicroseconds.toDouble()));
    debugPrint('[回执$receipt] $label: 观察窗帧数=$frameCount, '
        '平均UI帧耗时=${meanBuildMs.toStringAsFixed(2)}ms, '
        '最差UI帧耗时=${worstBuildMs.toStringAsFixed(2)}ms, '
        '平均栅格帧耗时=${meanRasterMs.toStringAsFixed(2)}ms, '
        '最差栅格帧耗时=${worstRasterMs.toStringAsFixed(2)}ms');
  }

  static double _mean(Iterable<double> values) {
    final List<double> list = values.toList();
    return list.reduce((double a, double b) => a + b) / list.length / 1000;
  }

  static double _worst(Iterable<double> values) {
    final List<double> list = values.toList();
    return list.reduce((double a, double b) => a > b ? a : b) / 1000;
  }

  @override
  Widget build(BuildContext context) {
    switch (_stage) {
      case 0:
        return Scaffold(
          appBar: AppBar(title: const Text('探针: 回执A 三档场景')),
          body: Center(
            child: SizedBox(
              width: _widths[_widthIndex],
              height: 640,
              child: const AdaptiveDemoPage(),
            ),
          ),
        );
      case 1:
        return const RebuildLabPage();
      default:
        return const RebuildLabFixedPage();
    }
  }
}
