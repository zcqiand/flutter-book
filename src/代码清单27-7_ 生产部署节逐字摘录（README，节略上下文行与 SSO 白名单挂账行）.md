## 生产部署

- prod 地址：`https://lab-flutter.xiangru.uk`（静态 SPA 容器：容器内 :80 → VPS `127.0.0.1:5208`，nginx 反代；形态照 saas-flutter 先例）
- 部署 = 打 tag 走 CI：`git tag v<X.Y.Z>-<YYYYMMDD> && git push origin <tag>`（全量回归绿后打，tag 铁律）
- 所需 GitHub Secrets（5 个，值与家族同源）：`DOCKER_USERNAME` / `DOCKER_PASSWORD` / `VPS_HOST` / `VPS_USER` / `VPS_SSH_KEY`
- prod 配置烘焙在 Dockerfile（`--dart-define`：API_BASE_URL=`https://lab-nextjs.xiangru.uk`、SAAS_CLIENT_ID=`lab-management`），无 runtime env；回滚 = VPS 重跑 deploy 脚本带旧 tag