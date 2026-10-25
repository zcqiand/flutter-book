import 'package:flutter/material.dart';

void main() {
  runApp(const ContactFilterApp());
}

/// 联系人只是一对只读数据：姓名加电话。
/// 字段全 final 且构造是 const，整份通讯录才能整体编进常量区，零运行时构建开销
class Contact {
  const Contact(this.name, this.phone);

  final String name;
  final String phone;
}

/// 内置通讯录：24 位联系人写死在常量里。
/// 本章主角是「过滤」这件事本身，数据从哪来不重要
const List<Contact> _contacts = <Contact>[
  Contact('张伟', '13812340001'),
  Contact('李娜', '13812340002'),
  Contact('王芳', '13812340003'),
  Contact('刘洋', '13812340004'),
  Contact('陈静', '13812340005'),
  Contact('杨帆', '13812340006'),
  Contact('赵敏', '13812340007'),
  Contact('黄磊', '13812340008'),
  Contact('周杰', '13812340009'),
  Contact('吴倩', '13812340010'),
  Contact('徐磊', '13812340011'),
  Contact('孙丽', '13812340012'),
  Contact('马超', '13812340013'),
  Contact('朱婷', '13812340014'),
  Contact('胡军', '13812340015'),
  Contact('郭靖', '13812340016'),
  Contact('林霞', '13812340017'),
  Contact('何平', '13812340018'),
  Contact('高远', '13812340019'),
  Contact('罗成', '13812340020'),
  Contact('郑洁', '13812340021'),
  Contact('王强', '13812340022'),
  Contact('冯雪', '13812340023'),
  Contact('曹阳', '13812340024'),
];

class ContactFilterApp extends StatelessWidget {
  const ContactFilterApp();

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ContactFilterPage(),
    );
  }
}

class ContactFilterPage extends StatefulWidget {
  const ContactFilterPage();

  @override
  State<ContactFilterPage> createState() => _ContactFilterPageState();
}

class _ContactFilterPageState extends State<ContactFilterPage> {
  // 全部状态就这一个搜索词：它一变，build 里每一步都重新算
  String _query = '';

  void _onQueryChanged(String value) {
    // 过滤没有「就地改列表」这个动作，只有「改 _query 让 build 重算」：
    // UI=f(state)——界面永远是状态这一次计算的结果（呼应第 1 章）
    setState(() {
      _query = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 每次重建都从头过滤一遍。24 条毫秒级完成，
    // 真实大列表再谈缓存与防抖，先让数据流保持这条最短的直路
    final List<Contact> filtered = _contacts
        .where((Contact c) => c.name.contains(_query))
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('联系人搜索')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: TextField(
              // 刻意不用 TextEditingController：本章只需要「击键就过滤」，
              // onChanged 回调已把新值送到手里，少管一个控制器对象
              onChanged: _onQueryChanged,
              decoration: const InputDecoration(
                hintText: '输入姓名，如：陈',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          // collection-if（正文 6.2）：没输入时这行计数整个不进列表，
          // 而不是渲染一个空 Text 占位——要不要这一项，让条件说了算
          if (_query.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '找到 ${filtered.length} 位联系人',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ),
          Expanded(
            // 空态三元：过滤结果为空时给一句明确的「无匹配联系人」，
            // 而不是留一片白——用户得能分清「没有结果」和「还没输入」
            child: filtered.isEmpty
                ? const Center(
                    child: Text('无匹配联系人', style: TextStyle(fontSize: 16)),
                  )
                : ListView.builder(
                    // itemCount + itemBuilder 是 builder 系列表的入场券：
                    // 框架只构建屏幕附近的行（正文 6.1 的惰性构建），
                    // 24 条无感，上千条时这就是流畅与卡顿的分水岭
                    itemCount: filtered.length,
                    itemBuilder: (BuildContext context, int index) {
                      final Contact contact = filtered[index];
                      return ListTile(
                        leading: const Icon(Icons.person_outline),
                        title: Text(contact.name),
                        subtitle: Text(contact.phone),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}