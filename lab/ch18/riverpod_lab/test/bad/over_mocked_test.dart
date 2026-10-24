// test/bad/over_mocked_test.dart
// 反例清单：本文件不可照抄，专供对照「替多了」长什么样。
// 被测对象是 FeedNotifier 的状态转移，这里却把 FeedNotifier 本身也 mock 掉，
// 测试自始至终没有一行被测逻辑在跑，绿了等于零证明
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:riverpod_lab/core/feed_notifier.dart';

/// 替身连业务层也实现了：从这一行起测试就已经空转
class _FakeFeedNotifier extends Mock implements FeedNotifier {}

void main() {
  test('反例：替掉被测逻辑后，断言只验替身自己的返回值', () async {
    // 第一处替多：状态转移的主人被换成了替身，
    // load 里的 loading 换态、空列表判分支、异常归一，全部不在场
    final _FakeFeedNotifier notifier = _FakeFeedNotifier();
    when(() => notifier.load()).thenAnswer((_) async {});

    // 第二处替多：连状态快照都是手造的，与 FeedNotifier 的真实产出无关
    const FeedState fakeState = FeedState(status: FeedStatus.data);
    when(() => notifier.state).thenReturn(fakeState);

    await notifier.load(); // 调的是替身剧本，不是被测实现
    final FeedState result = notifier.state; // 取的还是替身塞的假状态

    // 这行断言验的是假货：等号两边全部出自替身，
    // 被测逻辑全程不在场，测试绿了也什么都没证明
    expect(result.status, fakeState.status);
  });
}
