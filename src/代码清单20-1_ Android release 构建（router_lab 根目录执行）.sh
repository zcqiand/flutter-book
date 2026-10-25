# 在 router_lab 项目根目录执行
# 产物是 APK 安装包，位于 build/app/outputs/flutter-apk/ 目录
# router_lab 是双入口工程，-t 指定 go_router 轨入口 lib/main_gorouter.dart
flutter build apk --release -t lib/main_gorouter.dart