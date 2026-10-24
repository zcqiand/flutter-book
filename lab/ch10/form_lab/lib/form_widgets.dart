// ============================================================
// 参数化表单组件库：正文 10.5 实战底座，三档设计合流后的正式版。
// 复现操作序列：
//   1. 文件放 form_lab/lib/form_widgets.dart；
//   2. 由清单 10-7 的两个页面调用，同一套组件跑出两种表单。
// 看什么：每个参数属于哪一档；哪些参数能进 const 构造；
//   组件里为什么找不到任何一条具体业务规则。
// 纯 Flutter 组件文件，零第三方依赖。
// ============================================================
import 'package:flutter/material.dart';

/// 带标签的输入行：label 必选，提示与键盘可选，校验与联动是回调。
/// 全部字段 final 加 const 构造，组件自身无状态，可以放心参与 const 化
class LabeledField extends StatelessWidget {
  const LabeledField({
    super.key,
    required this.label,
    required this.controller,
    this.hintText,
    this.keyboardType,
    this.obscureText = false,
    this.validator,
    this.onChanged,
  });

  // 必选档：没有标签和控制器，这个组件就不成立
  final String label;
  final TextEditingController controller;

  // 可选档：调用方不传，组件按默认形态工作
  final String? hintText;
  final TextInputType? keyboardType;
  final bool obscureText;

  // 回调档：校验规则与输入响应由调用方注入。
  // 组件不认识「邮箱」「手机号」，两页才能共用；认识业务的只有页面
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(label),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          validator: validator,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hintText,
            border: const OutlineInputBorder(),
          ),
        ),
      ],
    );
  }
}

/// 提交条：提交文案可选（有默认值），动作必为回调。
/// 组件不知道自己在注册页还是在地址页，文案差异由页面用参数表达
class SubmitBar extends StatelessWidget {
  const SubmitBar({
    super.key,
    this.submitLabel = '提交',
    required this.onSubmit,
  });

  final String submitLabel;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onSubmit,
      child: Text(submitLabel),
    );
  }
}
