/// 租户列表状态机（M00.F01.I01，G-10 三分错误形态）。
/// 契约无名称/状态过滤参数（G-11）——过滤是客户端侧：全量拉取存 _all，
/// keyword/statusFilter 变更即本地重发 Loaded，不发第二请求。

// ……（节略：TenantListState sealed 四态骨架，与 24.5 接样单列表同款）

class TenantListController extends Notifier<TenantListState> {
  late final AdminTenantsApi _api;
  BuiltList<Tenant> _all = BuiltList<Tenant>();
  String _keyword = '';
  TenantStatus? _statusFilter;

  @override
  TenantListState build() {
    _api = ref.watch(adminTenantsApiProvider);
    return const TenantListLoading();
  }

  /// 显式 page=0/pageSize=50（Review Focus 4：不依赖服务端默认）。
  /// page 0 基——四方契约判例 M96.F02.I60（不传→page=0）/I61（page=1 即第二页）。
  /// silent=true 不闪 loading（回刷复用）。
  Future<void> load({bool silent = false}) async {
    if (!silent) state = const TenantListLoading();
    try {
      final response = await _api.adminTenantsListTenants(
        page: 0,
        pageSize: 50,
      );
      if (!ref.mounted) return; // autoDispose：页 pop 后丢陈旧响应
      _all = response.data?.items ?? BuiltList<Tenant>();
      _emit();
    } on DioException catch (e) {
      if (!ref.mounted) return;
      state = TenantListError(message: _mapError(e));
    }
  }

  /// keyword 匹配 name 或 tenantKey（客户端侧，Review Focus 1 面外词不崩）。
  void setKeyword(String kw) {
    _keyword = kw.trim();
    _emit();
  }

  void setStatusFilter(TenantStatus? s) {
    _statusFilter = s;
    _emit();
  }

  void _emit() {
    if (_all.isEmpty) {
      state = const TenantListEmpty();
      return;
    }
    final filtered = _all.where(
      (t) =>
          (_keyword.isEmpty ||
              t.name.contains(_keyword) ||
              t.tenantKey.contains(_keyword)) &&
          (_statusFilter == null || t.status == _statusFilter),
    );
    state = TenantListLoaded(
      items: BuiltList<Tenant>(filtered),
      keyword: _keyword.isEmpty ? null : _keyword,
      statusFilter: _statusFilter,
    );
  }

  String _mapError(DioException e) {
    if (e.response == null) return '无法连接服务器';
    return '加载失败，请重试';
  }
}

/// autoDispose（lab 页级 provider 同口径：随页 pop 即 dispose）。
final tenantListControllerProvider =
    NotifierProvider.autoDispose<TenantListController, TenantListState>(
      TenantListController.new,
    );