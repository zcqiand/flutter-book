// 载体冒烟测试：应用可构建、初始态与 l10n 接线可见。
// 注意：测试环境无平台通道实现，invokeMethod 在测试壳内同样抛 MissingPluginException，
// 与 Windows desktop 载体同形态（本章实测回执以 flutter run 实抓为准，此处不重复造）。
import 'package:channel_lab/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('app builds and shows initial state', (tester) async {
    await tester.pumpWidget(const ChannelLabApp());
    await tester.pump();
    expect(find.text('读取电量'), findsOneWidget);
    expect(find.text('尚未读取'), findsOneWidget);
    expect(find.textContaining('API_BASE_URL'), findsOneWidget);
  });
}
