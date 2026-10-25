// ============================================================
// 教学对照版本：正文 10.2 动态增删表单项（G018 对照实验）。
// 复现操作序列：
//   1. 整文件替换 form_lab/lib/main.dart，flutter run -d windows；
//   2. useKeys = true 先跑：三行各改成不同的文本，
//      点「随机删除中间一行」，看剩下两行的文本是否原地不动；
//   3. 把 useKeys 改成 false 再跑一遍，重复同样操作，
//      对比删行后各行文本的归属变化（G018 错位现场）。
// 看什么：同一个删除动作，有无 key 两种结果；
//   焦点框停在谁身上、文本出现在哪一行。
// 单文件自包含，零第三方依赖。
// ============================================================
import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(const FormLabApp());
}

class FormLabApp extends StatelessWidget {
  const FormLabApp();

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ContactsPage(),
    );
  }
}

// 对照开关：true 每行挂 ValueKey（按身份复用），false 不挂 key（按位置复用）
const bool useKeys = true;

// 行数据自带唯一 id：id 是这一行的身份，下标只是它此刻的座位号
class _RowData {
  const _RowData(this.id, this.initialText);

  final int id;
  final String initialText;
}

class ContactsPage extends StatefulWidget {
  const ContactsPage();

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  final List<_RowData> _rows = <_RowData>[
    _RowData(0, '联系人 0'),
    _RowData(1, '联系人 1'),
    _RowData(2, '联系人 2'),
  ];
  int _nextId = 3;
  final Random _random = Random();

  void _addRow() {
    setState(() {
      _rows.add(_RowData(_nextId, '联系人 $_nextId'));
      _nextId += 1;
    });
  }

  void _removeRandomMiddleRow() {
    // 至少三行才谈得上「中间」：首尾之外任选一行删，
    // 只删最后一行永远撞不出错位，对照实验就废了
    if (_rows.length < 3) {
      return;
    }
    setState(() {
      final int index = _random.nextInt(_rows.length - 2) + 1;
      _rows.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('联系人')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          for (final _RowData row in _rows) _buildRow(row),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Expanded(
                child: FilledButton.tonal(
                  onPressed: _addRow,
                  child: const Text('添加一行'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.tonal(
                  onPressed: _removeRandomMiddleRow,
                  child: const Text('随机删除中间一行'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRow(_RowData row) {
    return TextFormField(
      // 机制说明（G018 口径）：新旧两轮 widget 逐个配对时，
      // 无 key 按位置配对，第 2 个新 widget 直接顶替第 2 个旧 Element，
      // 旧座位上的 State 连同它攥着的已输入文本、焦点一起留给新行，
      // 于是文本「留座不留人」，看起来就是内容错位；
      // 有 key 按身份配对，id 相同的行无论坐第几位，
      // 都能找回自己的 Element，状态跟着行走。
      // key 管的是「这份状态归属谁」，不是性能优化
      key: useKeys ? ValueKey<int>(row.id) : null,
      initialValue: row.initialText,
    );
  }
}