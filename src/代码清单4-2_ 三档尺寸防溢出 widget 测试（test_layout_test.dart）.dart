import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:settings_page/main.dart';

void main() {
  // 三个尺寸档共用的装台逻辑：先把测试窗口调成目标设备的逻辑尺寸，
  // 这一步等价于换一台对应分辨率的模拟器，再把设置页泵进帧里
  Future<void> pumpPageAtSize(WidgetTester tester, Size screenSize) async {
    // physicalSize 配 devicePixelRatio 1.0，physical 即逻辑像素，
    // 360 就是 360 逻辑宽，不用再心算一版换算
    tester.view.physicalSize = screenSize;
    tester.view.devicePixelRatio = 1.0;
    // 测试结束后还原窗口尺寸，避免污染同一进程里的下一个用例
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: SizedBox(
          width: screenSize.width,
          height: screenSize.height,
          child: const SettingsPage(),
        ),
      ),
    );
    // 溢出在布局阶段就抛异常并被框架记下：takeException 取走异常，
    // 取到 null 说明整帧零溢出。三档各断言一次，一档失手整组测试就红
    expect(tester.takeException(), isNull);
  }

  testWidgets('360 逻辑宽（小屏手机档，5 至 6 英寸级）不溢出', (tester) async {
    await pumpPageAtSize(tester, const Size(360, 800));
  });

  testWidgets('414 逻辑宽（常规手机档，6.5 英寸级）不溢出', (tester) async {
    await pumpPageAtSize(tester, const Size(414, 896));
  });

  testWidgets('768 逻辑宽（平板档）不溢出', (tester) async {
    await pumpPageAtSize(tester, const Size(768, 1024));
  });
}