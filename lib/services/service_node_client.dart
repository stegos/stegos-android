import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as Math;

import 'package:json_at/json_at.dart';
import 'package:mobx/mobx.dart';
import 'package:pedantic/pedantic.dart';
import 'package:quiver/core.dart';
import 'package:stegos_wallet/env_stegos.dart';
import 'package:stegos_wallet/log/loggable.dart';
import 'package:stegos_wallet/utils/crypto.dart';
import 'package:stegos_wallet/utils/crypto_aes.dart';

part 'service_node_client.g.dart';

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

class StegosNodeErrorMessage implements Exception {
  StegosNodeErrorMessage(this.message);
  final String message;
  @override
  String toString() => 'StegosNodeErrorMessage: ${message}';

  bool get accountIsSealed => message == 'Account is sealed';

  bool get accountAlreadyUnsealed => message == 'Already unsealed';

  bool get invalidPassword => message.startsWith('Invalid password');
}

class StegosNodeMessage {
  StegosNodeMessage(this.id, this.json);
  final int id;
  final Map<String, dynamic> json;

  String get type => json['type'] as String;

  int get accountId => int.parse(json['account_id'] as String ?? '0');

  /// Gets subset of document using RFC 6901 JSON [pointer].
  Optional<dynamic> at(String pointer) => jsonAt(json, pointer);

  /// Gets subset of document using RFC 6901 JSON [pointer].
  Optional<dynamic> operator [](String pointer) => at(pointer);

  @override
  String toString() => '${id}: ${json}';
}

class _Message {
  _Message(this.payload, bool awaitResponse, [this.maxAwaitMs])
      : id = _nextId(),
        ts = DateTime.now().millisecondsSinceEpoch,
        completer = awaitResponse ? Completer<StegosNodeMessage>() : null {
    payload['id'] = id;
  }
  final Completer<StegosNodeMessage> completer;
  final int id;
  final int ts;
  final int maxAwaitMs;
  final Map<String, dynamic> payload;
}

class StegosNodeClient extends _StegosNodeClient with _$StegosNodeClient {
  factory StegosNodeClient.open(StegosEnv env) {
    final wss = StegosNodeClient._(env);
    unawaited(wss._connect());
    return wss;
  }
  StegosNodeClient._(StegosEnv env) : super(env);
}

/// Stegos node client.
///
abstract class _StegosNodeClient with Store, Loggable<StegosNodeClient> {
  _StegosNodeClient(this.env)
      : _minWait = env.configNodeWsEndpointMinReconnectTimeoutMs,
        _maxWait = env.configNodeWsEndpointMaxReconnectTimeoutMs,
        _nextWait = env.configNodeWsEndpointMinReconnectTimeoutMs;

  /// Env ref
  final StegosEnv env;

  /// Is connected to node
  @observable
  bool connected = false;

  /// Node incoming messages stream
  Stream<StegosNodeMessage> get stream => _controller.stream;

  /// Message waiting to send
  final _pending = Queue<_Message>();

  /// Messages awaiting server  response
  final _awaitingResponse = <int, _Message>{};

  final int _minWait;

  final int _maxWait;

  int _nextWait;

  var _controller = StreamController<StegosNodeMessage>.broadcast();

  WebSocket _ws;

  /// ignore: cancel_subscriptions
  StreamSubscription _subscription;

  bool get _disposed => _controller.isClosed;

  bool _reconnecting = false;

  void sendAndForget(Map<String, dynamic> payload) =>
      unawaited(send(payload, awaitResponse: false));

  Future<StegosNodeMessage> sendAndAwait(Map<String, dynamic> payload, [Duration maxAwaitTime]) =>
      send(payload, awaitResponse: true, maxAwaitTime: maxAwaitTime);

  Future<StegosNodeMessage> send(Map<String, dynamic> payload,
      {bool awaitResponse = true, Duration maxAwaitTime}) {
    awaitResponse ??= false;
    final maxAwaitTimeMs = maxAwaitTime?.inMilliseconds ?? env.configNodeMaxAwaitMessageResponseMs;
    final _Message msg = _Message(Map.of(payload), awaitResponse, maxAwaitTimeMs);
    _pending.add(msg);
    _processPendingMessages();
    return msg.completer?.future ?? Future.value();
  }

