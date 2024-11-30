import 'package:get/get.dart' show Get;
import 'package:logger/logger.dart' show Logger, Level;

export 'package:logger/logger.dart' show Level;

class Log {
  static final Logger instance = Logger();

  /// 应用程序当前的日志级别.
  ///
  /// 所有低于此级别的日志将被忽略
  static Level get level => Logger.level;

  static set level(Level logLevel) => Logger.level = logLevel;

  /// 在级别记录消息 [Level.trace]
  static void t(dynamic message, {DateTime? time, Object? error, StackTrace? stackTrace}) {
    Log.instance.t(message, time: time, error: error, stackTrace: stackTrace);
  }

  /// 在级别记录消息 [Level.debug]
  static void d(dynamic message, {DateTime? time, Object? error, StackTrace? stackTrace}) {
    Log.instance.d(message, time: time, error: error, stackTrace: stackTrace);
  }

  /// 在级别记录消息 [Level.info]
  static void i(dynamic message, {DateTime? time, Object? error, StackTrace? stackTrace}) {
    Log.instance.i(message, time: time, error: error, stackTrace: stackTrace);
  }

  /// 在级别记录消息 [Level.warning]
  static void w(dynamic message, {DateTime? time, Object? error, StackTrace? stackTrace}) {
    Log.instance.w(message, time: time, error: error, stackTrace: stackTrace);
  }

  /// 在级别记录消息 [Level.error]
  static void e(dynamic message, {DateTime? time, Object? error, StackTrace? stackTrace}) {
    Log.instance.e(message, time: time, error: error, stackTrace: stackTrace);
  }

  /// 在级别记录消息 [Level.fatal]
  static void f(dynamic message, {DateTime? time, Object? error, StackTrace? stackTrace}) {
    Log.instance.f(message, time: time, error: error, stackTrace: stackTrace);
  }

  /// 用 [Log.level] 级别记录消息
  static void log(Level level, dynamic message, {DateTime? time, Object? error, StackTrace? stackTrace}) {
    Log.instance.log(level, message, time: time, error: error, stackTrace: stackTrace);
  }

  static void logWriter(String value, {bool isError = false}) {
    if (!Get.isLogEnable) return;
    if (isError) {
      Log.e(value);
    } else {
      Log.d(value);
    }
  }
}
