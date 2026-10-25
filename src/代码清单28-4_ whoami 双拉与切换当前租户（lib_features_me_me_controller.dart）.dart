import 'package:built_collection/built_collection.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:saas_identity_platform_flutter/generated/saas_shared_generated.dart';

import 'me_providers.dart';

/// 「我」页状态机（application_list_controller 同构）：sealed 三态。
sealed class MeState {
  const MeState();
}

class MeLoading extends MeState {
  const MeLoading();
}

class MeLoaded extends MeState {
  const MeLoaded({required this.user, required this.memberships});

  final CurrentUser user;
  final BuiltList<TenantMembership> memberships;
}

class MeError extends MeState {
  const MeError(this.message);

  final String message;
}

/// 「我」页控制器：whoami + 我的租户成员关系双拉（Future.wait）。
class MeController extends Notifier<MeState> {
  @override
  MeState build() => const MeLoading();

  Future<void> load({bool silent = false}) async {
    if (!silent) state = const MeLoading();
    try {
      final results = await Future.wait([
        ref.read(meApiProvider).meWhoami(),
        ref.read(meApiProvider).meListMyTenants(),
      ]);
      state = MeLoaded(
        user: (results[0] as Response<CurrentUser>).data!,
        memberships:
            (results[1] as Response<BuiltList<TenantMembership>>).data!,
      );
    } on Exception {
      state = const MeError('无法连接服务器');
    }
  }

  /// 切换当前租户（M01.F03.I02）：POST switch 成功后 silent 回刷
  /// whoami（当前租户展示更新）。返回是否成功。
  Future<bool> switchTenant(String tenantId) async {
    try {
      await ref.read(meApiProvider).meSwitchTenant(tenantId: tenantId);
      await load(silent: true);
      return true;
    } on Exception {
      return false;
    }
  }
}

final meControllerProvider =
    NotifierProvider.autoDispose<MeController, MeState>(MeController.new);