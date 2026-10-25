import 'package:flutter/material.dart';

void main() {
  runApp(
    const MaterialApp(
      home: SettingsPage(),
      debugShowCheckedModeBanner: false, // 原型页要见人，关掉右上角 DEBUG 角标
    ),
  );
}

/// 整页骨架。本页零状态：所有内容在编译期就定死，没有任何一块会自己变，
/// 所以只用 StatelessWidget 就够（会自己变的有状态版见 4.4 节）。
/// 纵向用 ListView 而非 Column：内容超出屏高时滚动兜底，
/// 让三档尺寸验证只操心横向溢出这一件事
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 页面压灰、卡片留白：层次感只靠一块底色差立起来，与第 3 章名片页同一手法
      backgroundColor: const Color(0xFFF2F4F8),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          ProfileHeaderCard(),
          SizedBox(height: 16),
          GroupLabel(label: '通用'),
          SettingRow(
            icon: Icons.person,
            iconBackgroundColor: Color(0xFF3D5AFE),
            title: '个人资料',
            subtitle: '昵称、头像与一句话简介',
          ),
          SettingRow(
            icon: Icons.notifications,
            iconBackgroundColor: Color(0xFFFF8F00),
            title: '消息通知',
            subtitle: '接收活动提醒与系统公告',
            // 开关占位：静态图标假装开关，真正的交互版 SwitchListTile 见清单4-4
            trailing: Icon(Icons.toggle_on, size: 32, color: Color(0xFF3D5AFE)),
          ),
          SettingRow(
            icon: Icons.lock_outline,
            iconBackgroundColor: Color(0xFF00897B),
            title: '隐私设置',
            subtitle: '谁可以看到我的动态与收藏',
          ),
          SettingRow(
            icon: Icons.help_outline,
            iconBackgroundColor: Color(0xFF8E24AA),
            title: '帮助与反馈',
            subtitle: '常见问题与意见提交入口',
          ),
          SizedBox(height: 24),
          LogoutButton(),
        ],
      ),
    );
  }
}

/// 分组小标题：设置页常见的「灰底上先来一行小字」，
/// 用 Padding + Text 两层就够，不必为它专门造复杂组件
class GroupLabel extends StatelessWidget {
  const GroupLabel({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
      child: Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
    );
  }
}

/// 顶部资料区。Stack 的尺寸由不定位的孩子（大圆头像）撑起，
/// Positioned 的徽标只负责「浮在右下角」，不参与尺寸计算也不占排位——
/// 这就是层叠布局与横竖排布局的本质分工：一个管叠，一个管排
class ProfileHeaderCard extends StatelessWidget {
  const ProfileHeaderCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      // 装饰三件套在 Container 身上凑齐：白底、圆角、内边距
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              // 头像不用图片资源：底色加姓氏首字顶格当头像，
              // 工程保持零资源依赖，任何机器拿到代码都能直接跑（第 3 章先例）
              const CircleAvatar(
                radius: 32,
                backgroundColor: Color(0xFF3D5AFE),
                child: Text('林', style: TextStyle(fontSize: 24, color: Colors.white)),
              ),
              // 白描边把徽标从头像里「抠」出来：不用阴影不贴图，两色边框就够
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: const Color(0xFF00C853),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          // 文字列同样包 Expanded：资料行的两行字将来可能改长，
          // 弹性宽度在小屏上换行消化，而不是把整行撑出边界
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('林知远', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text('账号与同步状态正常', style: TextStyle(fontSize: 13, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 单条设置行：一个 SettingRow 复用四次，Row 横向拼三段——图标区、文字列、尾部。
/// 文字列必须包 Expanded：Row 先给不弹性的孩子（图标、尾部）分死位置，
/// 再把剩余宽度全交给弹性孩子；不包 Expanded，长标题在 360 宽的小屏上
/// 会直接把行撑出边界，撞上 Flutter 最著名的黄黑斜纹溢出报错
class SettingRow extends StatelessWidget {
  const SettingRow({
    super.key,
    required this.icon,
    required this.iconBackgroundColor,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  final IconData icon;
  final Color iconBackgroundColor;
  final String title;
  final String subtitle;
  final Widget? trailing; // 尾部占位：不传就用默认箭头，本页只有开关那行传了占位

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconBackgroundColor,
              borderRadius: BorderRadius.circular(8),
            ),
            // 图标用内置 Icons 字体，同样零资源；小色块当底，
            // 让每行图标各有身份色，这是真实设置页的通用做法
            child: Icon(icon, size: 20, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 2),
                // 副标题是三档尺寸里最长的文本：Expanded 把剩余宽度全交给它，
                // 再长的标题也是 Text 自己内部换行，不会把整行撑出边界
                Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          trailing ?? const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }
}

/// 底部退出按钮：Container 管装饰（白底、圆角、占满一行），
/// 点击本体交给 TextButton——布局与行为分家。
/// 零状态页按下没有下文，按钮真正开始干活在 4.6 节的交互页里
class LogoutButton extends StatelessWidget {
  const LogoutButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, // 宽度交给父级约束决定，不写死像素，三档尺寸通用
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextButton(
        onPressed: () {}, // 空回调保持按钮可用态；换成 null 会变灰禁用，观感失真
        child: const Text('退出登录', style: TextStyle(color: Colors.redAccent)),
      ),
    );
  }
}