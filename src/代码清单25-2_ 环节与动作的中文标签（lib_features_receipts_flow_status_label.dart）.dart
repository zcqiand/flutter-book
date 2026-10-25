import 'package:lab_management_system_flutter/generated/lab_shared_generated.dart'
    hide AuthState;

/// FlowStatus → 中文标签（G-12 全 8 值，漏一值测试即红）。
String flowStatusLabel(FlowStatus status) {
  return switch (status) {
    FlowStatus.receiving => '接收登记',
    FlowStatus.taskAssignment => '任务分配',
    FlowStatus.dataEntry => '数据录入',
    FlowStatus.review => '审核',
    FlowStatus.approval => '审批',
    FlowStatus.issuance => '签发',
    FlowStatus.archived => '归档',
    FlowStatus.completed => '完成',
    // EnumClass 非 sealed，编译器不认穷举：漏一值时测试先红，此处兜不住的
    // 未知枚举值 fail-fast（禁静默回退，suite-hard-rules §1 同纪律）。
    _ => throw ArgumentError('未知 FlowStatus: ${status.name}'),
  };
}

/// FlowAction → 中文标签（流程历史时间线用，flowStatusLabel 同款纪律）。
String flowActionLabel(FlowAction a) => switch (a) {
  FlowAction.submit => '提交',
  FlowAction.return_ => '退回',
  FlowAction.withdraw => '撤回',
  // EnumClass 非 sealed：未知值 fail-fast（禁静默回退）。
  _ => throw ArgumentError('未知 FlowAction: ${a.name}'),
};