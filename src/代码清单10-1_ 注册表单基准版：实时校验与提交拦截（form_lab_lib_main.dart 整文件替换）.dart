// ============================================================
// 教学演示版本：正文 10.1 Form/validator 体系与实时校验、提交拦截。
// 复现操作序列：
//   1. flutter create form_lab，整文件替换 lib/main.dart；
//   2. flutter run -d windows；
//   3. 邮箱框输入不含 @ 的文本，看错误文案是否随输入实时出现，
//      把 @ 补上，再看文案是否实时消失；
//   4. 密码只填 3 位，直接点「注册」，观察输入框下的错误提示，
//      以及控制台有没有打印提交信息（没有即拦截生效）。
// 看什么：validator 的返回值如何变成错误文案；validate() 返回 false
//   时提交逻辑被挡在哪一行。
// 单文件自包含，零第三方依赖。
// ============================================================
import 'package:flutter/material.dart';

void main() {
  runApp(const FormLabApp());
}

class FormLabApp extends StatelessWidget {
  const FormLabApp();

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: RegisterPage(),
    );
  }
}

class RegisterPage extends StatefulWidget {
  const RegisterPage();

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // Form 的身份凭证：提交按钮和表单隔着整棵子树，谁也够不着谁，
  // 只有攥住 GlobalKey 才能在提交时拿到 FormState 调 validate()
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    // 第 7 章立的清理纪律在表单域同样生效：控制器随 State 销毁释放
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // 约定很简单：返回 null 表示通过，返回字符串表示不通过，
  // 且这个字符串就是显示在输入框下方的错误文案。
  // 校验规则写在函数里而不是散在按钮回调里，规则才有了唯一住址
  String? _validateEmail(String? value) {
    final String text = value ?? '';
    if (text.isEmpty) {
      return '邮箱不能为空';
    }
    if (!text.contains('@')) {
      return '邮箱格式不正确，需要包含 @';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if ((value ?? '').length < 6) {
      return '密码至少 6 位';
    }
    return null;
  }

  void _submit() {
    // validate() 会沿 Form 的后代逐个执行 validator：
    // 全部通过返回 true；任何一个不过返回 false，
    // 同时错误文案已经落到对应输入框下面，不需要你手动管理提示
    final bool valid = _formKey.currentState?.validate() ?? false;
    if (!valid) {
      // 提交拦截的落点就在这一行：校验不过，函数折返，
      // 下面的提交逻辑根本没有机会执行
      return;
    }
    debugPrint('提交：${_emailController.text}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('注册')),
      body: Form(
        key: _formKey,
        // always：每次输入变化都重跑 validator，错误文案实时进退。
        // 若只想在点提交时才校验，换 disabled 即可，两种模式先体验再选
        autovalidateMode: AutovalidateMode.always,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: '邮箱'),
              validator: _validateEmail,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: '密码'),
              validator: _validatePassword,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _submit,
              child: const Text('注册'),
            ),
          ],
        ),
      ),
    );
  }
}