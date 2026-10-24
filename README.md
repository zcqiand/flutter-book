# flutter-book

《Flutter 从入门到项目实践》（xr-know-019）随书代码仓。

每章的随书工程放在 `lab/chNN/<工程名>/` 下，一章可含多个工程：

```
lab/
├── ch04/                    ← 第 4 章：基础语法示例
├── ch05/                    ← 第 5 章：theme_playground（主题系统演练）
├── ...
├── ch11/                    ← 第 11 章：多工程（列表/滚动系列示例）
├── ch16/cart_lab/           ← 状态管理：bloc 购物车
├── ch17/guard_lab/          ← 路由守卫验证
├── ch18/riverpod_lab/       ← Riverpod 状态管理
├── ch19/router_lab/         ← go_router 深链接 + CI
├── ch21/channel_lab/        ← 平台通道（MethodChannel）
├── ch22/dio_lab/            ← 网络层封装
└── ch23/migration_lab/      ← 项目实战：迁移工程
```

## 约定

- 每个工程独立可编译：`flutter pub get && flutter analyze && flutter test`
- `build/`、`.dart_tool/` 等可再生目录不入库
- 章节正文与讲解见主仓 `output/xr-know-019/chapters/`，此处只放随书代码
