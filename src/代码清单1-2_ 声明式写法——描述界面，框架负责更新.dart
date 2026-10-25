import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: CounterPage()));

class CounterPage extends StatefulWidget {
  const CounterPage({super.key});

  @override
  State<CounterPage> createState() => _CounterPageState();
}

class _CounterPageState extends State<CounterPage> {
  int _count = 0;

  void _increment() {
    // 只改状态变量：没有获取任何界面节点，也没有手动写任何显示内容。
    // setState 触发 build 重新求值——新的 Text 是用新 _count 算出的结果，
    // UI 只是状态的函数，不存在"找到 Text 再改它"这一步。
    setState(() => _count++);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('计数器')),
      body: Center(child: Text('点了 $_count 次')),
      floatingActionButton: FloatingActionButton(onPressed: _increment, child: const Icon(Icons.add)),
    );
  }
}