class BrokenCounterPage extends StatefulWidget {
  const BrokenCounterPage({super.key});

  @override
  State<BrokenCounterPage> createState() => _BrokenCounterPageState();
}

class _BrokenCounterPageState extends State<BrokenCounterPage> {
  int _count = 0;

  @override
  Widget build(BuildContext context) {
    // 错点一：setState 写在 build 方法体内——build 一执行就改状态，
    // 改状态又触发重建，重建再执行 build……无限循环，debug 模式当场卡死
    setState(() {
      _count++;
    });
    // 错点二：状态变更没有包在事件回调里——setState 的合法住址
    // 是 onPressed、onChanged 这类「用户做了什么」的回调；
    // build 的职责是照当前状态画界面，画的时候不该动手改状态
    return Text('$_count');
  }
}