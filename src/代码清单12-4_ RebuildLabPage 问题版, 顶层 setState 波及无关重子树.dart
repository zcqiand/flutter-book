// 与清单 12-1 同工程, 把 home 换成 RebuildLabPage 即可复现现场

class RebuildLabPage extends StatefulWidget {
  const RebuildLabPage({super.key});

  @override
  State<RebuildLabPage> createState() => _RebuildLabPageState();
}

class _RebuildLabPageState extends State<RebuildLabPage> {
  int _counter = 0;

  void _bump() {
    // 计数只是顶栏一行文本的状态, setState 却挂在整页 State 上
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
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

  @override
  Widget build(BuildContext context) {
    // 探针打印: 不借助任何工具, 逐次点按钮就能在控制台看到本 build 被无谓重跑
    debugPrint('HeavyListView.build 执行, 共 ${_items.length} 个条目');
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