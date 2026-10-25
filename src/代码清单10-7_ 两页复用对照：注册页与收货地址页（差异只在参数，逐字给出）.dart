// ============================================================
// 两页复用对照：正文 10.5 实战，注册页与收货地址页共用清单 10-6。
// 复现操作序列：
//   1. 整文件替换 form_lab/lib/main.dart；
//   2. flutter run -d windows，首页两颗按钮分别进两页；
//   3. 改注册页的密码规则为 8 位再热重载，确认只动了本页参数，
//      组件库一行没碰，地址页不受影响。
// 看什么：两页 build 结构逐字平行，差异全部收敛在参数里。
// 依赖同工程 lib/form_widgets.dart（清单 10-6），零第三方依赖。
// ============================================================
import 'package:flutter/material.dart';

import 'form_widgets.dart';

void main() {
  runApp(const FormLabApp());
}

class FormLabApp extends StatelessWidget {
  const FormLabApp();

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('form_lab')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FilledButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) => const RegisterPage(),
                  ),
                );
              },
              child: const Text('去注册页'),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) => const AddressPage(),
                  ),
                );
              },
              child: const Text('去收货地址页'),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== 注册页 ====================
class RegisterPage extends StatefulWidget {
  const RegisterPage();

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    final bool valid = _formKey.currentState?.validate() ?? false;
    if (!valid) {
      return;
    }
    debugPrint('注册提交：${_emailController.text}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('注册')),
      body: Form(
        key: _formKey,
        // 两页均未设 autovalidateMode，默认回落 disabled：
        // 红字只在点提交时全表重查，与清单 10-1 的 always 实时轨互为对照
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            // 唯一差异=参数：label 文案、提示文案、键盘类型、校验规则
            LabeledField(
              label: '邮箱',
              controller: _emailController,
              hintText: 'name@example.com',
              keyboardType: TextInputType.emailAddress,
              validator: (String? value) =>
                  (value ?? '').contains('@') ? null : '邮箱需包含 @',
              onChanged: (String value) => debugPrint('邮箱输入：$value'),
            ),
            const SizedBox(height: 12),
            // 唯一差异=参数：label 文案、密文开关、校验规则
            LabeledField(
              label: '密码',
              controller: _passwordController,
              obscureText: true,
              validator: (String? value) =>
                  (value ?? '').length < 6 ? '密码至少 6 位' : null,
            ),
            const SizedBox(height: 24),
            // 唯一差异=参数：提交文案
            SubmitBar(submitLabel: '注册', onSubmit: _submit),
          ],
        ),
      ),
    );
  }
}

// ==================== 收货地址页 ====================
// 与注册页逐字平行：同样的 State 字段清单、同样的 _submit、
// 同样的 Form 加 ListView 骨架，往下读到每一处差异都有注释标注
class AddressPage extends StatefulWidget {
  const AddressPage();

  @override
  State<AddressPage> createState() => _AddressPageState();
}

class _AddressPageState extends State<AddressPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _detailController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _detailController.dispose();
    super.dispose();
  }

  void _submit() {
    final bool valid = _formKey.currentState?.validate() ?? false;
    if (!valid) {
      return;
    }
    debugPrint('地址提交：${_nameController.text}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('收货地址')),
      body: Form(
        key: _formKey,
        // 两页均未设 autovalidateMode，默认回落 disabled：
        // 红字只在点提交时全表重查，与清单 10-1 的 always 实时轨互为对照
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            // 唯一差异=参数：label 文案、校验规则；键盘类型回落默认
            LabeledField(
              label: '收货人',
              controller: _nameController,
              hintText: '姓名',
              validator: (String? value) =>
                  (value ?? '').isEmpty ? '请填写收货人' : null,
            ),
            const SizedBox(height: 12),
            // 唯一差异=参数：label 文案、键盘类型（数字键盘）、校验规则
            LabeledField(
              label: '联系电话',
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              validator: (String? value) =>
                  (value ?? '').length == 11 ? null : '手机号需为 11 位',
            ),
            const SizedBox(height: 12),
            // 唯一差异=参数：label 文案、校验规则
            LabeledField(
              label: '详细地址',
              controller: _detailController,
              validator: (String? value) =>
                  (value ?? '').length >= 5 ? null : '地址至少 5 个字',
            ),
            const SizedBox(height: 24),
            // 唯一差异=参数：提交文案
            SubmitBar(submitLabel: '保存地址', onSubmit: _submit),
          ],
        ),
      ),
    );
  }
}