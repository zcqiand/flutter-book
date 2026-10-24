// 基线冒烟：TodoListModel 增量与手动广播语义（迁移前的行为锚点）
import 'package:flutter_test/flutter_test.dart';

import 'package:legacy/main.dart';

void main() {
  test('初始列表含种子待办「学 Flutter」', () {
    final TodoListModel model = TodoListModel();
    expect(model.items.map((Todo t) => t.title), <String>['学 Flutter']);
  });

  test('add 追加待办并广播（items 视图同步更新）', () {
    final TodoListModel model = TodoListModel();
    model.addListener(expectAsync0(() {}, count: 1));
    model.add('新待办');
    expect(model.items.length, 2);
    expect(model.items.last.title, '新待办');
  });
}
