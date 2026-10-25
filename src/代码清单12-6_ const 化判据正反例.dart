// 判据一句话: 构造参数必须全部编译期可求值, const 才成立,
// 它是全有或全无的判定, 混入一个运行时参数就堵死整个构造的 const 路
// 与清单 12-1 同工程, 把 home 换成 ConstJudgeDemo 即可对照体验

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