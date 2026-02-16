import 'dart:developer' as developer;

/// 应用日志工具
///
/// 使用Flutter的dart:developer进行日志记录
/// 支持不同级别的日志输出
class AppLogger {
  static const String _defaultTag = 'EchoMemo';

  /// 调试级别日志
  void d(String message, {String? tag}) {
    _log(LogLevel.debug, message, tag: tag);
  }

  /// 信息级别日志
  void i(String message, {String? tag}) {
    _log(LogLevel.info, message, tag: tag);
  }

  /// 警告级别日志
  void w(String message, {String? tag}) {
    _log(LogLevel.warning, message, tag: tag);
  }

  /// 错误级别日志
  void e(String message, {Object? error, StackTrace? stackTrace, String? tag}) {
    _log(LogLevel.error, message, error: error, stackTrace: stackTrace, tag: tag);
  }

  /// 内部日志方法
  void _log(
    LogLevel level,
    String message, {
    Object? error,
    StackTrace? stackTrace,
    String? tag,
  }) {
    final logTag = tag ?? _defaultTag;
    final timestamp = DateTime.now().toIso8601String();
    final logMessage = '[$timestamp] [$logTag] [$level.name] $message';

    switch (level) {
      case LogLevel.debug:
      case LogLevel.info:
        developer.log(logMessage);
        break;
      case LogLevel.warning:
        developer.log(
          logMessage,
          level: 500, // WARNING level
        );
        break;
      case LogLevel.error:
        developer.log(
          logMessage,
          level: 1000, // ERROR level
          error: error,
          stackTrace: stackTrace,
        );
        break;
    }
  }
}

/// 日志级别枚举
enum LogLevel {
  debug,
  info,
  warning,
  error,
}

/// 便捷的日志实例
/// 使用: logger.d('Debug message');
final logger = AppLogger();

