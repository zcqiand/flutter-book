// 模型类把「数据长什么样」写进类型系统：错误从运行时前移到编译期
class UserProfile {
  UserProfile({required this.name, required this.age, this.email});

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        name: json['name'] as String,
        age: json['age'] as int,
        email: json['email'] as String?,
      );

  final String name;
  final int age;
  final String? email; // 可空字段显式声明：缺失即 null，而不是「说不清的错误形态」
}

void main() {
  final profile = UserProfile.fromJson({'name': '林小满', 'age': 28});

  // 编译期拦截一：键名写错不再静默——访问 profile.eamil 直接是编译错误
  print('邮箱: ${profile.email ?? '未填写'}');

  // 编译期拦截二：类型写错同样被拒——构造时把 '28' 传给 int 类型的 age 参数，编译不过
  print('邮箱长度: ${(profile.email ?? '').length}');
  print('档案: ${profile.name}，${profile.age} 岁');
}