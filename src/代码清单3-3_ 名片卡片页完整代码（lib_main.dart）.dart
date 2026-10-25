import 'package:flutter/material.dart';

void main() {
  // 入口只做装配：把整页 Widget 交给框架，往下的层级全靠组合一层层长出来
  runApp(
    const MaterialApp(
      home: CardPage(),
      debugShowCheckedModeBanner: false, // 名片页要见人，关掉右上角 DEBUG 角标
    ),
  );
}

/// 整页 Widget：Scaffold 只管骨架（底色与居中区），名片本体另起一个类。
/// 页面与卡片分开写，是给「小 Widget 拼大 Widget」留出拼接缝
class CardPage extends StatelessWidget {
  const CardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 页面压灰、卡片留白：层次感只靠一块底色差立起来，不必写任何阴影代码
      backgroundColor: const Color(0xFFF2F4F8),
      body: const Center(
        child: BusinessCard(),
      ),
    );
  }
}

/// 名片本体：容器、内边距、纵向排列各占一层，内容再分装成两个小 Widget。
/// 全链 const：整棵子树编译期定死，重建时复用同一实例，
/// 3.2 节那份「配置不可变」的契约就落在这一串 const 上
class BusinessCard extends StatelessWidget {
  const BusinessCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const Card(
      margin: EdgeInsets.symmetric(horizontal: 24),
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min, // 收着排：卡片只包住内容，不铺满整列
          children: [
            ProfileHeader(),
            SizedBox(height: 20),
            SkillTags(),
          ],
        ),
      ),
    );
  }
}

/// 头部行：用 Row 把头像与文字并排拼起来——「自己拼一个新 Widget」的第一处
class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        // 头像不用图片资源：CircleAvatar 给一块底色，姓氏首字顶格当头像，
        // 工程保持零资源依赖，任何机器拿到代码都能直接跑
        CircleAvatar(
          radius: 32,
          backgroundColor: Color(0xFF3D5AFE),
          child: Text(
            '林',
            style: TextStyle(fontSize: 24, color: Colors.white),
          ),
        ),
        SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start, // 文字靠左，别跟着 Row 居中
          children: [
            Text(
              '林知远',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(
              'Flutter 开发工程师',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ],
    );
  }
}

/// 标签区：三枚 Chip 交给 Wrap 排——空间够一行排开，不够自动换行
class SkillTags extends StatelessWidget {
  const SkillTags({super.key});

  @override
  Widget build(BuildContext context) {
    return const Wrap(
      spacing: 8, // 同一行标签之间的横向间距
      runSpacing: 8, // 换行之后行与行的间距
      children: [
        Chip(label: Text('Dart 3')),
        Chip(label: Text('Widget 组合')),
        Chip(label: Text('多端运行')),
      ],
    );
  }
}