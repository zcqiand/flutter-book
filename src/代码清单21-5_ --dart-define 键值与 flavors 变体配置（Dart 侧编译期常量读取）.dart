// 段一：Dart 侧读取 --dart-define 注入的编译期常量
// --dart-define 在编译期注入键值：const 保证它在编译期定值，运行期零查找开销
const String apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'https://dev.example.com',
);