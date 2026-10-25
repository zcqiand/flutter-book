# 体检：逐项核对 Flutter 依赖的环境（哪项红就修哪项）
flutter doctor

# 新建首个项目并进入
flutter create counter_app
cd counter_app

# 查看当前可运行设备清单（模拟器、真机、Chrome 都会列出）
flutter devices

# 不指定 -d：仅一台设备时自动选中，多台则提示二选一
flutter run

# 指定 Chrome 跑 Web 端，验证不依赖模拟器的第二条运行链路
flutter run -d chrome