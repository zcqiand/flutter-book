// ============================================================
// 设计演进示意：正文 10.4 参数化三档，同一个 LabeledField 的三个版本。
// 三版并列只为看清「每加一档，调用方少了多少重复」，
// 本清单不入工程；实战合流后的正式版见清单 10-6。
// 零第三方依赖。
// ============================================================
import 'package:flutter/material.dart';

// v1 只开放必选：label 和 controller 缺一不可。
// 调用方被强制填满所有参数，想要提示文案的页面连传参入口都没有
class LabeledFieldV1 extends StatelessWidget {
  const LabeledFieldV1({
    super.key,
    required this.label,
    required this.controller,
  });

  final String label;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(label),
        TextField(controller: controller),
      ],
    );
  }
}

// v2 补上可选档：hintText 给了默认值、readOnly 给了默认关。
// 可选参数的收益在调用端：不传就走默认形态，传了才覆盖，
// 「少数页面才需要的差异化」从必选项里退了出去
class LabeledFieldV2 extends StatelessWidget {
  const LabeledFieldV2({
    super.key,
    required this.label,
    required this.controller,
    this.hintText = '',
    this.readOnly = false,
  });

  final String label;
  final TextEditingController controller;
  final String hintText;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(label),
        TextField(
          controller: controller,
          readOnly: readOnly,
          decoration: InputDecoration(hintText: hintText),
        ),
      ],
    );
  }
}

// v3 再补回调档：输入变化、提交动作的处置权交还调用方。
// 组件只负责「什么时候发生」，不负责「发生了怎么办」，
// 校验规则、联动逻辑不同的一百个页面因此可以共用同一个组件
class LabeledFieldV3 extends StatelessWidget {
  const LabeledFieldV3({
    super.key,
    required this.label,
    required this.controller,
    this.hintText = '',
    this.readOnly = false,
    this.onChanged,
    this.onSubmitted,
  });

  final String label;
  final TextEditingController controller;
  final String hintText;
  final bool readOnly;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(label),
        TextField(
          controller: controller,
          readOnly: readOnly,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          decoration: InputDecoration(hintText: hintText),
        ),
      ],
    );
  }
}