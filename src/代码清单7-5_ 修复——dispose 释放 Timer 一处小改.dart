// 小改一：补回 dispose——正文 7.5 归因段里断掉的那条引用链，从这里剪断。
// Timer 持着回调、回调持着 State，页面退场它们还活着；
// cancel 一响，整条链无人引用，随时可回收
@override
void dispose() {
  _timer?.cancel();
  super.dispose();
}

// 小改二：回调开头加 mounted 守卫，cancel 之外的第二道保险。
// cancel 拦不住「已在路上」的一跳：回调可能已在事件队列里排队，
// 守卫发现 State 已退场就就地 cancel 并返回，
// 不再向拆掉的页面打印心跳、更不会 setState
_timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
  if (!mounted) {
    timer.cancel();
    return;
  }
  debugPrint('泄漏心跳：剩余 $_remainingSeconds 秒');
  if (_remainingSeconds > 0) {
    setState(() => _remainingSeconds -= 1);
  } else {
    timer.cancel();
  }
});