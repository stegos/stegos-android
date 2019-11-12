import 'dart:async';

import 'package:logging/logging.dart';

mixin Loggable<T> {
  final log = Log(T.toString());
}

class Log implements Logger {
  static bool _initialized = false;

  static initialize() {
    if (!_initialized) {
      hierarchicalLoggingEnabled = true;
      _initialized = true;
      Logger.root.onRecord.listen((LogRecord rec) {
        final sb = StringBuffer('${rec.level.name}: ${rec.time} ${rec.loggerName}: ${rec.message}');
        if (rec.error != null) {
          sb.write(' ${rec.error}');
        }
        if (rec.stackTrace != null) {
          sb.write('\n${rec.stackTrace}');
        }
        print(sb.toString());
      });
    }
  }

  final Logger _impl;

  Log(String name) : _impl = Logger(name);

  bool get isAll => this.isLoggable(Level.ALL);
  bool get isFinest => this.isLoggable(Level.FINEST);
  bool get isFiner => this.isLoggable(Level.FINER);
  bool get isFine => this.isLoggable(Level.FINE);
  bool get isConfig => this.isLoggable(Level.CONFIG);
  bool get isInfo => this.isLoggable(Level.INFO);
  bool get isWarning => this.isLoggable(Level.WARNING);
  bool get isSevere => this.isLoggable(Level.SEVERE);
  bool get isShout => this.isLoggable(Level.SHOUT);
  bool get isOff => this.isLoggable(Level.OFF);

  @override
  Level level;

  @override
  Map<String, Logger> get children => _impl.children;

  @override
  void clearListeners() => _impl.clearListeners();

  @override
  void config(message, [Object error, StackTrace stackTrace]) =>
      _impl.config(message, error, stackTrace);

  @override
  void fine(message, [Object error, StackTrace stackTrace]) =>
      _impl.fine(message, error, stackTrace);

  @override
  void finer(message, [Object error, StackTrace stackTrace]) =>
      _impl.finer(message, error, stackTrace);

  @override
  void finest(message, [Object error, StackTrace stackTrace]) =>
      _impl.finest(message, error, stackTrace);

  @override
  void severe(message, [Object error, StackTrace stackTrace]) =>
      _impl.severe(message, error, stackTrace);

  @override
  void shout(message, [Object error, StackTrace stackTrace]) =>
      _impl.shout(message, error, stackTrace);

  @override
  void warning(message, [Object error, StackTrace stackTrace]) =>
      _impl.warning(message, error, stackTrace);

  @override
  void info(message, [Object error, StackTrace stackTrace]) =>
      _impl.info(message, error, stackTrace);

  @override
  String get fullName => _impl.fullName;

  @override
  bool isLoggable(Level value) => _impl.isLoggable(value);

  @override
  void log(Level logLevel, message, [Object error, StackTrace stackTrace, Zone zone]) =>
      _impl.log(logLevel, message, error, stackTrace, zone);

  @override
  String get name => _impl.name;

  @override
  Stream<LogRecord> get onRecord => _impl.onRecord;

  @override
  Logger get parent => _impl.parent;
}
