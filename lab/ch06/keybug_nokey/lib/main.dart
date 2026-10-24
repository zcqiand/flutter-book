// ============================================================
// 教学故意失败版本：本工程用于复现「无 key 时的状态错位」。
// 它是故意写错的，先跑一遍看看会发生什么，
// 再对照正文 6.5 与清单 6-6 的修复版，体会 key 到底在管什么。
//
// 复现路径：
//   1. 勾选第 1、3 项（张伟、韩梅梅）；
//   2. 点 AppBar 右上角的「删除第一项」；
//   3. 观察：名字集体上移一位，勾选却留在了原来的行上——
//      勾选没有跟人走，因为每行的 State 是按「位置」被复用的。
// ============================================================
import 'package:flutter/material.dart';

void main() {
  runApp(const KeyBugLabApp());
}

class KeyBugLabApp extends StatelessWidget {
  const KeyBugLabApp();

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CheckListPage(),
    );
  }
}

class CheckListPage extends StatefulWidget {
  const CheckListPage();

  @override
  State<CheckListPage> createState() => _CheckListPageState();
}

class _CheckListPageState extends State<CheckListPage> {
  // 名单是会变的：删除动作直接从这份列表头上摘人
  final List<String> _names = <String>[
    '张伟', '李雷', '韩梅梅', '王五', '赵敏', '刘洋', '陈静', '周杰',
  ];

  void _removeFirst() {
    setState(() {
      // 只删数据，不碰任何一行的勾选账——错位恰恰因此才现形
      _names.removeAt(0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('key 错位复现'),
        actions: [
          IconButton(
            tooltip: '删除第一项',
            icon: const Icon(Icons.delete_outline),
            onPressed: _removeFirst,
          ),
        ],
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(12),
            child: Text(
              '先勾选第 1、3 项，再点右上角删除第一项，看看勾选跟不跟人走',
              style: TextStyle(fontSize: 12),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _names.length,
              itemBuilder: (BuildContext context, int index) {
                // 实例化处刻意不给 key：这一行就是 bug 的全部根源。
                // 列表缩短后，框架按「同类型 + 同位置」复用旧的 State，
                // 勾选账留在了原位，名字却是新发下来的
                return _CheckRow(name: _names[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// 每一行自带勾选账：_checked 记在行自己的 State 里，
/// 父组件只下发 name、不代管勾选——正因账在各行自己手里，错位才看得见
class _CheckRow extends StatefulWidget {
  // super.key 是 Widget 家族的标配形参，本版实例化处不传它，它就形同虚设；
  // 复现失败的关键不在构造签名，而在上面 itemBuilder 里一个 key 都没给
  const _CheckRow({super.key, required this.name});

  final String name;

  @override
  State<_CheckRow> createState() => _CheckRowState();
}

class _CheckRowState extends State<_CheckRow> {
  bool _checked = false;

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      value: _checked,
      onChanged: (bool? value) => setState(() => _checked = value ?? false),
      title: Text(widget.name),
    );
  }
}
