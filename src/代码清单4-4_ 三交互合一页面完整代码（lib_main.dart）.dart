import 'package:flutter/material.dart';

void main() {
  runApp(
    const MaterialApp(
      home: InteractionPage(),
      debugShowCheckedModeBanner: false,
    ),
  );
}

/// 交互试验场整页。状态管理线第 1 站：只管本组件私有 UI 状态——
/// 计数、开关、已提交文本三个值都只在本页活着、本页消费，
/// 谁也不跨组件共享，所以 setState 单挑足够（跨组件共享是第 15 章起的话题）
class InteractionPage extends StatefulWidget {
  const InteractionPage({super.key});

  @override
  State<InteractionPage> createState() => _InteractionPageState();
}

class _InteractionPageState extends State<InteractionPage> {
  int _tapCount = 0;           // 交互一：按钮点击计数
  bool _notificationOn = true; // 交互二：开关状态
  String _submittedText = '';  // 交互三：最近一次提交的回显文本

  // 输入草稿不占上面三席，也不走 setState：每敲一个字就重建整页太浪费，
  // 草稿只进普通字段记个账，提交那一刻才 setState——一次重建只办一件值得的事
  String _input = '';

  /// 交互三的提交动作：校验、回显、确认弹条，三步全在事件回调里完成
  void _submitInput() {
    final String trimmed = _input.trim();
    if (trimmed.isEmpty) {
      // 空输入不进状态：无效数据不落账，用户拿到一条提醒而非静默失败
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('输入为空，先写点什么再提交')),
      );
      return;
    }
    setState(() {
      _submittedText = trimmed;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('已提交：$trimmed')),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 刻意留白：这一行注释占的正是初学者最爱把 setState 直接写进 build 的位置——
    // build 一执行就改状态，改状态又触发 build，页面当场死循环。
    // 两个错点的完整拆解见 4.4 节错例清单与清单4-6，此处只立牌子不犯错
    return Scaffold(
      appBar: AppBar(title: const Text('交互试验场')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildCounterCard(),
          const SizedBox(height: 16),
          _buildSwitchCard(),
          const SizedBox(height: 16),
          _buildInputCard(),
        ],
      ),
    );
  }

  /// 交互一：点击计数。setState 只干一件事——把「值变了」告诉框架，
  /// 框架随后重新执行 build，Text 读到新值，屏幕才刷新
  Widget _buildCounterCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('交互一：点击计数', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            '已点击 $_tapCount 次',
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF3D5AFE)),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () {
              // 状态变更包在事件回调里：用户点了才改，改完交给框架重建
              setState(() {
                _tapCount++;
              });
            },
            icon: const Icon(Icons.touch_app),
            label: const Text('点我加一'),
          ),
        ],
      ),
    );
  }

  /// 交互二：开关。SwitchListTile 把图标、标题、开关三件的横排打包成交互件，
  /// 整行可点，省去自己拼 Row 的功夫——常用交互组件优先选现成的
  Widget _buildSwitchCard() {
    // 白色卡片这里用 Material 顶替 Container：SwitchListTile 的底色与水波纹
    // 画在最近的 Material 祖先上，中间隔一层带底色的 Container 会被 debug
    // 断言点名（墨水效果可能被遮）；Material 自带 color 与圆角，一层顶两层
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          SwitchListTile(
            title: const Text('消息通知'),
            subtitle: const Text('点击整行即可切换'),
            value: _notificationOn,
            onChanged: (bool newValue) {
              setState(() {
                _notificationOn = newValue;
              });
            },
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Text(
              // 同一行文字跟着开关换文案换颜色：状态变了界面跟着变的最小样本
              _notificationOn ? '通知已开启，新消息会提醒你' : '通知已关闭，世界清静了',
              style: TextStyle(
                fontSize: 13,
                color: _notificationOn ? const Color(0xFF2E7D32) : Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 交互三：输入与提交。onChanged 里刻意不调 setState——
  /// 敲字过程只让普通字段记草稿，提交才触发一次重建
  Widget _buildInputCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('交互三：输入并提交', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          TextField(
            decoration: const InputDecoration(
              labelText: '内容',
              hintText: '写点什么，比如：布局学完了',
              border: OutlineInputBorder(),
            ),
            onChanged: (String value) {
              // 草稿已进 _input 记账，这里刻意不调 setState：
              // 「哪类变化不值得一整次重建」4.4 节正面回答
              _input = value;
            },
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submitInput,
              child: const Text('提交'),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _submittedText.isEmpty ? '还没有提交过内容' : '已提交：$_submittedText',
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}