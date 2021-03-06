import 'dart:async';
import 'dart:convert';

import 'package:ejdb2_flutter/ejdb2_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:mobx/mobx.dart';
import 'package:pedantic/pedantic.dart';
import 'package:stegos_wallet/env_stegos.dart';
import 'package:stegos_wallet/log/loggable.dart';
import 'package:stegos_wallet/services/service_node_client.dart';
import 'package:stegos_wallet/stores/store_common.dart';
import 'package:stegos_wallet/stores/store_stegos.dart';
import 'package:stegos_wallet/ui/password/screen_password.dart';
import 'package:stegos_wallet/utils/cont.dart';
import 'package:stegos_wallet/utils/dialogs.dart';
import 'package:stegos_wallet/utils/extensions.dart';

part 'service_node.g.dart';

const stegosFeeStandard = 1000;

const stegosFeeHigh = 5000;

StegosEnv _env;

final _txDateFormatter = DateFormat('yyyy-MM-dd HH:mm:ss');

/// Payment mode used in [_NodeService.pay]
enum PaymentMethod {
  /// Cloaked outputs, but without using Snowball.
  SIMPLE,

  /// Cloaked outputs + Snowball (recommended)
  SECURED,

  /// Public (uncloaked) outputs
  PUBLIC
}

class TxStore extends _TxStore with _$TxStore {
  TxStore(
      AccountStore account,
      int id,
      bool send,
      String recipient,
      int amount,
      int cts,
      String comment,
      int fee,
      String status,
      String hash,
      dynamic certOutput)
      : super(account, id, send, recipient, amount, cts, comment, fee, status,
            hash, certOutput);

  factory TxStore.fromJson(AccountStore account, int id, dynamic json) {
    final type = json['type'] as String ?? '';
    final send = type == 'outgoing' ||
        type.startsWith('transaction_') ||
        type.contains('payment');
    final recipient = json['recipient'] as String;
    final amount = json['amount'] as int ?? 0;
    final hash = json['tx_hash'] as String ?? json['output_hash'] as String;
    dynamic certOutput;

    int cts;
    if (json['timestamp'] is String) {
      cts = DateTime.parse(json['timestamp'] as String)
          .toUtc()
          .millisecondsSinceEpoch;
    } else {
      cts =
          json['_cts'] as int ?? DateTime.now().toUtc().millisecondsSinceEpoch;
    }
    final comment = json['comment'] as String ?? '';

    var fee = 0;
    var status = '';
    if (send) {
      fee = json['fee'] as int ?? 0;
      status = json['status'] as String ?? status;
      certOutput = (json['outputs'] as List ?? []).firstWhere(
          (o) => o['output_type'] == 'payment' && o['rvalue'] != null,
          orElse: () => null);
    }
    return TxStore(account, id, send, recipient, amount, cts, comment, fee,
        status, hash, certOutput);
  }
}

abstract class _TxStore with Store {
  _TxStore(this.account, this.id, this.send, this.recipient, this.amount,
      this.cts, this.comment, this.fee, this.status, this.hash, this.certOutput)
      : humanCreationTime = _txDateFormatter
            .format(DateTime.fromMillisecondsSinceEpoch(cts, isUtc: false)),
        humanAmount = '${send ? '-' : ''}${(amount / 1e6).toStringAsFixed(3)}';

  final AccountStore account;

  /// Transaction database ID
  final int id;

  /// Is send transaction
  final bool send;

  /// Transaction amount in nSTG
  final int amount;

  /// Human readable tx amount in STG
  final String humanAmount;

  /// Transaction creation time ms since epoch UTC
  final int cts;

  /// Transaction creation time in local timezone
  final String humanCreationTime;

  /// Transactiont comment
  final String comment;

  /// Recipient address
  final String recipient;

  /// Transaction is finished. `!pending`
  bool get finished => !pending;

  /// Is transaction failed
  bool get failed =>
      const ['failed', 'rejected', 'conflicted'].contains(status);

  /// Transaction in pending state
  @computed
  bool get pending => send && !failed && status != 'committed';

  /// Human readable tx status
  @computed
  String get humanStatus {
    if (send) {
      if (pending) {
        if (status != null) {
          return 'Transaction ${status}...';
        } else {
          return 'Sending...';
        }
      } else if (failed) {
        return 'Send ${status}';
      } else {
        return 'Sent';
      }
    } else {
      return 'Received';
    }
  }

  /// tx hash / output_hash
  @observable
  String hash;

  /// Transaction has certificate
  bool get hasCert => certOutput != null;

  /// Transaction certificate output
  dynamic certOutput;

  @observable
  int fee;

  /// Human readable status of transaction state
  @observable
  String status = '';

  @override
  int get hashCode => id.hashCode;

  @override
  bool operator ==(dynamic other) => other is TxStore && other.id == id;

