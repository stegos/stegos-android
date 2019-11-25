import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as Math;
import 'dart:typed_data';

import 'package:pedantic/pedantic.dart';
import 'package:steel_crypt/steel_crypt.dart';
import 'package:stegos_wallet/env_stegos.dart';
import 'package:stegos_wallet/log/loggable.dart';
import 'package:stegos_wallet/utils/crypto.dart';
import 'package:stegos_wallet/utils/crypto_aes.dart';

class StegosNodeMessage {
  StegosNodeMessage(this.raw);
  final String raw;
}

/// Stegos node client.
///
class StegosNodeClient with Loggable<StegosNodeClient> {
  StegosNodeClient._(this.env)
      : _minWait = env.configNodeWsEndpointMinReconnectTimeoutMs,
        _maxWait = env.configNodeWsEndpointMaxReconnectTimeoutMs,
        _nextWait = env.configNodeWsEndpointMinReconnectTimeoutMs;

  factory StegosNodeClient.open(StegosEnv env) {
    final wss = StegosNodeClient._(env);
    unawaited(wss._connect());
    return wss;
  }

  final StegosEnv env;

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
    return WebSocket.connect(env.configNodeWsEndpoint).then((ws) {
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

  /// Encodes a given [payload]for websocket channel
  /// connected to stegos node.
  String _messageEncrypt(String payload) {
    // aes-128-ctr
    final aes = StegosAesCrypt(env.configNodeWsEndpointApiToken, 'ctr');
    final iv = const StegosCryptKey().genDartRaw(16);
    final encrypted = aes.encrypt(const Utf8Encoder().convert(payload), iv);
    return base64Encode(iv + encrypted);
  }

  /// Decodes receved [buffer] into plain text
  String _messageDecrypt(String buffer) {
    // aes-128-ctr
    final bytes = base64Decode(buffer);
    if (bytes.length <= 16) {
      throw Exception('Invalid data recieved');
    }
    final iv = bytes.sublist(0, 16);
    final encrypted = bytes.sublist(16);
    final aes = StegosAesCrypt(env.configNodeWsEndpointApiToken, 'ctr');
    final payload = aes.decrypt(encrypted, iv);
    return const Utf8Decoder().convert(payload);
  }
}
