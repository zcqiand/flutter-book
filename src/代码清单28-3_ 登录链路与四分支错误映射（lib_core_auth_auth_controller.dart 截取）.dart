/// 认证状态机（riverpod Notifier）。
/// - login：submitting 门（防并发）→ sessionsLogin → token 非空校验 → save → Authed
/// - 四分支错误映射：423 锁定 / 401 错凭据 / 无响应=网络不可达 / 其余带响应=登录失败；
///   响应缺令牌单独文案（服务端契约破损，非传输问题）
/// - restore：accessToken 非空 → Authed（无 whoami，userId 空）；空 → Anonymous
/// - sessionExpired：清 store（写侧故障不阻断）+ 回 anonymous（401 缝回调）
/// - logout：best-effort 通知 + 本地清必达（clear 失败仍迁移 Anonymous）
class AuthController extends Notifier<AuthState> {
  late final AuthApi _api;
  late final TokenStore _store;
  late final String _clientId;

  @override
  AuthState build() {
    _api = ref.watch(authApiProvider);
    _store = ref.watch(tokenStoreProvider);
    _clientId = ref.watch(appConfigClientIdProvider);

    final guard = ref.watch(sessionGuardProvider);
    guard.onUnauthorized = sessionExpired;
    ref.onDispose(() => guard.onUnauthorized = null);

    Future.microtask(() async {
      final token = await _store.readAccessToken();
      if (state is AuthRestoring) {
        state = (token != null && token.isNotEmpty)
            ? const Authed()
            : const AuthAnonymous();
      }
    });
    return const AuthRestoring();
  }

  /// 密码登录（M01.F04.I01）。submitting 期间再调用是 no-op（RF#1）。
  Future<void> login(String username, String password) async {
    if (state is AuthSubmitting) return;
    state = const AuthSubmitting();
    final request = LoginRequest(
      (b) => b
        ..username = username
        ..password = password
        ..clientId = _clientId,
    );
    try {
      final response = await _api.sessionsLogin(loginRequest: request);
      final body = response.data;
      final access = body?.accessToken;
      final refresh = body?.refreshToken;
      if (body == null ||
          access == null ||
          access.isEmpty ||
          refresh == null ||
          refresh.isEmpty) {
        state = const AuthFailed('登录失败：服务端响应缺少令牌');
        return;
      }
      await _store.save(accessToken: access, refreshToken: refresh);
      state = Authed(
        userId: body.userId,
        currentTenantId: body.currentTenantId,
      );
    } on DioException catch (e) {
      state = AuthFailed(_message(e));
    } catch (_) {
      state = const AuthFailed('无法连接服务器');
    }
  }

// ……（节略：logout 与 sessionExpired，24.4 走读过的同构处置）

  static String _message(DioException e) {
    // 四分支对齐 react LoginPage（终审 I-2）：带响应 = 服务端应答过，
    // 不得谎报「无法连接服务器」；Phase 1 不透传服务端 message。
    if (e.response == null) return '无法连接服务器';
    final status = e.response?.statusCode;
    if (status == 423) return '账号已被锁定，请稍后再试';
    if (status == 401) return '用户名或密码错误';
    return '登录失败，请稍后再试';
  }
}

final authControllerProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);