  @action
  void _updateFromJson(dynamic json) {
    if (send) {
      fee = json['fee'] as int ?? fee ?? 0;
      status = json['status'] as String ?? status;
      hash ??= json['tx_hash'] as String ?? json['output_hash'] as String;
      certOutput ??= (json['outputs'] as List ?? []).firstWhere(
          (o) => o['output_type'] == 'payment' && o['rvalue'] != null,
          orElse: () => null);
    }
  }
}

class AccountStore extends _AccountStore with _$AccountStore {
  AccountStore.empty(int id) : super(id);

  AccountStore._(int id, String name, String password, String iv, int ordinal,
      String pkey, String networkPKey)
      : super(id, name, password, iv, ordinal, pkey, networkPKey);

  factory AccountStore._fromJBDOC(JBDOC doc) {
    final ret = AccountStore._(
        doc.object['id'] as int,
        doc.object['name'] as String,
        doc.object['password'] as String,
        doc.object['iv'] as String,
        doc.object['ordinal'] as int,
        doc.object['pkey'] as String,
        doc.object['networkPKey'] as String);
    ret._setBalanceFromJBDOC(doc);
    return ret;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  bool operator ==(dynamic other) => other is AccountStore && other.id == id;
}

abstract class _AccountStore with Store {
  _AccountStore(this.id,
      [this.name,
      this._password,
      this._iv,
      this.ordinal,
      this.pkey,
      this.networkPKey]) {
    ordinal ??= id > 0 ? id - 1 : 0;
  }

  final int id;

  final txList = ObservableList<TxStore>();

  String pkey;

  String networkPKey;

  @computed
  String get humanName => name ?? 'Account #${id}';

  String get humanBalance => '${(balanceCurrent / 1e6).toStringAsFixed(3)}';

  @observable
  String name;

  @observable
  bool sealed = true;

  @observable
  bool balanceIsFinal = false;

  @observable
  int balanceCurrent = 0;

  @observable
  int balanceAvailable = 0;

  @observable
  int balanceStakeCurrent = 0;

  @observable
  int balanceStakeAvailable = 0;

  @observable
  int balancePublicCurrent = 0;

  @observable
  int balancePublicAvailable = 0;

  @observable
  int balancePaymentCurrent = 0;

  @observable
  int balancePaymentAvailable = 0;

  @observable
  int ordinal = 0;

  @observable
  bool backedUp = false;

  @computed
  bool get hasPendingTransactions =>
      txList.firstWhere((tx) => tx.pending, orElse: () => null) != null;

  /// PIN encrypted dedicated account password
  String _password;

  String _iv;

  @override
  int get hashCode => id.hashCode;

  @override
  bool operator ==(dynamic other) => other is _AccountStore && other.id == id;

  @action
  void _registerTransaction(TxStore tx) {
    txList.insert(0, tx);
    while (txList.length > _env.configMaxTransactionsPerAccount) {
      txList.removeLast();
    }
  }

  @action
  void _updateTransaction(int id, dynamic json) {
    final tx = txList.firstWhere((tx) => tx.id == id, orElse: () => null);
    if (tx == null) {
      _registerTransaction(TxStore.fromJson(this as AccountStore, id, json));
    } else {
      tx._updateFromJson(json);
    }
  }

  @action
  void _updateFromJson(dynamic json) {
    name = json['name'] as String ?? name;
    ordinal = json['ordinal'] as int ?? ordinal;
    backedUp = json['backedUp'] as bool ?? backedUp;
    _password = json['password'] as String;
    _iv = json['iv'] as String;
  }

  void _updateFromJBDOC(JBDOC doc) => _updateFromJson(doc.object);

  @action
  void _updateFromBalanceMessage(StegosNodeMessage msg) {
    balanceIsFinal = msg
        .at('/is_final')
        .transform((v) => v as bool)
        .or(balanceIsFinal ?? false);
    balanceCurrent =
        msg.at('/current').transform((v) => v as int).or(balanceCurrent ?? 0);
    balanceAvailable = msg
        .at('/available')
        .transform((v) => v as int)
        .or(balanceAvailable ?? 0);
    balancePaymentCurrent = msg
        .at('/payment/current')
        .transform((v) => v as int)
        .or(balancePaymentCurrent ?? 0);
    balancePaymentAvailable = msg
        .at('/payment/available')
        .transform((v) => v as int)
        .or(balancePaymentAvailable ?? 0);
    balancePublicCurrent = msg
        .at('/public_payment/current')
        .transform((v) => v as int)
        .or(balancePublicCurrent ?? 0);
    balancePublicAvailable = msg
        .at('/public_payment/available')
        .transform((v) => v as int)
        .or(balancePublicAvailable ?? 0);
    balanceStakeCurrent = msg
        .at('/stake/current')
        .transform((v) => v as int)
        .or(balanceStakeCurrent ?? 0);
    balanceStakeAvailable = msg
        .at('/stake/available')
        .transform((v) => v as int)
        .or(balanceStakeAvailable ?? 0);
  }

  void _setBalanceFromJBDOC(JBDOC doc) {
    balanceCurrent = doc.object['balanceCurrent'] as int ?? 0;
  }

