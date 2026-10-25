// 与清单 12-4 同文件可 diff, 修复手法只有两处改动, 逐行对照即见

class RebuildLabFixedPage extends StatelessWidget {
  const RebuildLabFixedPage({super.key});

  @override
  Widget build(BuildContext context) {
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

  @override
  Widget build(BuildContext context) {
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