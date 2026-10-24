import 'package:flutter/material.dart';

void main() {
  runApp(const DarkModeApp());
}

/// 根组件必须住在 StatefulWidget 上：themeMode 是全 App 级状态，
/// 只有它挂在 MaterialApp 头上、变化时重建根，整套配色才会统一换装
class DarkModeApp extends StatefulWidget {
  const DarkModeApp({super.key});

  @override
  State<DarkModeApp> createState() => _DarkModeAppState();
}

class _DarkModeAppState extends State<DarkModeApp> {
  // themeMode 三档：light 锁亮、dark 锁暗、system 跟随系统明暗设置自动换；
  // 三档全由 Material 消化，我们不用写任何「暗色就用深色值」的分支代码
  ThemeMode _themeMode = ThemeMode.light;

  void _setDarkMode(bool dark) {
    // 第 4 章的老朋友 setState：报脏后根 State 的 build 重跑，
    // MaterialApp 拿到新 themeMode，整棵树按新口径换装
    setState(() {
      _themeMode = dark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // 亮色档：种子色自动配齐亮色板
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3D5AFE))),
      // 暗色档：同一颗种子加 brightness dark，品牌色在明暗两态保持同一气质，
      // 色板角色逐个有对应的暗色值，这是手写 ColorScheme 最容易漏的活
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3D5AFE),
          brightness: Brightness.dark,
        ),
      ),
      // 三档开关在这里生效：MaterialApp 内部按 themeMode 挑一份色板下发
      themeMode: _themeMode,
      home: DarkModePage(darkOn: _themeMode == ThemeMode.dark, onToggle: _setDarkMode),
    );
  }
}

/// 展示页零状态：开关只负责把拨动上报给根组件，自己不记账
class DarkModePage extends StatelessWidget {
  const DarkModePage({super.key, required this.darkOn, required this.onToggle});

  final bool darkOn;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    // 关键读法：下面所有取色都走 colorScheme 角色，没有一处写死色值，
    // 所以拨开关换装后，这里的每一行取色代码一个字都不用改
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('暗色一键切换')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: SwitchListTile(
              title: const Text('暗色模式'),
              subtitle: const Text('拨动一下，全 App 换装'),
              value: darkOn,
              onChanged: onToggle,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '角色取色样本',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: scheme.primary),
                  ),
                  const SizedBox(height: 12),
                  _roleSample('primary', scheme.primary),
                  _roleSample('secondary', scheme.secondary),
                  _roleSample('error', scheme.error),
                  const SizedBox(height: 12),
                  ElevatedButton(onPressed: () {}, child: const Text('主题色按钮')),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 角色样本：左色块右角色名。亮暗两态各自天然和谐，
  /// 这正是角色制配色替读者省掉的工作量
  Widget _roleSample(String roleName, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(6)),
          ),
          const SizedBox(width: 12),
          Text(roleName, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}