  dynamic toJson() => {
        // Note: Sensitive info is not stored in db
        'id': id,
        'name': name,
        'ordinal': ordinal,
        'backedUp': backedUp,
        'password': _password,
        'iv': _iv,
        'pkey': pkey,
        'networkPKey': networkPKey,
        'balanceCurrent': balanceCurrent
      };

  @override
  String toString() => jsonEncode(this);
}

class _UnsealAccountStatus {
  const _UnsealAccountStatus(
      {this.unsealed = false, this.invalidPassword = false});

  final bool unsealed;
  final bool invalidPassword;

  @override
  String toString() =>
      'usealed=${unsealed}, invalidPassword=${invalidPassword}';
}

class TxValidationInfo {
  TxValidationInfo(
      this.epoch, this.blockHash, this.isFinal, this.timestamp, this.amount);
  factory TxValidationInfo.fromJson(dynamic json) => TxValidationInfo(
      json['epoch'] as int ?? 0,
      json['block_hash'] as String ?? '',
      json['is_final'] as bool ?? false,
      json['timestamp'] as String ?? '',
      json['amount'] as int ?? 0);

  final int epoch;
  final String blockHash;
  final bool isFinal;
  final String timestamp;
  final int amount;
}

class NodeService = _NodeService with _$NodeService;

abstract class _NodeService with Store, StoreLifecycle, Loggable<NodeService> {
  _NodeService(this.parent) {
    // Set global env
    _env = parent.env;
    unawaited(_env.useDb((db) => Future.wait([
          db.ensureStringIndex(_txsCollection, '/tx_hash', true),
          db.ensureStringIndex(_txsCollection, '/output_hash', true),
          db.ensureIntIndex(_txsCollection, '/account_id', false)
        ])));
  }

  final StegosStore parent;

  StegosNodeClient get client => parent.env.nodeClient;

  final accounts = ObservableMap<int, AccountStore>();

  @computed
  List<AccountStore> get accountsList => accounts.values.toList(growable: false)
    ..sort((a, b) => a.ordinal.compareTo(b.ordinal));

  @computed
  int get totalBalance => accounts.values
      .fold(0, (s, a) => s + a.balanceCurrent); // todo: balanceCurrent?

  String get totalBalanceSTG => (totalBalance / 1e6).toStringAsFixed(3);

  /// Is app is connected to network
  @computed
  bool get connected => client.connected;

  /// Is Segos network node operable:
  ///  - We can send transactions
  ///  - We can acquire account baalnces
  @computed
  bool get operable => client.connected && synchronized;

  /// Is stegos app locked:
  ///  - Don't update any observable items
  @computed
  bool get locked => _env.securityService.needAppUnlock;

  /// Is Stegos network node synchronized
  @computed
  bool get synchronized => min_epoch == remote_epoch;

  /// Local min epoch.
  @observable
  int min_epoch = 0;

  /// Remote node epoch.
  @observable
  int remote_epoch = 1;

  /// Stegos network id:
  /// - stg: mainNet
  /// - stt: testNet
  /// - str: devNet
  /// - dev: dev tests
  @observable
  String network = '';

  @computed
  String get networkName {
    switch (network) {
      case 'stg':
        return 'MainNet';
      case 'stt':
        return 'TestNet';
      case 'str':
        return 'DevNet';
      case 'dev':
        return 'DevTests';
      default:
        return 'Unknown';
    }
  }

  @observable
  String lastDeletedAccountName;

  @computed
  String get _accountsCollecton => 'accounts_$network';

  @computed
  String get _txsCollection => 'txs_$network';

  @computed
  bool get _syncAllowed =>
      client.connected && !_env.securityService.needAppUnlock;

  final _disposers = <ReactionDisposer>[];

  // ignore: cancel_subscriptions
  StreamSubscription<StegosNodeMessage> _nodeClientSubscription;

  Future<void> deleteAccount(AccountStore account) async {
    if (log.isFine) {
      log.fine('deleteAccount: ${account.id}');
    }
    await _checkConnected();
    return _unsealAccount(account.id, force: true)
        .then((_) => client.sendAndAwait(
            {'type': 'delete_account', 'account_id': '${account.id}'}))
        .catchError(defaultErrorHandler<void>(_env));
  }

  Future<void> createNewAccount([String name]) async {
    await _checkConnected();
    final pwp = await _env.securityService.acquirePasswordForApp();
    final msg = await client
        .sendAndAwait({'type': 'create_account', 'password': pwp.first});
    unawaited(_syncAccounts().then((_) async {
      final accountId = msg.accountId;
      if (accountId > 0 && name != null && name.isNotEmpty) {
        final acc = accounts[accountId];
        if (acc != null) {
          await _env.useDb((db) => db.patchOrPut(
              _accountsCollecton, {'id': accountId, 'name': name}, accountId));
          runInAction(() {
            acc.name = name;
          });
        }
      }
    }));
    return msg;
  }

