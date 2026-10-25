# ……（节略 L1-103：用法注释、set -eu、入参校验、vhost 渲染段，见仓内原文）

echo "→ image: $IMAGE"
echo "→ docker login"
printf '%s' "$PASSWORD" | docker login -u "$USERNAME" --password-stdin

echo "→ docker pull"
docker pull "$IMAGE"

echo "→ docker stop & rm $CONTAINER_NAME"
docker stop "$CONTAINER_NAME" 2>/dev/null || true
docker rm "$CONTAINER_NAME" 2>/dev/null || true

echo "→ docker run"
# Flutter Web 静态 SPA —— runtime 无 env-file 注入（dart-define 在 build 时已烤进 bundle）。
docker run -d \
  --name "$CONTAINER_NAME" \
  --restart unless-stopped \
  -p "127.0.0.1:${HOST_PORT}:80" \
  "$IMAGE"

echo "→ docker image prune"
docker image prune -f

echo "→ docker ps"
docker ps --filter name="$CONTAINER_NAME"

# ……（节略 L129 空行，探活段自 L130 起逐字续录）

# 健康检查: 容器 healthcheck 30s 内应 healthy (Dockerfile: nginx:alpine + wget 127.0.0.1)
echo "→ waiting for container health..."
i=0
while [ $i -lt 30 ]; do
  STATUS=$(docker inspect --format='{{.State.Health.Status}}' "$CONTAINER_NAME" 2>/dev/null || echo "starting")
  if [ "$STATUS" = "healthy" ]; then
    echo "→ container healthy after ${i}s"
    break
  fi
  if [ "$STATUS" = "unhealthy" ]; then
    echo "→ container unhealthy, logs:"
    docker logs --tail 30 "$CONTAINER_NAME"
    exit 1
  fi
  i=$((i+1))
  sleep 1
done

if [ $i -ge 30 ]; then
  echo "→ container failed to become healthy in 30s, logs:"
  docker logs --tail 30 "$CONTAINER_NAME"
  exit 1
fi

# host 级探活（第二条）:探 `/` —— SPA fallback try_files 保证恒 200;
# 本仓无 /api/health,静态 200 也证不了 dart-define 烘焙(那是 Dockerfile grep 断言的职责),
# 这里只证「端口映射 + nginx serve」这一层。地址一律 127.0.0.1 字面量(busybox wget ::1 指纹)。
echo "→ host probe http://127.0.0.1:${HOST_PORT}/"
wget --tries=1 --timeout=3 -q "http://127.0.0.1:${HOST_PORT}/" -O /dev/null \
  || { echo "ERROR: host probe ${HOST_PORT} failed"; docker logs --tail 30 "$CONTAINER_NAME"; exit 1; }

echo "→ deploy done at $(date -u)"