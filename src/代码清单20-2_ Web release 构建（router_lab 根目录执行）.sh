# 同在 router_lab 项目根目录执行
# 产物是一组可直接静态托管的网页文件，位于 build/web/ 目录
# 注释口径同清单 20-1：双入口工程，-t 指定 go_router 轨入口
flutter build web --release -t lib/main_gorouter.dart