  Future<void> recoverAccount(List<String> recoveryPhrase) async {
    recoveryPhrase =
        recoveryPhrase.map((r) => r.trim()).where((r) => r.isNotEmpty).toList();
    if (recoveryPhrase.length != 24) {
      return Future.error('Invalid recovery phrase');
    }
    await _checkOperable();
    final pwp = await _env.securityService.acquirePasswordForApp();
    return client.sendAndAwait({
      'type': 'recover_account',
      'recovery': recoveryPhrase.join(' '),
      'password': pwp.first
    }).then((_) {
      unawaited(_syncAccounts());
    });
  }

  Future<List<String>> getSeedWords(AccountStore account) async {
    await _checkOperable();
    await _unsealAccount(account.id, force: true);
    final msg = await client.sendAndAwait({
      'type': 'get_recovery',
      'account_id': '${account.id}',
    });
    if (log.isFine) {
      log.fine('Fetched account recovery keys: ${msg}');
    }
    final String wordsString = msg.json['recovery'].toString();
    return wordsString.split(' ');
  }

  Future<void> swapAccounts(int fromIndex, int toIndex) {
    if (log.isFine) {
      log.fine('Swap accounts from=$fromIndex to=$toIndex');
    }
    final alist = List<AccountStore>.from(accountsList);
    if (fromIndex == toIndex) {
      return Future.value();
    }
    if (fromIndex >= alist.length || toIndex >= alist.length) {
      log.warning(
          'reorderAccounts: invalid arguments: ${fromIndex}, ${toIndex}');
      return Future.value();
    }

    runInAction(() {
      final AccountStore account = alist.removeAt(fromIndex);
      alist.insert(toIndex, account);
      for (int i = 0; i < alist.length; i++) {
        alist[i].ordinal = i;
      }
    });

    return _env.useDb((db) {
      final List<Future<void>> dbPatches = [];
      alist.forEach((a) => dbPatches
          .add(db.patch(_accountsCollecton, {'ordinal': a.ordinal}, a.id)));
      return Future.wait(dbPatches);
    });
  }

  Future<void> markAsBackedUp(int id) {
    final account = accounts[id];
    if (account == null) {
      return Future.value();
    }
    return _env
        .useDb((db) => db.patch(_accountsCollecton, {'backedUp': true}, id))
        .then((_) {
      runInAction(() {
        account.backedUp = true;
      });
    });
  }

  Future<void> setAccountPassword(AccountStore account, String password) async {
    await _unsealAccount(account.id, force: true);
    final pwp = await _env.securityService.acquirePasswordForApp();
    final pp =
        _env.securityService.setupPinProtectedPassword(password, pwp.second);
    await client.sendAndAwait({
      'type': 'change_password',
      'account_id': '${account.id}',
      'new_password': password
    });
    account._password = pp.first;
    account._iv = pp.second;
    await _env.useDb((db) => db.patch(_accountsCollecton,
        {'password': account._password, 'iv': account._iv}, account.id));
  }

  Future<void> renameAccount(int id, String name) {
    final account = accounts[id];
    if (account == null) {
      return Future.value();
    }
    return _env
        .useDb((db) => db.patch(_accountsCollecton, {'name': name}, id))
        .then((_) {
      runInAction(() {
        account.name = name;
      });
    });
  }

  Future<void> pay(
      {@required AccountStore account,
      @required String recipient,
      @required int amount,
      PaymentMethod paymentMethod = PaymentMethod.SIMPLE,
      String comment,
      int fee,
      bool withCertificate,
      DateTime lockedTimestamp}) async {
    comment ??= '';
    fee ??= stegosFeeStandard;
    withCertificate ??= false;
    if (withCertificate) {
      paymentMethod = PaymentMethod.SIMPLE;
    }
    String type;
    switch (paymentMethod) {
      case PaymentMethod.SECURED:
        type = 'secure_payment';
        break;
      case PaymentMethod.PUBLIC:
        type = 'public_payment';
        break;
      default:
        type = 'payment';
    }

    await _unsealAccount(account.id, force: true);
    final payload = {
      'type': type,
      'recipient': recipient,
      'amount': amount,
      'comment': comment,
      'account_id': '${account.id}',
      'with_certificate': withCertificate,
      'payment_fee': fee,
      'locked_timestamp': lockedTimestamp?.toUtc()?.toIso8601StringV2(),
    };

    final txdata = {
      ...payload,
      '_cts': DateTime.now().toUtc().millisecondsSinceEpoch
    };
    final id = await _env.useDb((db) => db.put(_txsCollection, txdata));
    if (log.isFine) {
      log.fine('Payment persisted: ${txdata}');
    }
    account._updateTransaction(id, txdata);

    StegosNodeMessage msg;
    try {
      msg = await client
          .sendAndAwait(payload)
          .catchError(defaultErrorHandler<StegosNodeMessage>(_env));
      if (log.isFine) {
        log.fine('Payment accepted: ${msg}');
      }
    } catch (e) {
      final patch = {'status': 'failed'};
      await _env.useDb((db) => db.patch(_txsCollection, patch, id));
      unawaited(Future(() {
        account._updateTransaction(id, patch);
      }));
      rethrow;
    }

    await _env.useDb((db) => db.patch(_txsCollection, msg.json, id));
    account._updateTransaction(id, msg.json);
  }

