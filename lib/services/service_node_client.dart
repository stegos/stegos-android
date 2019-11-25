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
import 'package:stegos_wallet/utils/extensions.dart';

/// Message sequence
int _seq = 0;

int _nextId() {
  if (_seq >= 9007199254740991) {
    // JS max safe integer, used for compatibility with JS based endpoints
    return _seq = 1;
  } else {
    return ++_seq;
  }
}

class StegosNodeMessage {
  StegosNodeMessage(this.id, this.raw);
  final id;
  final String raw;
}

class _Message {
  _Message(this.payload, bool awaitResponse, [this.maxAwaitMs])
      : id = _nextId(),
        ts = DateTime.now().millisecondsSinceEpoch,
        completer = awaitResponse ? Completer<StegosNodeMessage>() : null;
  final Completer<StegosNodeMessage> completer;
  final int id;
  final int ts;
  final int maxAwaitMs;
  final dynamic payload;
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

  /// Message waiting to send
  final _pending = <_Message>[];

  /// Messages awaiting server  response
  final _awaitingResponse = <int, _Message>{};

  var _controller = StreamController<StegosNodeMessage>.broadcast();

  Stream<StegosNodeMessage> get stream => _controller.stream;

  WebSocket _ws;

  /// ignore: cancel_subscriptions
  StreamSubscription _subscription;

  bool get _disposed => _controller.isClosed;

  bool _reconnecting = false;

  bool _connected = false;

  final int _minWait;

  final int _maxWait;

  int _nextWait;

  void sendAndForget(dynamic payload) => unawaited(send(payload, awaitResponse: false));

  Future<StegosNodeMessage> send(dynamic payload,
      {bool awaitResponse = true, Duration maxAwaitTime}) {
    awaitResponse ??= false;
    final maxAwaitTimeMs = maxAwaitTime?.inMilliseconds ?? env.configNodeMaxAwaitNodeResponseMs;
    final _Message msg = _Message(payload, awaitResponse, maxAwaitTimeMs);
    _pending.add(msg);
    _processPendingMessages();
    return msg.completer?.future ?? Future.value();
  }

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

  void _processPendingMessages() {
    if (!_connected) {
      while (_pending.length > env.configNodeMaxPendingMessages) {
        _pending.removeFirst();
      }
      return;
    }
    // todo:
  }

  Future<void> _reconnect() {
    _connected = false;
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
        log.info('WS line: $line');
        // todo:
        // _controller.add(StegosNodeMessage(line));
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
      _connected = true;
      _processPendingMessages();
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
