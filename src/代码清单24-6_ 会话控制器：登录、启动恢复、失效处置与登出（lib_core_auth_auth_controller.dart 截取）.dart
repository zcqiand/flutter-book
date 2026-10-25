class AuthController extends Notifier<AuthState> {
  late final AuthApi _api;
  late final TokenStore _store;

// ……（节略）

  /// 原生登录（M01.F05.I06）。submitting 期间再调用是 no-op（RF#1）。
  Future<void> login(String username, String password) async {
    if (state is AuthSubmitting) return;
    state = const AuthSubmitting();
    final request = LoginRequest(
      (b) => b
        ..username = username
        ..password = password,
    );
    try {
      final response = await _api.authNativeLogin(loginRequest: request);
      final body = response.data;
      final access = body?.token;
      if (body == null || access == null || access.isEmpty) {
        state = const AuthFailed('登录失败：服务端响应缺少令牌');
        return;
      }
      await _store.save(
        accessToken: access,
        refreshToken: body.refreshToken, // 契约可选，可空直存
      );
      final user = body.user;
      state = Authed(
        userId: user.id,
        displayName: (user.displayName?.isNotEmpty == true)
            ? user.displayName
            : user.username,
      );
    } on DioException catch (e) {
      state = AuthFailed(_message(e));
    } catch (_) {
      state = const AuthFailed('无法连接服务器');
    }
  }

// ……（节略）

  @override
  AuthState build() {
    _api = ref.watch(authApiProvider);
    _store = ref.watch(tokenStoreProvider);

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

// ……（节略）

  /// 401 缝回调（SessionGuard.fire）：清 store + 回 anonymous。
  Future<void> sessionExpired() async {
    try {
      await _store.clear();
    } catch (_) {
      // 同 logout：清失败也必须迁移。
    }
    if (state is! AuthAnonymous) state = const AuthAnonymous();
  }

// ……（节略）

  /// 登出（M01.F05.I04）：服务端尽力通知，本地清空必达（有 token 才调服务端）。
  Future<void> logout() async {
    final access = await _store.readAccessToken();
    if (access != null && access.isNotEmpty) {
      try {
        await _api.authLogout(
          authLogoutRequest: AuthLogoutRequest((b) => b..token = access),
        );
      } catch (_) {
        // best-effort：服务端失败不阻断本地清理。
      }
    }
    try {
      await _store.clear();
    } catch (_) {
      // 存储写侧故障不阻断迁移（saas 终审 I-1 形态直带）：clear 成败不影响回 Anonymous。
    }
    state = const AuthAnonymous();
  }