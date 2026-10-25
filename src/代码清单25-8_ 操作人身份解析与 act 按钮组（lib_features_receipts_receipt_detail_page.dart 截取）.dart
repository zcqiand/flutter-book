// ===== 操作人身份解析 =====
/// operator 解析链（M03.F01.I04/I08）：displayName 非空优先，否则 userId；
/// 双空 = 无操作人身份 → act 按钮全禁。空串 displayName 不兜底（`??` 对空串
/// 不回退，记忆 saas-no-displayname-empty-string-fallback-trap；ADR-0019）。
String? _resolveOperator(AuthState auth) => switch (auth) {
  Authed(:final userId, :final displayName) =>
    (displayName?.isNotEmpty ?? false) ? displayName : userId,
  _ => null,
};

// ===== act 三动作按钮组：仅 receiving 阶段渲染 =====
        // act 三动作按钮组（M03.F01.I04 提交 / I08 三动作）：仅 receiving
        // 阶段渲染；无操作人身份 → 禁用 + Tooltip（不兜底）。
        if (receipt.flowStatus == FlowStatus.receiving)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                for (final (action, label) in <(FlowAction, String)>[
                  (FlowAction.submit, '提交'),
                  (FlowAction.return_, '退回'),
                  (FlowAction.withdraw, '撤回'),
                ])
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: operator == null
                          ? Tooltip(
                              message: '无操作人身份',
                              child: FilledButton(
                                onPressed: null,
                                child: Text(label),
                              ),
                            )
                          : FilledButton(
                              onPressed: () => ref
                                  .read(
                                    receiptDetailControllerProvider.notifier,
                                  )
                                  .act(action),
                              child: Text(label),
                            ),
                    ),
                  ),
              ],
            ),
          ),