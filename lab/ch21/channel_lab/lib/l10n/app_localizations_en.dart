// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get title => 'Battery Channel';

  @override
  String get helloButton => 'Read Battery';

  @override
  String batteryLevel(int level) {
    return 'Battery level: $level%';
  }

  @override
  String get notReadYet => 'Not read yet';

  @override
  String get channelMissing =>
      'Battery channel not implemented on this platform';

  @override
  String get hostNull => 'Read failed: host returned null';

  @override
  String failWith(String reason) {
    return 'Read failed: $reason';
  }
}
