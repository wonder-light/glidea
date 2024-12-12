import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:glidea/controller/site.dart';
import 'package:glidea/helpers/fs.dart';
import 'package:logger/logger.dart' show AdvancedFileOutput, ProductionFilter, Level, Logger;

export 'package:logger/logger.dart' show Level;

class Log {
  ///保存单例
  static late final Logger _singleton;

  // [Logger] 实例
  static Logger get instance => _singleton;

  /// 应用程序当前的日志级别.
  ///
  /// 所有低于此级别的日志将被忽略
  static Level get level => Logger.level;

  static set level(Level logLevel) => Logger.level = logLevel;

  /// 初始化
  static void initState(SiteController site) {
    Level? level;
    ProductionFilter? filter;
    AdvancedFileOutput? output;
    // 生产模式
    if (kReleaseMode) {
      level = Level.info;
      filter = ProductionFilter();
      output = AdvancedFileOutput(path: FS.join(site.state.supportDir, 'log'));
    }
    _singleton = Logger(filter: filter, output: output, level: level);
  }

  /// 是否 log 资源
  static void dispose() {
    Log.instance.close();
  }

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
}
