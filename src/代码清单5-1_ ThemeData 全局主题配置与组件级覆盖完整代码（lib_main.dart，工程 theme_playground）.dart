import 'package:flutter/material.dart';

void main() {
  runApp(const ThemePlaygroundApp());
}

/// 主题在这定一次，全 App 的 Material 组件都来这取色。
/// 刻意不写 useMaterial3: true：Flutter 3.47 出厂默认已是 Material 3，
/// ThemeData 构造出来就是 M3 色板体系，再手写一行反而像旧代际的残留
class ThemePlaygroundApp extends StatelessWidget {
  const ThemePlaygroundApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // fromSeed 一颗种子色自动配齐整套 ColorScheme 角色：
        // 换主题从逐个挑色变成填空题，这一行就是全 App 配色的总开关
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3D5AFE)),
      ),
      home: const ThemeShowcasePage(),
    );
  }
}

/// 展示页摆两层：上层吃全局色板，下层被局部换装，同框对比最直观
class ThemeShowcasePage extends StatelessWidget {
  const ThemeShowcasePage({super.key});

  @override
  Widget build(BuildContext context) {
    // 全局层取色：这里拿到的就是 MaterialApp 里那份 colorScheme
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('主题试验场')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('全局主题层', style: TextStyle(fontSize: 13, color: scheme.secondary)),
          const SizedBox(height: 8),
          Card(
            // 卡片不手写底色：M3 默认样式自己消费色板容器角色，
            // 换种子色它跟着变，这正是「组件找主题要色」的活样本
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '这一层读的是全局色板',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: scheme.primary),
                  ),
                  const SizedBox(height: 8),
                  _secondarySample('全局 secondary', scheme.secondary),
                  const SizedBox(height: 8),
                  ElevatedButton(onPressed: () {}, child: const Text('全局主题按钮')),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          // 就地换装：Theme 包住谁，谁的 Theme.of 就拿到新装；
          // 子树外一切照旧，覆盖边界由包裹范围说了算，全 App 不受牵连
          Theme(
            data: Theme.of(context).copyWith(
              // copyWith 只换一个角色，其余角色原样继承自全局主题
              colorScheme: Theme.of(context).colorScheme.copyWith(secondary: Colors.teal),
            ),
            // Builder 造一个位于换装层之下的 context：第 4 章说过 context 是位置句柄，
            // 拿外层 build 的 context 取色，取到的仍是全局主题；
            // 只有让取色动作发生在换装层里面，才拿得到青色 secondary
            child: Builder(
              builder: (BuildContext innerContext) {
                final ColorScheme overridden = Theme.of(innerContext).colorScheme;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('局部覆盖层', style: TextStyle(fontSize: 13)),
                    const SizedBox(height: 8),
                    // 关键对比：同样的 secondary 角色，这里取到的已是青色，
                    // 与上层卡片里的蓝紫色块并排，一眼看出换装只发生在包裹范围内
                    _secondarySample('覆盖后的 secondary', overridden.secondary),
                    const SizedBox(height: 8),
                    ElevatedButton(onPressed: () {}, child: const Text('覆盖层里的按钮')),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 色板角色样本：左色块右名字。拿角色色画色块，
  /// 比文字描述直观，也顺手演示了角色色的标准取法
  Widget _secondarySample(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(6)),
        ),
        const SizedBox(width: 12),
        Text(label, style: const TextStyle(fontSize: 14)),
      ],
    );
  }
}