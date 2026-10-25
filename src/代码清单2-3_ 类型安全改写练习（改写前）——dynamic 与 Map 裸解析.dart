void main() {
  // 模拟一条接口返回：用户档案，email 字段可能缺失
  final Map<String, dynamic> profile = {
    'name': '林小满',
    'age': 28,
  };

  // 风险点一：键名打错（eamil），编译器不吭声——dynamic 上的任何拼写都合法
  final dynamic email = profile['eamil'];
  print('邮箱: $email'); // 预期输出 null：错误被推迟到展示层才露馅

  // 风险点二：字段缺失还裸调用成员方法，运行时才炸（此处捕获以便对照观察爆炸形态）
  final dynamic nickname = profile['nickname'];
  try {
    print('昵称长度: ${nickname.length}');
  } catch (error) {
    // 预期输出 NoSuchMethodError：Class 'Null' has no instance getter 'length'
    print('运行时才炸: $error');
  }
}