import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

mixin Loggable<T> {
  final log = Log(T.toString());
}

class Log implements Logger {
  Log(String name) : _impl = Logger(name);
  static bool _initialized = false;

  static void initialize() {
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

        void printWrapped(String text) {
          const block = 800;
          final n = text.length ~/ block;
          final r = text.length % block;
          for (var i = 0; i < n; ++i) {
            print(text.substring(i * block, (i + 1) * block));
          }
          if (r > 0) {
            print(text.substring(text.length - r, text.length));
          }
        }

        printWrapped(sb.toString());
      });
    }
  }

  final Logger _impl;

  bool get isAll => isLoggable(Level.ALL);
  bool get isFinest => isLoggable(Level.FINEST);
  bool get isFiner => isLoggable(Level.FINER);
  bool get isFine => isLoggable(Level.FINE);
  bool get isConfig => isLoggable(Level.CONFIG);
  bool get isInfo => isLoggable(Level.INFO);
  bool get isWarning => isLoggable(Level.WARNING);
  bool get isSevere => isLoggable(Level.SEVERE);
  bool get isShout => isLoggable(Level.SHOUT);
  bool get isOff => isLoggable(Level.OFF);

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