  void sendRaw(Map<String, dynamic> payload) {
    final data = jsonEncode(payload);
    final chunk = _messageEncrypt(data);
    _ws.add(chunk);
  }

  @override
  void dispose() {
    unawaited(close(dispose: true));
  }

  Future<void> close({bool dispose}) async {
    runInAction(() {
      connected = false;
    });
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
    if (!connected || _ws == null) {
      while (_pending.length > env.configNodeMaxPendingMessages) {
        _pending.removeFirst();
      }
      return;
    }
    while (_pending.isNotEmpty) {
      final msg = _pending.removeFirst();
      if (msg == null) {
        continue;
      }
      _sendMessage(msg);
    }
  }

  void _sendMessage(_Message msg) {
    if (msg.completer != null) {
      _awaitingResponse[msg.id] = msg;
    }
    final data = jsonEncode(msg.payload);
    final chunk = _messageEncrypt(data);
    if (log.isFine) {
      log.fine('sendMessage:\n\t${data}');
    }
    _ws.add(chunk);
    _cleanupAwaiters();
  }

  void _onIncomingMessage(String payload) {
    payload = _messageDecrypt(payload);
    if (log.isFine) {
      log.fine('onIncomingMessage: ${payload}');
    }
    final json = jsonDecode(payload) as Map<String, dynamic>;
    if (json['type'] == 'error') {
      log.warning('Node responded with error: ${json['error'] ?? json}');
    }
    final id = json['id'] is int ? json['id'] as int : 0;
    final msg = StegosNodeMessage(id, json);
    final awaited = _awaitingResponse[id];
    if (awaited != null) {
      _awaitingResponse.remove(id);
      if (json['type'] == 'error') {
        awaited.completer.completeError(StegosNodeErrorMessage('${json['error'] ?? json}'));
      } else {
        awaited.completer.complete(msg);
      }
    }
    _controller.add(msg);
    _cleanupAwaiters();
  }

  void _cleanupAwaiters() {
    final ts = DateTime.now().millisecondsSinceEpoch;
    final ep = env.configNodeMaxAwaitMessageResponseMs;
    _awaitingResponse.entries
        .where((e) => ts - e.value.ts >= ep)
        .map((e) => e.key)
        .toList()
        .forEach(_awaitingResponse.remove);
  }

  Future<void> _reconnect() {
    runInAction(() {
      connected = false;
    });
    if (_reconnecting || _disposed) {
      return Future.value();
    }
    _reconnecting = true;
    _nextWait = Math.min((_nextWait * 1.1).ceil(), _maxWait);
    return Future.delayed(Duration(milliseconds: _nextWait), _connect);
  }

  Future<void> _connect({bool ensureOpened = false}) async {
    if (ensureOpened && (_reconnecting || connected)) {
      return Future.value();
    }
    log.info('Connecting...');
    if (_disposed) {
      _controller = StreamController<StegosNodeMessage>.broadcast();
    }
    _reconnecting = true;
    await close(dispose: false).catchError((err, StackTrace st) {
      log.warning('', err, st);
    });
    return WebSocket.connect(env.configNodeWsEndpoint).then((ws) {
      _ws = ws;
      _reconnecting = false;
      runInAction(() {
        connected = true;
      });
      _subscription = _ws.listen((chunk) {
        _nextWait = _minWait;
        if (chunk is String) {
          _onIncomingMessage(chunk);
        }
      }, onDone: () {
        log.warning('Connection closed');
        _nextWait = _minWait;
        _subscription = null;
        _reconnecting = false;
        unawaited(_reconnect());
      }, onError: (err) {
        log.warning('Connection error', err);
        _reconnecting = false;
        unawaited(_reconnect());
      });
    }).then((_) {
      log.info('Connected');
      _processPendingMessages();
    }).catchError((err, StackTrace st) {
      log.warning('Connection error', err);
      _reconnecting = false;
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