  Future<TxValidationInfo> validateTxCertificate(TxStore tx) async {
    if (!operable || tx.certOutput == null) {
      return null;
    }
    final certOutput = tx.certOutput;
    final msg = await client.sendAndAwait({
      'type': 'validate_certificate',
      'spender': tx.account.pkey,
      'output_hash': certOutput['output_hash'],
      'recipient': certOutput['recipient'],
      'rvalue': certOutput['rvalue']
    });
    return TxValidationInfo.fromJson(msg.json);
  }

  @override
  Future<void> activate() async {
    if (!client.connected) {
      await _syncAccountsOffline().catchError((err, StackTrace st) =>
          log.warning('Failed to sync accounts for offline usage', err, st));
    }
    // Track connection status changes
    _disposers.addAll([
      autorun((_) {
        setEmbeddedNode(_env.store.embeddedNode);
      }),
      autorun((_) {
        if (_syncAllowed) {
          untracked(_syncAccounts);
        }
      }),
      autorun((_) {
        if (client.connected) {
          untracked(() {
            _syncAccountsInfo(client.connected);
          });
        }
      })
    ]);
    _nodeClientSubscription = client.stream.listen(_onNodeMessage);
  }

  Future<void> suspend() {
    log.info('Suspending remote node.');
    final ch = StegosEnv.activityControlChannel;
    return ch.invokeMethod('stopNode');
  }

  Future<void> setEmbeddedNode(bool active) {
    log.warning('Activate embedded: ${active}');
    final ch = StegosEnv.activityControlChannel;
    if (active) {
      return ch.invokeMethod('startNode', {
        'network': 'testnet', // todo: hardcoded
        'apiToken': _env.store.nodeWsEndpointApiToken
      });
    } else {
      return ch.invokeMethod('stopNode');
    }
  }

  @override
  Future<void> disposeAsync() async {
    _disposers.forEach((d) => d());
    _disposers.length = 0;
    if (_nodeClientSubscription != null) {
      final subscription = _nodeClientSubscription;
      _nodeClientSubscription = null;
      unawaited(subscription.cancel());
    }
  }

  Future<void> _onAccountDeleted(StegosNodeMessage msg) =>
      _env.useDb((db) async {
        await _clearAccountTransactions(msg.accountId);
        await db.delIgnoreNotFound(_accountsCollecton, msg.accountId);
      }).whenComplete(() {
        runInAction(() {
          final acc = accounts[msg.accountId];
          accounts.remove(msg.accountId);
          if (acc != null) {
            lastDeletedAccountName = acc.humanName;
          }
        });
      });

  Future<void> _onUpdateBalance(StegosNodeMessage msg) {
    final acc = accounts[msg.accountId];
    if (acc == null) {
      return Future.value();
    }
    if (log.isFine) {
      log.info('Update balance: ${msg}');
    }
    return _env.useDb((db) {
      acc._updateFromBalanceMessage(msg);
      return db.patchOrPut(_accountsCollecton, acc, acc.id);
    });
  }

  Future<void> _checkConnected() {
    if (!connected) {
      return Future.error(StegosUserException('Stegos node is not connected'))
          .catchError(defaultErrorHandler(_env));
    }
    return Future.value();
  }

  Future<void> _checkOperable() {
    if (!operable) {
      return Future.error(
              StegosUserException('Stegos node is not connected/synchronized'))
          .catchError(defaultErrorHandler(_env));
    }
    return Future.value();
  }

  void _onNodeMessage(StegosNodeMessage msg) {
    switch (msg.type) {
      case 'balance_changed':
        unawaited(_onUpdateBalance(msg));
        break;
      case 'account_deleted':
        unawaited(_onAccountDeleted(msg));
        break;
      case 'transaction_status':
        unawaited(_onTransactionStatus(msg));
        break;
      case 'received':
        unawaited(_onReceived(msg));
        break;
      case 'status_changed':
        unawaited(_onStatusChanged(msg));
        break;
    }
  }

  Future<void> _onStatusChanged(StegosNodeMessage msg) async {
    final epoch = msg.json['epoch'] as int ?? min_epoch;
    if (locked) {
      return;
    }

    if (remote_epoch > 1 && epoch > min_epoch) {
      log.info('Updating min_epoch: before:${min_epoch} after ${epoch}');
      min_epoch = epoch;
    }
  }

