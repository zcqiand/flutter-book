// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get title => '电量通道';

  @override
  String get helloButton => '读取电量';

  @override
  String batteryLevel(int level) {
    return '当前电量：$level%';
  }

  @override
  String get notReadYet => '尚未读取';

  @override
  String get channelMissing => '当前平台未实现电量通道';

  @override
  String get hostNull => '读取失败：宿主回传为空';

  @override
  String failWith(String reason) {
    return '读取失败：$reason';
  }
}
