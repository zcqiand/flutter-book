// 场景：客厅温湿度传感器上报一条原始读数，我们解析它、定级它、汇总它。

sealed class ReadingStatus {}

class Normal extends ReadingStatus {
  Normal(this.value);
  final int value;
}

class Warning extends ReadingStatus {
  Warning(this.value, this.threshold);
  final int value;
  final int threshold;
}

class Offline extends ReadingStatus {}

// 返回类型写成 String?，是把「可能没有」写进契约——调用方被迫处理，编译器替你把关
String? parseLabel(String raw) {
  final match = RegExp(r'label=(\w+)').firstMatch(raw);
  return match?.group(1);
}

// records：局部多值返回的最轻方案，不必为凑两个返回值造一个包装类
(String, int) parseReading(String raw) {
  final parts = raw.split(',');
  return (parts[0], int.parse(parts[1]));
}

// switch 表达式 + sealed class：子类全集封闭，漏写一个分支编译器直接拒绝
String describe(ReadingStatus status) => switch (status) {
      Normal(value: final v) when v < 30 => '正常（$v），无需处理',
      Normal(value: final v) => '正常偏高（$v），建议通风',
      Warning(value: final v, threshold: final t) => '告警（$v，阈值 $t），请检查设备',
      Offline() => '设备离线，尝试重连',
    };

void main() {
  // (a) null safety：缺失值用 ?? 兜底，展示层永远拿不到裸 null
  final label = parseLabel('label=livingroom,value=26');
  print('传感器位置: ${label ?? '未知位置'}');

  final unlabeled = parseLabel('value=26');
  print('无标签读数: ${unlabeled ?? '未标注位置'}');

  // ! 只用在能证明非空处：这条输入的模式必然命中；对可能为 null 的值乱用 ! 是运行时崩溃源
  final known = parseLabel('label=balcony,value=31');
  print('确知位置: ${known!.toUpperCase()}');

  // (b) records：解构声明一次取出两个字段，类型各自收敛
  final (sensorId, temperature) = parseReading('livingroom,26');
  print('读数解析: $sensorId 的温度是 $temperature 度');

  // (c) 模式匹配：按数据结构分支，替代层层 if-else
  print(describe(Normal(26)));
  print(describe(Normal(32)));
  print(describe(Warning(31, 30)));
  print(describe(Offline()));
}