  Future<void> _onReceived(StegosNodeMessage msg) async {
    final json = msg.json;
    if (json['comment'] == 'Change') {
      // FIXME: use `is_change`
      // https://github.com/stegos/stegos/issues/1449
      return;
    }
    final account = accounts[msg.accountId];
    if (account == null) {
      return;
    }
    if (log.isFine) {
      log.fine('onReceived: ${msg}');
    }
    return _env.useDb((db) async {
      final res = await db
          .createQuery(
              '/[account_id = :?] and /[output_hash = :?]', _txsCollection)
          .setInt(0, msg.accountId)
          .setString(1, json['output_hash'] as String)
          .first();
      if (res.isNotPresent) {
        final doc = {
          ...json,
          '_cts': DateTime.now().toUtc().millisecondsSinceEpoch
        };
        final id = await db.put(_txsCollection, doc);
        account._updateTransaction(id, doc);
      }
    });
  }

  Future<void> _onTransactionStatus(StegosNodeMessage msg) async {
    final json = msg.json;
    final account = accounts[msg.accountId];
    if (account == null) {
      return;
    }
    final doc = await _env.useDb((db) => db
        .createQuery('/[tx_hash = :?] | apply :?', _txsCollection)
        .setString(0, msg.json['tx_hash'] as String)
        .setJson(1, {'status': msg.json['status']}).first());
    if (!doc.isPresent) {
      log.warning('Missing tx hash: ${msg.json['tx_hash']} in wallet db');
      return;
    }
    if (log.isFine) {
      log.fine(
          'onTransactionStatus updated: ${doc.value}\nStatus: ${msg.json['status']}');
    }
    account._updateTransaction(doc.value.id, json);
  }

  Future<void> _syncAccountsInfo(bool connected) async {
    if (!connected || locked) {
      log.warning('Client disconnected.');
      if (log.isFine) log.fine('Schedule syncNodeStatus in next 10 secs');
      Timer(
          const Duration(seconds: 10), () => _syncAccountsInfo(this.connected));
      return;
    }
    return client.sendAndAwait({'type': 'accounts_info'}).then((msg) {
      runInAction(() {
        // synchronized = msg.json['is_synchronized'] as bool ?? false;
        remote_epoch = msg.json['remote_epoch'] as int ?? remote_epoch;
        if (remote_epoch <= 0) {
          remote_epoch = 1;
        } else {
          int local_min_epoch = null;
          // update min epoch only if we know remote_epoch.
          for (final MapEntry e in msg.json['accounts'].entries) {
            final int epoch = e.value['epoch'] as int ?? 0;
            if (local_min_epoch == null || epoch < local_min_epoch) {
              local_min_epoch = epoch;
            }
          }
          min_epoch = local_min_epoch;
        }
        log.info('Remote epoch = ${remote_epoch}, local_epoch = ${min_epoch}');
        if (log.isFine) log.fine('Schedule syncNodeStatus in next 10 secs');
        Timer(const Duration(seconds: 10),
            () => _syncAccountsInfo(this.connected));
      });
    });
  }

  Future<void> syncAccountsByIds(Iterable<int> ids,
          {bool forceSealing = false}) =>
      Future.forEach(ids, (int id) {
        if (!accounts.containsKey(id)) {
          return Future.value();
        }
        return _syncAccountInfo(id, forceSealing: forceSealing)
            .catchError((err, StackTrace st) {
          log.warning('Error getting account info #${id}', err, st);
          accounts.remove(id);
        });
      });

  Future<List<TxStore>> _fetchAccountTransactions(AccountStore account) =>
      _env.useDb((db) async {
        final list = await db
            .createQuery('/[account_id = :?] | noidx limit :?', _txsCollection)
            .setInt(0, account.id)
            .setInt(1, _env.configMaxTransactionsPerAccount)
            .execute()
            .map((doc) => TxStore.fromJson(account, doc.id, doc.object))
            .toList();
        list.sort((s1, s2) => s2.cts.compareTo(s1.cts));
        return list;
      });

  Future<void> syncAccountTransactions(AccountStore account) =>
      _env.useDb((db) async {
        final list = await _fetchAccountTransactions(account);
        final hmap = <String, TxStore>{};
        list.forEach((tx) {
          if (tx.hash != null) {
            hmap[tx.hash] = tx;
          }
        });

        final fromTs = list.lastOrNull?.cts ??
            DateTime.now().toUtc().millisecondsSinceEpoch -
                1000 * 60 * 60 * 24 * 365; // ~1Y

        final msg = await client.sendAndAwait({
          'type': 'history_info',
          'account_id': '${account.id}',
          'starting_from':
              DateTime.fromMillisecondsSinceEpoch(fromTs, isUtc: true)
                  .toIso8601StringV2(),
          'limit': 10 * 1024 // 10K
        });

        final history = (msg.json['log'] as List ?? []).where((h) {
          return (h['is_change'] as bool ?? true) == false ||
              const ['committed', 'rejected', 'conflicted']
                  .contains(h['status'] as String);
        });

        for (final h in history) {
          final hash = h['tx_hash'] as String ?? h['output_hash'] as String;
          if (hash != null) {
            final tx = hmap[hash];
            if (tx == null) {
              final toadd = {'account_id': '${account.id}', ...h as Map};
              if (toadd['amount'] == null) {
                final output = (toadd['outputs'] as List ?? []).firstWhere(
                    (o) =>
                        o['output_type'] == 'payment' &&
                        o['is_change'] == false,
                    orElse: () => null);
                if (output != null) {
                  toadd['amount'] = output['amount'];
                }
              }
              if (toadd['amount'] != null) {
                final id = await db.put(_txsCollection, toadd);
                list.add(TxStore.fromJson(account, id, toadd));
              }
            } else if (tx.send &&
                h['status'] != null &&
                tx.status != h['status']) {
              tx._updateFromJson(h);
              await db.patch(_txsCollection, {'status': tx.status}, tx.id);
            }
          }
        }

        list.sort((s1, s2) => s2.cts.compareTo(s1.cts));

        runInAction(() {
          account.txList.clear();
          account.txList.addAll(list);
        });
      });

