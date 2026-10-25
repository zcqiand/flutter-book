# Flutter 从入门到项目实践 - 代码清单

## 关于本书

《Flutter 从入门到项目实践》是一本锚定当前稳定口径写作、面向工程化实战的 Flutter 跨端开发教程书：基于 Flutter 3.4x stable + Dart 3，覆盖 Material 3 默认主题、Impeller 默认渲染引擎、records/patterns 等代际特性，正面填补中文 Flutter 内容约 3-4 年的版本真空。全书以「一切皆 Widget + 约束下行布局 + UI=f(state)」为核心心智模型，从 Dart 前置补课起步，走到状态管理、导航、网络与测试的工程化主线，最终在两个冻结 tag 的真实案例仓上完成 Android/Web 双端项目实践收官。正文不钉具体补丁号，版本口径以案例仓冻结 pubspec 实测为准，版本漂移记入附录说明。

全书 32 章四卷：卷一基础篇——建立 Flutter 的心智模型（环境搭建、Widget 模型、Material 3、列表渲染），卷二进阶篇——生命周期、布局原理与组件设计（约束下行、异步并发、动画与性能控制），卷三综合能力篇——路由、数据、状态与质量保障（go_router、dio、Riverpod 与四方案选型决策、三层测试与 CI 门禁），卷四项目实战篇——从跨端工程到两个真实可跑项目（平台通道、构建发布、后端联调、旧版迁移，交付实验室管理系统与 SaaS 身份认证平台两个 Flutter 客户端）。你有任意一门编程语言的基础语法、会用命令行即可开读；Android/iOS 原生工程师可从第 20 章跨端方案对比切入，前端/后端工程师可从第 13、15 章切入。

## 本书特点

**第一，版本基线锁定，代码可运行。** 全书示例基于 Flutter 3.4x stable + Dart 3 编写并实测，版本口径以配套仓库的锁定记录为准；Material 3、Impeller、records/patterns 等代际特性全部纳入正文——学到的代码在当前 SDK 上跑得起来，不是历史教材。

**第二，双真实案例仓贯穿，终点不是示范小工具。** 卷四 8 章案例实战落在两个冻结 tag、测试全绿的企业级仓上：实验室管理系统客户端（原生登录、401 会话守卫、接样单 CRUD、流程引擎七阶段）与 SaaS 身份认证平台客户端（多租户、RBAC 授权链、OAuth 应用集成、CI 回归与生产发布），按 README 启动即可在 Android/Web 双端跑通，无需第三方 API Key。

**第三，决策导向：每处选型都有依据。** 状态管理 setState/InheritedWidget/Riverpod/Bloc 四方案同题共答，产出一张含 AI 友好度新维度的选型决策表；Flutter/React Native/KMP 跨端方案对比同样实测产出——「在什么场景选什么方案」是全书反复训练的判断力。

**第四，一码多端全链路。** Android/iOS/Web 多平台差异、平台通道、flavors 多环境、l10n 国际化、签名发布与 CI 部署一站式覆盖；案例仓的「CI 回归 → Web release → Docker 静态容器 → VPS 部署」生产链路在书中完整呈现。

**第五，每章交付物导向，教学故意失败。** 学完一章的检验标准，是该章的可运行成果你是否独立做出来了；高频事故（无 key 状态错位、忘记 dispose 的内存泄漏、组件销毁后的异步竞态）设专门「故意失败」环节——先亲手复现，再亲手修复，坑踩在书里就不踩在你的项目里。

**第六，契约驱动的企业级前后端链路。** TypeSpec 契约 → dart-dio 生成客户端 → token 注入拦截器 → 401 会话守卫——这条真实联调链路完整呈现在第 22 章与两个案例仓中，与后端仓同源对齐，是市面 Flutter 教程极少覆盖的工程化深水区。

## 案例仓库

| 仓库名 | 说明 |
| :--- | :--- |
| lab-management-system-flutter @ v0.2.1-20261011 | 建筑工程实验室管理系统的 Flutter 客户端（Web 开发端口 5208），第 24-27 章贯穿项目：原生登录与 401 会话守卫、接样单业务 CRUD、流程引擎七阶段、测试与交付 |
| saas-identity-platform-flutter @ v0.2.2-20261010 | SaaS 多租户多应用身份平台的 Flutter 客户端（Web 开发端口 5108），第 28-31 章贯穿项目：SaaS 架构与多租户、角色与菜单授权、成员管理与应用集成、联调验收与生产发布 |

> 配套案例仓库为独立可跑的真实工程，均以冻结 tag 发布、与书稿章节锚定，clone 后切到对应 tag 即可按章跟跑；仓库地址随本书配书资源公布。

## 代码清单说明

本书所有代码清单均收录于本目录，对应书稿中「代码清单 N-M」标题块。

### 运行环境

```bash
# Flutter SDK 安装与自检（全书实测锚定 Flutter 3.47.6 stable + Dart 3.13.5，第 2 章含环境搭建专节）
flutter doctor    # 目标：全绿
flutter --version
git --version
# 目标平台：Android + Web（编辑器 Android Studio / VS Code 任一，Web 端需 Chrome）
# 中国大陆网络可设置镜像 PUB_HOSTED_URL / FLUTTER_STORAGE_BASE_URL（设置方法见案例仓 README）
# 案例卷（第 24-31 章）：克隆双案例仓库后切到冻结 tag（仓库地址随本书配书资源公布）
git checkout v0.2.1-20261011   # lab-management-system-flutter（第 24-27 章）
git checkout v0.2.2-20261010   # saas-identity-platform-flutter（第 28-31 章）
flutter create --platforms=android,web .   # 生成平台目录（每仓一次）
flutter pub get
flutter run -d chrome --web-port 5208      # saas-identity-platform-flutter 为 --web-port 5108
# 与后端联调的 API 地址经 --dart-define=API_BASE_URL=... 传入，逐章说明见卷四
```

### 目录结构

```
src/
├── 代码清单1-* … 代码清单31-*   # 第 1-31 章，共 161 个清单文件（命名「代码清单N-M_ 描述.扩展名」）
└── extracted_code_manifest.json   # 全部清单索引（title/lang/chapter_file/line/extracted_file/source）
```
