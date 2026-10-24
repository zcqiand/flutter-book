// 诊断夹具（非章内代码）：定位 ValueKey 在 ListView.builder 下的真实行为。
// A. 打印修复版删除前/后逐行 (人名, 勾选) 状态表；
// B. 对照组：同样代码 + findChildIndexCallback（ListView.builder 官方参数），
//    验证勾选是否才真正跟人走。
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:contacts_demo/main.dart';

Future<void> tapRow(WidgetTester tester, String name) async {
  await tester.tap(find.text(name));
  await tester.pumpAndSettle();
}

bool rowChecked(WidgetTester tester, String name) {
  final CheckboxListTile tile =
      tester.widget(find.widgetWithText(CheckboxListTile, name));
  return tile.value ?? false;
}

String table(WidgetTester tester, List<String> names) {
  return [for (final n in names) '$n=${rowChecked(tester, n) ? "勾" : "空"}']
      .join(' ');
}

const List<String> afterDeleteNames = <String>[
  '李雷', '韩梅梅', '王五', '赵敏', '刘洋', '陈静', '周杰',
];

void main() {
  testWidgets('诊断A：清单6-6 修复版删除前后逐行状态表',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const KeyBugLabApp());
    await tester.pumpAndSettle();

    await tapRow(tester, '张伟');
    await tapRow(tester, '韩梅梅');
    // ignore: avoid_print
    print('DIAG 删除前(期望 张伟=勾 李雷=空 韩梅梅=勾 …): '
        '${table(tester, const ['张伟', '李雷', '韩梅梅', '王五'])}');

    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();
    // ignore: avoid_print
    print('DIAG 修复版删除后(实测逐行): ${table(tester, afterDeleteNames)}');
  });

  testWidgets('诊断B：同代码 + findChildIndexCallback 对照',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: _DiagFindIndexPage(),
      ),
    );
    await tester.pumpAndSettle();

    await tapRow(tester, '张伟');
    await tapRow(tester, '韩梅梅');
    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();

    final String t = table(tester, afterDeleteNames);
    // ignore: avoid_print
    print('DIAG findChildIndexCallback 删除后(实测逐行): $t');
    expect(rowChecked(tester, '韩梅梅'), isTrue,
        reason: 'findChildIndexCallback 下韩梅梅的勾应跟人走');
    expect(rowChecked(tester, '李雷'), isFalse);
    expect(rowChecked(tester, '王五'), isFalse);
  });

  testWidgets('诊断C：同一 ValueKey 模式放 Column(children:) 全量构建列表',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: _DiagColumnPage(),
      ),
    );
    await tester.pumpAndSettle();

    await tapRow(tester, '张伟');
    await tapRow(tester, '韩梅梅');
    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();

    // ignore: avoid_print
    print('DIAG Column+ValueKey 删除后(实测逐行): ${table(tester, afterDeleteNames)}');
    expect(rowChecked(tester, '韩梅梅'), isTrue,
        reason: 'Column 全量构建按 key 跨位匹配，勾应跟人走');
    expect(rowChecked(tester, '李雷'), isFalse);
    expect(rowChecked(tester, '王五'), isFalse);
  });
}

/// 与清单 6-4/6-6 完全同构，唯一差异 = ListView.builder 多传官方参数
/// findChildIndexCallback（诊断对照专用，非章内代码）。
class _DiagFindIndexPage extends StatefulWidget {
  const _DiagFindIndexPage();

  @override
  State<_DiagFindIndexPage> createState() => _DiagFindIndexPageState();
}

class _DiagFindIndexPageState extends State<_DiagFindIndexPage> {
  final List<String> _names = <String>[
    '张伟', '李雷', '韩梅梅', '王五', '赵敏', '刘洋', '陈静', '周杰',
  ];

  void _removeFirst() {
    setState(() {
      _names.removeAt(0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('诊断 findChildIndexCallback'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _removeFirst,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _names.length,
        findChildIndexCallback: (Key key) {
          final ValueKey<String> valueKey = key as ValueKey<String>;
          final int index = _names.indexOf(valueKey.value);
          return index < 0 ? null : index;
        },
        itemBuilder: (BuildContext context, int index) {
          return _DiagRow(name: _names[index],
              key: ValueKey<String>(_names[index]));
        },
      ),
    );
  }
}

class _DiagRow extends StatefulWidget {
  const _DiagRow({super.key, required this.name});

  final String name;

  @override
  State<_DiagRow> createState() => _DiagRowState();
}

class _DiagRowState extends State<_DiagRow> {
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

/// 诊断C：同一 ValueKey 模式放进 Column(children:) 全量构建列表——
/// 验证「非懒列表按 key 跨位匹配、勾跟人走」是否成立（机制对照）。
class _DiagColumnPage extends StatefulWidget {
  const _DiagColumnPage();

  @override
  State<_DiagColumnPage> createState() => _DiagColumnPageState();
}

class _DiagColumnPageState extends State<_DiagColumnPage> {
  final List<String> _names = <String>[
    '张伟', '李雷', '韩梅梅', '王五', '赵敏', '刘洋', '陈静', '周杰',
  ];

  void _removeFirst() {
    setState(() {
      _names.removeAt(0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _removeFirst,
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          for (final String name in _names)
            _DiagRow(name: name, key: ValueKey<String>(name)),
        ],
      ),
    );
  }
}
