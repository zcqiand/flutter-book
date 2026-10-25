# 段三：构建命令（dev 与 prod 各一条，命令即环境声明）
flutter run --dart-define=API_BASE_URL=https://dev.example.com
flutter build apk --release --flavor dev
flutter build web --release --dart-define=API_BASE_URL=https://api.example.com