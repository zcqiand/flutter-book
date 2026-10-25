// @entry M01.F02.I01
// ……（节略：imports 与弹窗参数，tenantId 加 member 两件行李）

/// 分配角色弹窗（M01.F02.I01）：member↔role 关系面，全量覆盖语义——
/// 预勾 member.roleIds，勾选集即 PUT body，空选=合法清空。
class AssignMemberRolesDialog extends ConsumerStatefulWidget {
  const AssignMemberRolesDialog({
    super.key,
    required this.tenantId,
    required this.member,
  });

  final String tenantId;
  final TenantMemberUserView member;

// ……（节略：状态类与生命周期）

  List<SysRole>? _roles;
  String? _loadError;
  late final Set<String> _selected = widget.member.roleIds.toSet();
  bool _saving = false;
  String? _error;

  Future<void> _save() async {
    if (_saving) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref
          .read(tenantMembersApiProvider)
          .tenantMembersAssignTenantMemberRoles(
            tenantId: widget.tenantId,
            userId: widget.member.id,
            setTenantMemberRolesRequest: SetTenantMemberRolesRequest(
              (b) => b..roleIds.replace(BuiltList<String>(_selected.toList())),
            ),
          );
      if (!mounted) return;
      Navigator.of(context).pop(true); // 页侧凭 true 出 SnackBar + 回刷
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = e.response == null ? '无法连接服务器' : '保存失败，请重试';
      });
    }
  }

// ……（节略：角色册拉取与角色勾选列表骨架，一行一角色）
}