// lib/core/api_error.dart
// 统一错误模型：页面层只认识 ApiException，不必知道 dio 内部异常长什么样
import 'package:dio/dio.dart';

/// 错误四分类：网络不通、超时、服务端状态异常、其余归入未知
enum ApiErrorType { network, timeout, server, unknown }

class ApiException implements Exception {
  const ApiException(this.type, this.message, {this.cause});

  final ApiErrorType type;
  final String message;

  /// 原始错误留着：排查问题时往日志里一丢就能看到全貌
  final Object? cause;

  @override
  String toString() => 'ApiException($type): $message';
}

/// 把任意异常归一成 ApiException：页面层 catch 到什么都先过这一道
ApiException mapDioError(Object error) {
  if (error is DioException) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      // 转换超时同属超时家族，一并归入下面同一句话
      case DioExceptionType.transformTimeout:
        // 超时类分支对用户是同一句话：等太久，稍后再试
        return ApiException(ApiErrorType.timeout, '请求超时，请稍后重试', cause: error);
      case DioExceptionType.connectionError:
        return ApiException(ApiErrorType.network, '网络连接失败，请检查网络', cause: error);
      case DioExceptionType.badResponse:
        return ApiException(
          ApiErrorType.server,
          '服务返回异常（HTTP ${error.response?.statusCode}）',
          cause: error,
        );
      case DioExceptionType.cancel:
      case DioExceptionType.badCertificate:
      // unknown 是 dio 的兜底枚举，同样归入未知类
      case DioExceptionType.unknown:
        return ApiException(ApiErrorType.unknown, '未知错误', cause: error);
    }
  }
  return ApiException(ApiErrorType.unknown, '未知错误', cause: error);
}