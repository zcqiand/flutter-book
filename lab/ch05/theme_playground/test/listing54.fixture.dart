import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const DualStyleApp());
}

/// 暗色机制与清单5-2 同款：亮暗两份色板挂 MaterialApp，themeMode 由根 State 驱动，
/// 保证双风格在亮暗两态下都能看。Cupertino 只取其一看边界，本章不铺开成风格教学线
class DualStyleApp extends StatefulWidget {
  const DualStyleApp({super.key});

  @override
  State<DualStyleApp> createState() => _DualStyleAppState();
}

class _DualStyleAppState extends State<DualStyleApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _setDarkMode(bool dark) {
    setState(() {
      _themeMode = dark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3D5AFE))),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3D5AFE),
          brightness: Brightness.dark,
        ),
      ),
      themeMode: _themeMode,
      home: DualStylePage(darkOn: _themeMode == ThemeMode.dark, onToggle: _setDarkMode),
    );
  }
}

/// 同页摆两列：左 Material 右 Cupertino，同功能一对一对照。
/// 开关各有各的账，两列互不牵连，拨哪列只有哪列动
class DualStylePage extends StatefulWidget {
  const DualStylePage({super.key, required this.darkOn, required this.onToggle});

  final bool darkOn;
  final ValueChanged<bool> onToggle;

  @override
  State<DualStylePage> createState() => _DualStylePageState();
}

class _DualStylePageState extends State<DualStylePage> {
  bool _materialOn = true;  // Material 版开关的账
  bool _cupertinoOn = true; // Cupertino 版开关的账

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('双风格同页对比')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: SwitchListTile(
              title: const Text('暗色模式'),
              subtitle: const Text('拨一下，两列一起换装'),
              value: widget.darkOn,
              onChanged: widget.onToggle,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _materialColumn()),
              const SizedBox(width: 16),
              Expanded(child: _cupertinoColumn()),
            ],
          ),
        ],
      ),
    );
  }

  /// 左列 Material 版：按钮与开关各配一行小字注观感
  Widget _materialColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Material', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ElevatedButton(onPressed: () {}, child: const Text('凸起按钮')),
        const Text('凸起阴影，按下有水波纹', style: TextStyle(fontSize: 12)),
        const SizedBox(height: 16),
        Switch(value: _materialOn, onChanged: (bool v) => setState(() => _materialOn = v)),
        const Text('长轨道式，拨动跟手滑动', style: TextStyle(fontSize: 12)),
      ],
    );
  }

  /// 右列 Cupertino 版：同样的按钮与开关，另一套设计语言的回答。
  /// 两列开关行为完全同构（value 加 onChanged），差异只在观感，
  /// 这说明组件换风格不必换逻辑，代价主要在视觉资产的维护
  Widget _cupertinoColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Cupertino', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        CupertinoButton(
          onPressed: () {},
          child: const Text('扁平按钮'),
        ),
        const Text('扁平无涟漪，按下变透明', style: TextStyle(fontSize: 12)),
        const SizedBox(height: 16),
        CupertinoSwitch(
          value: _cupertinoOn,
          onChanged: (bool v) => setState(() => _cupertinoOn = v),
        ),
        const Text('胶囊滑块，开启态绿底', style: TextStyle(fontSize: 12)),
      ],
    );
  }
}
