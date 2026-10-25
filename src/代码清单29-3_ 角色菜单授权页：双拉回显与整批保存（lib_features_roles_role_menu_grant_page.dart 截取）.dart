// @entry M00.F04.I02
import 'package:built_collection/built_collection.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:saas_identity_platform_flutter/generated/saas_shared_generated.dart';

import 'role_providers.dart';

/// 角色菜单授权页（M00.F04.I02 回显 / I03 整批设置 / I04 清空）：
/// 目录按角色 clientId 拉（client 作用域），现授权按 roleId 拉——经 clientId
/// 对齐；保存 = PUT 全量替换（契约语义，恰勾选全集）；清空 = DELETE +
/// 确认（明示「清空后该角色登录不再渲染任何菜单」）。入口：角色列表行
/// 「菜单授权」。I01 权限矩阵已废弃（ADR-0025）不呈现。
class RoleMenuGrantPage extends ConsumerStatefulWidget {
// ……（节略：四件行李参数与生命周期）

  /// 并行拉目录 + 现授权（I02）；任一失败整页错误态。
  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        ref
            .read(clientMenusApiProvider)
            .clientMenusListSysMenus(clientId: widget.clientId)
            .then((r) => r.data!),
        ref
            .read(roleMenuGrantApiProvider)
            .tenantRoleMenusListSysRoleMenus(
              tenantId: widget.tenantId,
              roleId: widget.roleId,
            )
            .then((r) => r.data!),
      ]);
      if (!mounted) return;
      setState(() {
        _catalog = results[0] as BuiltList<SysMenu>;
        _checked = (results[1] as RoleMenuGrant).menuIds.toSet();
        _loading = false;
      });
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.response == null ? '无法连接服务器' : '加载失败';
        _loading = false;
      });
    }
  }

  /// 整批设置（I03）：PUT body 恰当前勾选全集（全量替换语义）。
  Future<void> _save() async {
    try {
      await ref
          .read(roleMenuGrantApiProvider)
          .tenantRoleMenusSetSysRoleMenus(
            tenantId: widget.tenantId,
            roleId: widget.roleId,
            setSysRoleMenusRequest: SetSysRoleMenusRequest(
              (b) => b..menuIds.replace(BuiltList<String>(_checked)),
            ),
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('授权已保存')));
      await _load(); // 静默回读（勾选态与服务端对齐）
    } on DioException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.response == null ? '无法连接服务器' : '保存失败，请重试')),
      );
    }
  }

// ……（节略：清空确认链与勾选列表骨架）
}