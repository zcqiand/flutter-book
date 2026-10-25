import 'package:built_collection/built_collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:saas_identity_platform_flutter/generated/saas_shared_generated.dart';

import 'role_providers.dart';

/// 角色列表状态机（member_list_controller 同构）：sealed 四态。
sealed class RoleListState {
  const RoleListState();
}

class RoleListLoaded extends RoleListState {
  const RoleListLoaded({required this.items, required this.clientFilter});

  final BuiltList<SysRole> items;

  /// clientId 服务端过滤（null=全部）。
  final String? clientFilter;
}

// ……（节略：Loading 与 Empty、Error 三个状态类，sealed 四态同前款）

/// 角色列表控制器：tenant-scoped（family by tenantId）；列表固定
/// page=0&pageSize=50（0 基判例），clientId chip 是服务端参数。
class RoleListController extends Notifier<RoleListState> {
  RoleListController(this.tenantId);

  final String tenantId;

  String? _clientFilter;

  @override
  RoleListState build() => const RoleListLoading();

  Future<void> load({bool silent = false}) async {
    if (!silent) state = const RoleListLoading();
    try {
      final resp = await ref
          .read(roleApiProvider)
          .tenantRolesListSysRoles(
            tenantId: tenantId,
            clientId: _clientFilter,
            page: 0,
            pageSize: 50,
          );
      final items = resp.data!.items;
      state = items.isEmpty
          ? const RoleListEmpty()
          : RoleListLoaded(items: items, clientFilter: _clientFilter);
    } on Exception {
      state = const RoleListError('无法连接服务器');
    }
  }

  Future<void> setClientFilter(String? clientId) async {
    _clientFilter = clientId;
    await load();
  }
}

final roleListControllerProvider = NotifierProvider.autoDispose
    .family<RoleListController, RoleListState, String>(RoleListController.new);