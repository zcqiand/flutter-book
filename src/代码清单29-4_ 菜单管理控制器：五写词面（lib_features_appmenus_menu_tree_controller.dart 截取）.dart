/// 根菜单 parentId（后端 b.parentId ?? 零 UUID；契约 parentId 非空）。
const String kMenuRootParentId = '00000000-0000-0000-0000-000000000000';

// ……（节略：imports 与 sealed 四态，同前款）

/// 菜单管理控制器（REQ-2026-011 M04.F04）：扁平 list + 增删改 + 排序 +
/// 移动。写成功后静默回刷（层级/顺序变更面大，逐项回填不划算；更新除
/// 外——PATCH 响应权威快照按 id 回填）。family by clientId（菜单是
/// client-scoped 面）。
class MenuTreeController extends Notifier<MenuTreeState> {
// ……（节略：构造与 load）

// ……（节略：create（I02，父级空即顶级）、update（I04，PATCH 不带父编号，响应按 id 原位回填）、remove（I05，级联清理）三写方法体，同款 try 收口）

  /// 同级排序（I06）：orderedMenuIds=该菜单同级（含自身）新顺序。
  Future<bool> reorder(String menuId, BuiltList<String> orderedMenuIds) async {
    try {
      await ref
          .read(clientMenusApiProvider)
          .clientMenusReorderSysMenus(
            clientId: clientId,
            menuId: menuId,
            reorderSysMenuRequest: ReorderSysMenuRequest(
              (b) => b..orderedMenuIds.replace(orderedMenuIds),
            ),
          );
      await load(silent: true);
      return true;
    } on Exception {
      return false;
    }
  }

  /// 切换父级（I07）：PATCH /parent。
  Future<bool> move(String menuId, String? parentId) async {
    try {
      await ref
          .read(clientMenusApiProvider)
          .clientMenusMoveSysMenu(
            clientId: clientId,
            menuId: menuId,
            clientMenusMoveSysMenuRequest: ClientMenusMoveSysMenuRequest(
              (b) => b..parentId = parentId,
            ),
          );
      await load(silent: true);
      return true;
    } on Exception {
      return false;
    }
  }

// ……（节略：_replace 按 id 原位回填与 provider 声明）
}