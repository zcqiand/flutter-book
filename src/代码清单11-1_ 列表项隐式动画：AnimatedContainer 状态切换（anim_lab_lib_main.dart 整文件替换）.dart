// ============================================================
// 教学演示版本：正文 11.1 隐式动画家族之 AnimatedContainer。
// 复现操作序列：
//   1. flutter create anim_lab，整文件替换 lib/main.dart；
//   2. flutter run -d windows；
//   3. 点按列表任意一项，看高度与底色如何过渡到展开态；
//   4. 再次点按同一项，看收起过程。
// 看什么：setState 只改了两个属性的目标值，中间的每一帧
//   都是 AnimatedContainer 自己补出来的，没有控制器、没有 dispose。
// 单文件自包含，零第三方依赖。
// ============================================================
import 'package:flutter/material.dart';

void main() {
  runApp(const AnimLabApp());
}

class AnimLabApp extends StatelessWidget {
  const AnimLabApp();

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ImplicitListPage(),
    );
  }
}

class ImplicitListPage extends StatelessWidget {
  const ImplicitListPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('列表项隐式动画')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: const <Widget>[
          ExpandableItem(title: '需求评审'),
          ExpandableItem(title: '技术方案'),
          ExpandableItem(title: '上线检查单'),
        ],
      ),
    );
  }
}

// 展开状态由每个列表项自己持有：互不干扰，也无需上提到页面级
class ExpandableItem extends StatefulWidget {
  const ExpandableItem({super.key, required this.title});

  final String title;

  @override
  State<ExpandableItem> createState() => _ExpandableItemState();
}

class _ExpandableItemState extends State<ExpandableItem> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: AnimatedContainer(
        // 300ms 是日常 UI 过渡的常用档位：太短看不清过程，太长显得拖沓
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        // 只声明目标态：高度和底色怎么渐变，是容器自己的事
        height: _expanded ? 120 : 56,
        decoration: BoxDecoration(
          color: _expanded ? Colors.indigo.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.indigo.shade200),
        ),
        alignment: Alignment.centerLeft,
        child: Text(
          _expanded ? '${widget.title}：已展开，点按收起' : widget.title,
          style: TextStyle(
            fontSize: 16,
            color: _expanded ? Colors.indigo : Colors.black87,
          ),
        ),
      ),
    );
  }
}