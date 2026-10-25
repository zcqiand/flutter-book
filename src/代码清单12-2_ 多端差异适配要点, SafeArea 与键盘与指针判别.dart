// 追加进 responsive_lab/lib/main.dart 即可运行(与清单 12-1 同一工程同一文件)
// 把 ResponsiveLabApp 的 home 换成 MultiDeviceDemoPage 即可体验

class MultiDeviceDemoPage extends StatelessWidget {
  const MultiDeviceDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    // MediaQuery 读的是窗口级环境信息, 与 LayoutBuilder 的父级约束分工不同
    // 键盘弹出与收起会改变 viewInsets, 依赖它的 build 自动重跑, 无需手动监听
    final MediaQueryData media = MediaQuery.of(context);
    final bool keyboardUp = media.viewInsets.bottom > 0;
    // 指针判别走绑定层: 有鼠标连接说明当前环境存在精确指针,
    // 触屏没有 hover, 同一控件两端的交互反馈要据此分开设计
    final bool hasMouse =
        WidgetsBinding.instance.mouseTracker.mouseIsConnected;

    return Scaffold(
      appBar: AppBar(title: const Text('多端差异适配')),
      // SafeArea 避开状态栏, 刘海与手势条, 手机端必备, 桌面端通常无感
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('键盘是否顶起: ${keyboardUp ? "是" : "否"}'),
              const SizedBox(height: 8),
              Text('底部安全区边距: ${media.padding.bottom}'),
              Text('精确指针(鼠标): ${hasMouse ? "有" : "无"}'),
              const SizedBox(height: 24),
              // 点这里拉起软键盘, 再看上方「键盘是否顶起」的开关
              const TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: '聚焦我拉起键盘',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}