import 'dart:async';
import 'dart:io';
import 'dart:math' as Math;

import 'package:pedantic/pedantic.dart';
import 'package:stegos_wallet/env_stegos.dart';
import 'package:stegos_wallet/log/loggable.dart';

class StegosNodeMessage {
  StegosNodeMessage(this.raw);
  final String raw;
}

/// Stegos node client.
///
class StegosNodeClient with Loggable<StegosNodeClient> {
  StegosNodeClient._(this._env)
      : _minWait = _env.configNodeWsEndpointMinReconnectTimeoutMs,
        _maxWait = _env.configNodeWsEndpointMaxReconnectTimeoutMs,
        _nextWait = _env.configNodeWsEndpointMinReconnectTimeoutMs;

  factory StegosNodeClient.open(StegosEnv env)  {
    final wss = StegosNodeClient._(env);
    unawaited(wss._connect());
    return wss;
  }

  final StegosEnv _env;

  var _controller = StreamController<StegosNodeMessage>.broadcast();

  Stream<StegosNodeMessage> get stream => _controller.stream;

  WebSocket _ws;

  /// ignore: cancel_subscriptions
  StreamSubscription _subscription;

  bool get _disposed => _controller.isClosed;

  bool _reconnecting = false;

  final int _minWait;

  final int _maxWait;

  int _nextWait;

  Future<void> close({bool dispose}) async {
    if (_disposed) {
      return;
    }
    if (dispose) {
      await _controller.close();
    }
    if (_subscription != null) {
      final sub = _subscription;
      _subscription = null;
      unawaited((sub.cancel() ?? Future.value()).catchError(
          (err, StackTrace st) => log.warning('Error cancelling ws subscription', err, st)));
    }
    if (_ws != null) {
      log.warning('Closing connection');
      final ws = _ws;
      _ws = null;
      unawaited(ws
          .close()
          .catchError((err, StackTrace st) => log.warning('Error closing ws endpoint', err, st)));
    }
  }

  // Ensure node client is able to connect
  Future<void> ensureOpened() => _connect(ensureOpened: true);

  Future<void> _reconnect() {
    if (_reconnecting || _disposed) {
      return Future.value();
    }
    _reconnecting = true;
    _nextWait = Math.min((_nextWait * 1.1).ceil(), _maxWait);
    return Future.delayed(Duration(milliseconds: _nextWait), () {
      _reconnecting = false;
      log.info('Reconnecting...');
      return _connect();
    });
  }

  Future<void> _connect({bool ensureOpened = false}) async {
    if (_disposed) {
      _controller = StreamController<StegosNodeMessage>.broadcast();
    }
    if (ensureOpened && _ws != null) {
      return Future.value();
    }
    await close(dispose: false);
    return WebSocket.connect(_env.configNodeWsEndpoint).then((ws) {
      _ws = ws;
      _subscription = _ws.listen((line_) {
        _nextWait = _minWait;
        final line = line_ as String;
        log.info('WS line: $line'); // todo: remove log
        _controller.add(StegosNodeMessage(line));
      }, onDone: () {
        _subscription = null;
        _nextWait = _minWait;
        log.warning('Connection closed');
        unawaited(_reconnect());
      }, onError: (err) {
        log.warning('Connection error', err);
        unawaited(_reconnect());
      });
    }).then((_) {
      log.info('Connected');
    }).catchError((err, StackTrace st) {
      log.warning('Connection error', err);
      unawaited(_reconnect());
    });
  }
}
