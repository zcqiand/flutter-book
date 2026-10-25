// lib/main.dart（工程 migration_lab/legacy）
// 本文件是本章迁移的起跑线：一段 2020 年代真实写法的待办清单应用，
// Material 2 主题加 package:provider 状态管理。
// 工程来历与用法：基线可先独立跑通，再跟着清单 23-2 迁到新范式，
// 逐行改动对照见清单 23-3 的 diff 全记录。
// 基线来历纪律：按 2020 年代的历史写法原样呈现，不替老代码预先现代化。
// 已被框架彻底删除的旧组件（如旧凸起、扁平按钮一族）想原样保留已无从编译，只进第 23 章对照表点名；
// 基线里仍保留的旧样式名在新 SDK 首跑即报 error，这正是迁移的第一站（改名走 23.4 第三步）。
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
      // 申报：色板名这一行在新 SDK 实测仍可编译、零诊断（连弃用提示都没有），
      // 属于被静默容忍的旧写法；迁移换掉它是为了对齐角色表，不是因为它报错
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
            // 旧代际的文本样式名：与迁移后的新角色名一一对应，见清单 23-3。
            // 申报：bodyText1 在新 SDK 已删除，基线按 2020 年写法原样保留此行，
            // 首跑即在本行报 error——这正是迁移的第一站；换成新角色名后可跑（见清单 23-4 回执）
            title: Text(
              model.items[index].title,
              style: Theme.of(context).textTheme.bodyText1,
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