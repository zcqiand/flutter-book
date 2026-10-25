// 修复版本（正文 9.4）：与清单 9-5 相同场景，只重写埋雷的 initState。
// 复现操作序列不变：进详情页、3 秒内按返回键、等满 3 秒看控制台。
// 预期现象：控制台安静，迟到的回调被 mounted 防线礼貌劝返
@override
void initState() {
  super.initState();
  Future<void>.delayed(const Duration(seconds: 3), () async {
    // mounted 的语义：这枚 State 此刻还挂在组件树上吗。
    // 用户按返回键后 State 走完 dispose，mounted 变为 false；
    // return 不只是躲开断言，更是放弃整个迟到动作：
    // setState 不该做，弹窗也不该弹，页面已经不在了
    if (!mounted) return;
    setState(() {
      _report = '慢汇报已到达';
    });
    await showDialog<void>(
      context: context,
      builder: (_) => const AlertDialog(
        title: Text('迟到的弹窗'),
        content: Text('这次只有在页面还活着时才会弹出'),
      ),
    );
  });
}

// 正文 9.3：竞态防线的 Stream 版不是 mounted 而是取消订阅。
// 清单 9-3 已经示范：StreamSubscription 攥字段、dispose 里 cancel，
// 流推得再勤也够不着一个已销毁的页面。
// 一句话分界：Future 场景守 mounted，Stream 场景守 cancel