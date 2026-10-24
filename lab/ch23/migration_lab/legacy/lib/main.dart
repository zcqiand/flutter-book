// lib/main.dart（工程 migration_lab/legacy）
// 本文件是本章迁移的起跑线：一段 2020 年代真实写法的待办清单应用，
// Material 2 主题加 package:provider 状态管理。
// 工程来历与用法：基线可先独立跑通，再跟着清单 23-2 迁到新范式，
// 逐行改动对照见清单 23-3 的 diff 全记录。
// 基线可编译性纪律（2026-10-20 实测修订）：旧 API 在新代际分两态——
// 色板名（primarySwatch）实测零诊断、静默容忍；旧文本样式名（bodyText1）
// 已被框架删除（error 硬错），实物基线用等价新名保持可跑（见下方偏离申报），
// 原名单保留在清单 23-1 作「迁移第一站」教学对照。
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// 不可变待办模型：title 是迁移前后保持一致的语义字段，
/// 迁移不动数据形状，改的只是状态住在哪、谁来改
@immutable
class Todo {
  const Todo({required this.title});

  final String title;
}

/// 2020 年代的状态载体：继承框架的通知基类，改完数据要手动广播
class TodoListModel extends ChangeNotifier {
  // 私有列表：数据只住在类内部，外部拿不到可变引用
  final List<Todo> _todos = <Todo>[const Todo(title: '学 Flutter')];

  /// 对外只给不可变视图：外部只能读，改数据必须走 add 这类方法入口
  List<Todo> get items => List<Todo>.unmodifiable(_todos);

  void add(String title) {
    _todos.add(Todo(title: title));
    // 手动广播：漏掉这一行界面就不刷新，是旧范式最经典的坑
    notifyListeners();
  }
}

void main() {
  runApp(
    // 旧范式的接线口：在组件树根部挂好通知源，后代凭 context 沿树向上取
    MultiProvider(
      // 列表类型不写显式标注：让推断按 ChangeNotifierProvider 的父类型收口，
      // 这是 2020 年代文档里 providers 参数的标准书写形态
      providers: [
        ChangeNotifierProvider<TodoListModel>(
          create: (BuildContext context) => TodoListModel(),
        ),
      ],
      child: const LegacyTodoApp(),
    ),
  );
}

class LegacyTodoApp extends StatelessWidget {
  const LegacyTodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'migration_lab legacy',
      // Material 2 的主题形态：主色靠色板名（swatch）整体给定，
      // 不开 ColorScheme 角色表；这段写法迁移到 M3 的改法见清单 23-2 与 23-3
      // 实测（2026-10-20）：primarySwatch 在当前代际零诊断——连弃用提示
      // （deprecated_member_use）都没有，属静默容忍，基线可原样保留
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const LegacyTodoPage(),
    );
  }
}

class LegacyTodoPage extends StatelessWidget {
  const LegacyTodoPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 旧范式的读法：凭 context 沿树向上找通知源，找到即订阅，数据变则重建
    final TodoListModel model = context.watch<TodoListModel>();
    return Scaffold(
      appBar: AppBar(title: const Text('待办清单（迁移前基线）')),
      body: ListView.builder(
        itemCount: model.items.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            // 旧代际的文本样式名：与迁移后的新角色名一一对应，见清单 23-3
            // 实测（2026-10-20）：bodyText1 已从 TextTheme 删除（error 硬错）
            // 实测臂偏离申报（2026-10-20）：bodyText1 在 Flutter 3.47.6 已从
            // TextTheme 删除（undefined_getter 硬错，非弃用提示），
            // 基线为守住「真实可跑」纪律替换为其等价新名 bodyLarge；
            // 正文清单 23-1/23-3 的 bodyText1 行为缺陷登记，归 patch 臂裁决
            title: Text(
              model.items[index].title,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        // 旧范式的写法：凭 context 找到实例后直接调方法，方法内自己广播
        onPressed: () => context.read<TodoListModel>().add('新待办'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