  Future<AccountStore> _syncAccountInfo(int id,
      {bool forceSealing = false}) async {
    final account = await _unsealAccount(id, force: forceSealing);
    //try {
    final msg = await client
        .sendAndAwait({'type': 'balance_info', 'account_id': '$id'});
    await _env.useDb((db) async {
      account._updateFromBalanceMessage(msg);
      await db.patchOrPut(_accountsCollecton, account, id);

      // fixme: Lazy loading of account transactions
      return syncAccountTransactions(account);
    });
    // } finally {
    //   unawaited(_sealAccount(id, force: forceSealing));
    // }
    if (log.isFine) {
      log.fine('Fetched account info: ${account}');
    }
    return account;
  }

  Future<AccountStore> _sealAccount(int id, {bool force = false}) {
    if (log.isFine) {
      log.fine('Sealing account: #${id}');
    }
    final account = _account(id);
    if (!force && account.sealed) {
      return Future.value(account);
    }
    return client
        .sendAndAwait({'type': 'seal', 'account_id': '$id'}).catchError((err) {
      if (err is StegosNodeErrorMessage && err.accountIsSealed) {
        // Account is sealed already
        return Future<StegosNodeMessage>.value();
      } else {
        return Future<StegosNodeMessage>.error(err);
      }
    }).then((_) {
      runInAction(() {
        account.sealed = true;
      });
      if (log.isFine) {
        log.fine('Account#${id} is sealed');
      }
      return account;
    });
  }

  Future<AccountStore> unsealAccount(AccountStore account,
          {bool force = false}) =>
      _unsealAccount(account.id, force: force);

  Future<AccountStore> _unsealAccount(int id, {bool force = false}) async {
    final acc = _account(id);
    if (!force && !acc.sealed) {
      return acc;
    }
    _UnsealAccountStatus status;
    final pwp = await _env.securityService.acquirePasswordForApp();
    if (acc._password != null && acc._iv != null) {
      // We have own pin protected account password
      final apwp = _env.securityService
          .recoverPinProtectedPassword(pwp.second, acc._password, acc._iv);
      status = await _unsealAccountRaw(acc, apwp.first);
      if (status.unsealed) {
        return acc;
      }
    }
    status = await _unsealAccountRaw(acc, pwp.first);
    if (status.unsealed) {
      return acc;
    }
    if (status.invalidPassword) {
      // May be empty password is used?
      status = await _unsealAccountRaw(acc, '');
      if (status.unsealed) {
        // If so try to change empty password
        log.warning('Changing default password for account: $id');
        await client.sendAndAwait({
          'type': 'change_password',
          'account_id': '$id',
          'new_password': pwp.first
        });
      } else {
        final pw = await appShowDialog<String>(
            builder: (context) => PasswordScreen(
                  title: 'Unlock ${acc.humanName}',
                  caption:
                      'It seems that this account is locked by unknown password.',
                  titleStatus: 'Please provide account password to unlock',
                  titleSubmitButton: 'UNLOCK',
                  unlocker: (password) async {
                    status = await _unsealAccountRaw(acc, password);
                    if (status.invalidPassword) {
                      return Pair(null, 'Invalid password provided');
                    }
                    final pwp =
                        await _env.securityService.acquirePasswordForApp();
                    final pp = _env.securityService
                        .setupPinProtectedPassword(password, pwp.second);
                    acc._password = pp.first;
                    acc._iv = pp.second;
                    await _env.useDb((db) => db.patchOrPut(_accountsCollecton,
                        {'password': acc._password, 'iv': acc._iv}, id));
                    return Pair(password, null);
                  },
                ));
        if (pw == null) {
          // User cannot unlock this account
          throw StegosUserException('${acc.humanName} cannot be unlocked');
        }
      }
    }
    return acc;
  }

