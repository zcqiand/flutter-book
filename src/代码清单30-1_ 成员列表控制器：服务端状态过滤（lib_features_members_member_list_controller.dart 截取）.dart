import 'package:built_collection/built_collection.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:saas_identity_platform_flutter/generated/saas_shared_generated.dart';

import 'member_providers.dart';

/// 成员列表状态机（M00.F02.I01，tenantListController 同构；G-10 三分错误形态）。
/// 与租户列表不同：契约带 status 服务端过滤参数——chip 切换走真请求，
/// 不做客户端侧过滤。
sealed class MemberListState {
  const MemberListState();
}

class MemberListLoaded extends MemberListState {
  const MemberListLoaded({required this.items, this.statusFilter});
  final BuiltList<TenantMemberUserView> items;
  final TenantMemberStatus? statusFilter;
}

// ……（节略：Loading 与 Empty、Error 三个状态类，sealed 四态同前款）

/// family by tenantId（成员是 tenant-scoped 面）。
class MemberListController extends Notifier<MemberListState> {
  MemberListController(this.tenantId);

  final String tenantId;
  late final TenantMembersApi _api;
  TenantMemberStatus? _statusFilter;

  @override
  MemberListState build() {
    _api = ref.watch(tenantMembersApiProvider);
    return const MemberListLoading();
  }

  /// 显式 page=0/pageSize=50（契约 0 基判例，M00.F01 同款不依赖服务端默认）。
  /// status chip 参数服务端过滤；silent=true 不闪 loading（回刷复用）。
  Future<void> load({bool silent = false}) async {
    if (!silent) state = const MemberListLoading();
    try {
      final response = await _api.tenantMembersListTenantUsers(
        tenantId: tenantId,
        page: 0,
        pageSize: 50,
        status: _statusFilter,
      );
      final items = response.data!.items;
      state = items.isEmpty
          ? const MemberListEmpty()
          : MemberListLoaded(items: items, statusFilter: _statusFilter);
    } on DioException catch (e) {
      state = MemberListError(
        message: e.response == null ? '无法连接服务器' : '加载失败，请重试',
      );
    }
  }

  Future<void> setStatusFilter(TenantMemberStatus? status) async {
    _statusFilter = status;
    await load();
  }
}

final memberListControllerProvider = NotifierProvider.autoDispose
    .family<MemberListController, MemberListState, String>(
      MemberListController.new,
    );