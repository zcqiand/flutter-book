# $env: 只对当前会话生效；要长期生效可写入用户级环境变量（系统设置或 setx）
$env:PUB_HOSTED_URL = "https://pub.flutter-io.cn"
$env:FLUTTER_STORAGE_BASE_URL = "https://storage.flutter-io.cn"

# 验证已生效
echo $env:PUB_HOSTED_URL
echo $env:FLUTTER_STORAGE_BASE_URL