// 单元层：TodoListNotifier 状态逻辑回归（不等 UI，直接驱动容器）
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:migrated/main.dart';

void main() {
  test('初始状态含种子待办「学 Flutter」', () {
    final ProviderContainer container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(todoListProvider), <Todo>[
      const Todo(title: '学 Flutter'),
    ]);
  });

  test('add 不可变追加：旧列表不被原地改写，新列表整体替换', () {
    final ProviderContainer container = ProviderContainer();
    addTearDown(container.dispose);

    final List<Todo> before = container.read(todoListProvider);
    container.read(todoListProvider.notifier).add('新待办');
    final List<Todo> after = container.read(todoListProvider);

    expect(after.length, 2);
    expect(after.last.title, '新待办');
    expect(identical(before, after), isFalse,
        reason: '状态必须整体替换，不允许原地追加');
  });

  test('监听者在状态整体替换时被框架自动通知', () {
    final ProviderContainer container = ProviderContainer();
    addTearDown(container.dispose);

    final List<List<Todo>> seen = <List<Todo>>[];
    container.listen(todoListProvider, (_, List<Todo> next) => seen.add(next));

    container.read(todoListProvider.notifier).add('第二条');
    expect(seen, hasLength(1));
    expect(seen.single.last.title, '第二条');
  });
}
