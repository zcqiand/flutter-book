// lib/main.dart（工程 migration_lab/migrated）
// 清单 23-1 的等价迁移版：同一个待办清单语义，状态载体换成 Riverpod 的
// Notifier，主题换成 Material 3 角色表；界面文案与交互一字未动
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 与基线同形的不可变模型：迁移不动数据形状，只动状态的住址
@immutable
class Todo {
  const Todo({required this.title});

  final String title;
}

/// 业务状态收敛入口：build 给初始列表，add 只做不可变更新后整体替换状态，
/// 通知环节移交框架，与 ch15 的 state 替换口径完全一致
class TodoListNotifier extends Notifier<List<Todo>> {
  @override
  List<Todo> build() => <Todo>[const Todo(title: '学 Flutter')];

  void add(String title) {
    // 不可变更新：不往旧列表里追加，而是展开旧列表造一份新列表整体替换，
    // 「改完忘了通知」这一类坑从根上不存在，监听者自动跟上
    state = <Todo>[...state, Todo(title: title)];
  }
}

/// 声明接线一行：类型参数写明状态形状，谁是载体、状态是什么一眼可读
final NotifierProvider<TodoListNotifier, List<Todo>> todoListProvider =
    NotifierProvider<TodoListNotifier, List<Todo>>(TodoListNotifier.new);

void main() {
  // 全局容器挂在树根：Riverpod Provider 都注册在这只容器里，后代直接问容器要，
  // 不再需要旧范式那套根部包裹加沿树向上查找的接线
  runApp(ProviderScope(child: const MigratedTodoApp()));
}

class MigratedTodoApp extends StatelessWidget {
  const MigratedTodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'migration_lab migrated',
      // M3 角色表进场：一颗种子色自动配齐整套 ColorScheme 角色，
      // 基线里按色板名取主色的写法在 M3 主题里退场，
      // 配色入口从「选一块色板」变成「往角色表里填种子」（回指 5.1 的口径）
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: const MigratedTodoPage(),
    );
  }
}

/// ConsumerWidget：build 多一个 ref 参数，读状态不经过 context，直接问容器
class MigratedTodoPage extends ConsumerWidget {
  const MigratedTodoPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 读法：watch 容器里的列表状态，列表一换整体重建，订阅不需人登记
    final List<Todo> todos = ref.watch(todoListProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('待办清单（迁移后）')),
      body: ListView.builder(
        itemCount: todos.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            // M3 的文本角色名：与基线同一取法（Theme 向上找），只换代际名
            title: Text(
              todos[index].title,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        // 写法：经 notifier 拿到状态载体再调方法，方法内整体替换状态；
        // 与基线「找到实例就调方法」的调用形一致，广播环节已移交框架
        onPressed: () => ref.read(todoListProvider.notifier).add('新待办'),
        child: const Icon(Icons.add),
      ),
    );
  }
}