  Future<_UnsealAccountStatus> _unsealAccountRaw(
      AccountStore acc, String password) {
    if (log.isFine) {
      log.fine('Unsealing account raw #${acc.id}');
    }
    return client
        .sendAndAwait({
          'type': 'unseal',
          'account_id': '${acc.id}',
          'password': password ?? ''
        })
        .then((_) => const _UnsealAccountStatus(unsealed: true))
        .catchError((err) {
          if (err is StegosNodeErrorMessage) {
            if (err.accountAlreadyUnsealed) {
              return const _UnsealAccountStatus(unsealed: true);
            } else if (err.invalidPassword) {
              return const _UnsealAccountStatus(
                  unsealed: false, invalidPassword: true);
            }
          }
          return Future.error(err);
        })
        .then((v) {
          runInAction(() {
            acc.sealed = !v.unsealed;
          });
          if (log.isFine) {
            log.fine('Unsealing status #${acc.id}: ${v}');
          }
          return v;
        });
  }

  AccountStore _account(int id) {
    final acc = accounts[id];
    if (acc == null) {
      throw Exception('Unknown account: ${id}');
    }
    return acc;
  }

  Future<Map<String, dynamic>> _listRawAccounts() =>
      client.sendAndAwait({'type': 'list_accounts'}).then(
          (msg) => msg.json['accounts'] as Map<String, dynamic> ?? {});

  Future<Map<String, dynamic>> _detectNetworkAndSetupInitialAccounts() async {
    var nodeAccounts = await _listRawAccounts();
    if (nodeAccounts.isEmpty) {
      final pwp = await _env.securityService.acquirePasswordForApp();
      await client
          .sendAndAwait({'type': 'create_account', 'password': pwp.first});
      nodeAccounts = await _listRawAccounts();
      if (nodeAccounts.isEmpty) {
        throw StegosUserException(
            'Unable to create an initial account and determine network type');
      }
    }
    final pkey = nodeAccounts.values.first['account_pkey'] as String;
    if (pkey.length < 3) {
      // should never happen
      throw StegosUserException('Invalid account data');
    }
    runInAction(() {
      network = pkey.substring(0, 3);
    });
    log.info('Using Stegos network: ${network}');
    return nodeAccounts;
  }

  Future<void> _subscribeNotifications() async {
    await client
          .sendAndAwait({'type': 'subscribe_wallet_updates'});
  }

  Future<void> _syncAccountsOffline() async => _env.useDb((db) async {
        if (log.isFine) {
          log.fine('syncAccountsOffline...');
        }
        for (final checknet in ['stg', 'stt', 'str', 'dev']) {
          final cnt = await db
              .createQuery('/* | count', 'accounts_$checknet')
              .executeScalarInt();
          if (cnt == 0) {
            continue;
          }
          network = checknet;
          runInAction(accounts.clear);
          final accList = await db
              .createQuery('/*', _accountsCollecton)
              .execute()
              .map((doc) => AccountStore._fromJBDOC(doc))
              .asyncMap((acc) async {
            acc.txList.addAll(await _fetchAccountTransactions(acc));
            return acc;
          }).toList();
          runInAction(() {
            for (final acc in accList) {
              accounts[acc.id] = acc;
            }
          });
          break;
        }
      });

  Future<int> _clearAccountTransactions(int accountId) {
    if (log.isFine) {
      log.fine('Clearing account ${accountId} transactions');
    }
    return _env.useDb((db) => db
        .createQuery('/[account_id = :?] | del | count', _txsCollection)
        .setInt(0, accountId)
        .executeScalarInt());
  }

  Future<void> _syncAccounts() async {
    final nodeAccounts = await _detectNetworkAndSetupInitialAccounts();
    await _subscribeNotifications();
    final ids = nodeAccounts.keys.map(int.parse).toList();
    // Cleanup not matched accounts
    runInAction(() => accounts.removeWhere((k, v) => !ids.contains(k)));
    if (ids.isEmpty) {
      return Future.value();
    }
    return _env.useDb((db) async {
      await for (final doc in db
          .createQuery('/[id in :?]', _accountsCollecton)
          .setJson(0, ids)
          .execute()) {
        final id = doc.object['id'] as int;
        final acc = accounts[id];
        if (acc == null) {
          runInAction(() => accounts[id] = AccountStore._fromJBDOC(doc));
        } else {
          acc._updateFromJBDOC(doc);
        }
      }
      await Future.wait(ids.map((id) {
        final acc = runInAction(
            () => accounts.putIfAbsent(id, () => AccountStore.empty(id)));
        final nacc = nodeAccounts['$id'];
        final pkey = nacc['account_pkey'] as String;
        final networkPKey = nacc['network_pkey'] as String;
        final keysChanged = (acc.pkey != null && acc.pkey != pkey) ||
            (acc.networkPKey != null && acc.networkPKey != networkPKey);
        acc.pkey = pkey;
        acc.networkPKey = networkPKey;
        return keysChanged ? _clearAccountTransactions(acc.id) : Future.value();
      }));
    }).then((_) {
      return syncAccountsByIds(ids, forceSealing: true);
    });
  }
}
