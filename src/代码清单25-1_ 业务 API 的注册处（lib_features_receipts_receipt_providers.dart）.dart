import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lab_management_system_flutter/generated/lab_shared_generated.dart'
    hide AuthState;

import '../../core/auth/providers.dart';

/// Phase 2 业务 API providers（复用 Phase 1 dio 链与测试 override 缝）。
final receiptsApiProvider = Provider<ReceiptsApi>(
  (ref) => ReceiptsApi(ref.watch(dioProvider), standardSerializers),
);

final samplesApiProvider = Provider<SamplesApi>(
  (ref) => SamplesApi(ref.watch(dioProvider), standardSerializers),
);

final reportNamesApiProvider = Provider<ReportNamesApi>(
  (ref) => ReportNamesApi(ref.watch(dioProvider), standardSerializers),
);

final testRecordsApiProvider = Provider<TestRecordsApi>(
  (ref) => TestRecordsApi(ref.watch(dioProvider), standardSerializers),
);

final inspectionDictionaryApiProvider = Provider<InspectionDictionaryApi>(
  (ref) => InspectionDictionaryApi(ref.watch(dioProvider), standardSerializers),
);