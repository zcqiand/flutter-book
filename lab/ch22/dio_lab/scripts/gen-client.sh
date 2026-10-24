#!/bin/bash
# 生成 dart-dio 客户端：契约到 lib/generated/ 的三步链。
# 与案例仓 scripts/gen-shared.sh 同构（教学简化版）；工具前置为
# Node、Java 与 Flutter SDK 捆绑的 Dart，工具版本一律以案例仓
# tag 冻结版为准，此处不钉。教学契约源收在本工程 contract/ 目录。
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"

echo "[gen-client] step 1/3 - 契约发射 OpenAPI 规范文件..."
(cd "$ROOT/contract" && npm run emit:openapi)

OPENAPI="$ROOT/contract/generated/openapi.yaml"
if [ ! -f "$OPENAPI" ]; then
  echo "[gen-client] ERROR: missing $OPENAPI" >&2
  exit 1
fi

echo "[gen-client] step 2/3 - dart-dio 生成客户端到临时目录..."
# hideGenerationTimestamp=true：不关这个开关，每次生成都会因时间戳
# 不同产生整目录假 diff，把真实契约改动淹没在噪声里（案例仓同款教训）
rm -rf "$ROOT/.gen-tmp"
npx --yes @openapitools/openapi-generator-cli generate \
  -g dart-dio \
  -i "$OPENAPI" \
  -o "$ROOT/.gen-tmp/dart" \
  --additional-properties=hideGenerationTimestamp=true,pubName=contract_generated

echo "[gen-client] step 2.5/3 - 补齐模型序列化伴生文件..."
# dart-dio 产物里同样有 part 指令（与 14.4 的 json_serializable 同一机制），
# 有则须在临时包内跑 build_runner 把伴生文件补齐
if grep -rq "part '" "$ROOT/.gen-tmp/dart/lib"; then
  (cd "$ROOT/.gen-tmp/dart" && dart pub get)
  (cd "$ROOT/.gen-tmp/dart" && dart run build_runner build --delete-conflicting-outputs)
fi

echo "[gen-client] step 3/3 - 拷入 lib/generated/（先删后写）..."
# 先删后写是红线一的机械执行：目录整个换血，任何手改痕迹都被抹掉
mkdir -p "$ROOT/lib/generated"
rm -rf "$ROOT/lib/generated"/*
cp -r "$ROOT/.gen-tmp/dart/lib/src/." "$ROOT/lib/generated/"
# barrel 一并带入（案例仓同款流程）：消费方 import 的唯一入口
cp "$ROOT/.gen-tmp/dart/lib/contract_generated.dart" "$ROOT/lib/generated/"
# 生成物以生成包名自 import（package:contract_generated/...），
# 进宿主包后该前缀失效，确定性 sed 改写到宿主 generated/ 路径（幂等）
LC_ALL=C grep -rl 'package:contract_generated/src/' "$ROOT/lib/generated" \
  | xargs -r sed -i 's#package:contract_generated/src/#package:dio_lab/generated/#g'
# 守卫前置：包名自 import 残留 = 改写漏网，停下查（案例仓 fail-loud 同款）
if grep -rq 'package:contract_generated/' "$ROOT/lib/generated"; then
  echo "[gen-client] ERROR: 残留 package:contract_generated/ 自 import（改写规则失配）" >&2
  exit 3
fi
# 生成物目录级 analyzer 配置：error/warning 分析保留，仅关闭生成器
# 风格类 lint 与固有噪声告警（案例仓 gen-shared.sh 同款，目录每跑必重写）
cat > "$ROOT/lib/generated/analysis_options.yaml" <<'EOF'
# AUTO-WRITTEN BY scripts/gen-client.sh — DO NOT EDIT (regen wipes this dir).
# 生成物保留 error/warning 级分析（类型检查全量），linter 风格规则与生成器
# 固有噪声告警在本目录关闭；手写代码沿用仓库根 analysis_options。
include: ../../analysis_options.yaml
analyzer:
  errors:
    unused_import: ignore
    strict_raw_type: ignore
    unused_element_parameter: ignore
linter:
  rules:
    no_leading_underscores_for_local_identifiers: false
    use_function_type_syntax_for_parameters: false
    unnecessary_this: false
    unnecessary_lambdas: false
    use_super_parameters: false
    unnecessary_brace_in_string_interps: false
    constant_identifier_names: false
EOF
# 生成器输出与当前 SDK 格式化器有出入，格式化后的字节即最终形态（幂等）
dart format "$ROOT/lib/generated" >/dev/null
rm -rf "$ROOT/.gen-tmp"

# fail-loud 结构守卫：关键产物缺任一 = 生成器输出结构漂移，停下查
if [ -z "$(find "$ROOT/lib/generated/api" -name '*.dart' 2>/dev/null)" ] \
  || [ -z "$(find "$ROOT/lib/generated/model" -name '*.dart' 2>/dev/null)" ]; then
  echo "[gen-client] ERROR: lib/generated/api|model 无 dart 文件（生成器输出结构漂移？）" >&2
  exit 3
fi

echo "[gen-client] OK"
