# ===== saas-identity-platform-flutter — Web 静态容器 =====
# saas 家族 X08 扩展槽位启用（2026-10-10）：容器内 nginx:alpine :80，host 127.0.0.1:5108。
# 形态照 saas-react（同家族 SPA 静态容器先例）；构建链是 Flutter Web。
#
# prod 配置烘焙（禁兜底铁律：两键缺一，lib/core/config/app_config.dart validate() 启动即抛）：
#   API_BASE_URL=https://saas-nextjs.xiangru.uk   —— prod 基线后端（与 dev 默认 :5101 对称）
#   SAAS_CLIENT_ID=saas-console
#
# builder 不用社区 Flutter 镜像（ghcr.io/cirruslabs/flutter 已停更于 3.14.x，无 3.4x tag），
# 改用官方 stable tarball：URL 内嵌精确版本，flutter --version 断言兜底防漂移。

FROM debian:12-slim AS builder

RUN apt-get update \
  && apt-get install -y --no-install-recommends bash curl git xz-utils ca-certificates \
  && rm -rf /var/lib/apt/lists/*

# 官方 stable tarball（含预编译 Dart SDK，首启无需额外下载 engine 件）
RUN curl -fsSL "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.47.6-stable.tar.xz" \
  | tar -xJ -C /opt
ENV PATH="/opt/flutter/bin:${PATH}"

# tarball 内文件属主 uid ≠ 容器运行用户 → git 报 dubious ownership，flutter 工具
# 全部命令（含 --version）即崩。放行 SDK 目录属配置修复，非门禁放宽。
RUN git config --global --add safe.directory /opt/flutter

# 版本钉死断言：tarball URL 与本断言双保险，任何一环漂移都 fail-fast
RUN flutter --version | grep -q 'Flutter 3.47.6' \
  || { echo "ERROR: Flutter 版本漂移，期望 3.47.6" >&2; exit 1; }

WORKDIR /app
# pub 依赖直连 pub.dev（Actions runner 在美西；PUB_HOSTED_URL 镜像是本机 Windows 开发策略，
# 见 docs/conventions/flutter-app.md §4，CI/容器内不设）
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

COPY . .
RUN flutter build web --release \
  --pwa-strategy=none \
  --dart-define=API_BASE_URL=https://saas-nextjs.xiangru.uk \
  --dart-define=SAAS_CLIENT_ID=saas-console

# 烘焙断言：容器探活 200 证不了 dart-define 真烘进 bundle（那是运行时断言），
# 构建期直接验产物——断言失败 = 链路某处把烘焙键丢了，宁红不放
RUN grep -q 'saas-nextjs\.xiangru\.uk' build/web/main.dart.js \
  || { echo "ERROR: API_BASE_URL 未烘进产物" >&2; exit 1; }

FROM nginx:alpine AS runtime
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=builder /app/build/web /usr/share/nginx/html
EXPOSE 80
# 探活一律 127.0.0.1 字面量（busybox wget 把 localhost 解析成 ::1 的家族指纹）
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD wget -qO- http://127.0.0.1/ >/dev/null || exit 1
CMD ["nginx", "-g", "daemon off;"]