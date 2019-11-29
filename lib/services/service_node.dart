import 'dart:async';
import 'dart:convert';

import 'package:ejdb2_flutter/ejdb2_flutter.dart';
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
import 'package:stegos_wallet/utils/extensions_db.dart';

part 'service_node.g.dart';

class NodeService = _NodeService with _$NodeService;

class AccountStore extends _AccountStore with _$AccountStore {
  AccountStore.empty(int id) : super(id);
  AccountStore._(int id, String name, String password, String iv) : super(id, name, password, iv);

  factory AccountStore._fromJBDOC(JBDOC doc) {
    return AccountStore._(doc.object['id'] as int, doc.object['name'] as String,
        doc.object['password'] as String, doc.object['iv'] as String);
  }

  @override
  int get hashCode => id.hashCode;

  @override
  bool operator ==(dynamic other) => other is AccountStore && other.id == id;
}

abstract class _AccountStore with Store {
  _AccountStore(this.id, [this.name, this._password, this._iv]) {
    ordinal = id;
  }

  final int id;

  String pkey;

  String networkPkey;

  @computed
  String get humanName => name ?? 'Account #${id}';

  String get humanBalance => '${balanceCurrent}';

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

  /// PIN encrypted dedicated account password
  String _password;

  String _iv;

  @override
  int get hashCode => id.hashCode;

  @override
  bool operator ==(dynamic other) => other is _AccountStore && other.id == id;

  @action
  void _updateFromJson(dynamic json) {
    name = json['name'] as String ?? name;
    ordinal = json['ordinal'] as int ?? ordinal;
    _password = json['password'] as String;
    _iv = json['iv'] as String;
  }

  void _updateFromJBDOC(JBDOC doc) => _updateFromJson(doc.object);

  @action
  void _updateFromBalanceMessage(StegosNodeMessage msg) {
    balanceIsFinal = msg.at('/is_final').transform((v) => v as bool).or(balanceIsFinal ?? false);
    balanceCurrent = msg.at('/current').transform((v) => v as int).or(balanceCurrent ?? 0);
    balanceAvailable = msg.at('/available').transform((v) => v as int).or(balanceAvailable ?? 0);
    balancePaymentCurrent =
        msg.at('/payment/current').transform((v) => v as int).or(balancePaymentCurrent ?? 0);
    balancePaymentAvailable =
        msg.at('/payment/available').transform((v) => v as int).or(balancePaymentAvailable ?? 0);
    balancePublicCurrent =
        msg.at('/public_payment/current').transform((v) => v as int).or(balancePublicCurrent ?? 0);
    balancePublicAvailable = msg
        .at('/public_payment/available')
        .transform((v) => v as int)
        .or(balancePublicAvailable ?? 0);
    balanceStakeCurrent =
        msg.at('/stake/current').transform((v) => v as int).or(balanceStakeCurrent ?? 0);
    balanceStakeAvailable =
        msg.at('/stake/available').transform((v) => v as int).or(balanceStakeAvailable ?? 0);
  }

  dynamic toJson() => {
        // Note: Sensitive info is not stored in db
        'id': id,
        'name': name,
        'ordinal': ordinal,
        'password': _password,
        'iv': _iv
      };

  @override
  String toString() => jsonEncode(this);
}

class _UnsealAccountStatus {
  const _UnsealAccountStatus({this.unsealed = false, this.invalidPassword = false});
  final bool unsealed;
  final bool invalidPassword;
  @override
  String toString() => 'usealed=${unsealed}, invalidPassword=${invalidPassword}';
}

abstract class _NodeService with Store, StoreLifecycle, Loggable<NodeService> {
  _NodeService(this.parent);

  final StegosStore parent;

  StegosNodeClient get client => parent.env.nodeClient;

  StegosEnv get env => parent.env;

  final accounts = ObservableMap<int, AccountStore>();

  @computed
  List<AccountStore> get accountsList =>
      accounts.values.toList(growable: false)..sort((a, b) => a.ordinal.compareTo(b.ordinal));

  /// Is app is connected to network
  @computed
  bool get connected => client.connected;

  /// Is Segos network node operable:
  ///  - We can send transactions
  ///  - We can acquire account baalnces
  @computed
  bool get operable => client.connected && synchronized;

  /// Is Stegos network node synchronized
  @observable
  bool synchronized = false;

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

  Future<void> swapAccounts(int fromIndex, int toIndex) {
    final alist = accountsList;
    if (fromIndex != toIndex && fromIndex < alist.length && toIndex < alist.length) {
      log.warning('reorderAccounts: invalid arguments: ${fromIndex}, ${toIndex}');
      return Future.value();
    }
    final from = alist[fromIndex];
    final to = alist[toIndex];
    runInAction(() {
      final tmp = from.ordinal;
      from.ordinal = to.ordinal;
      to.ordinal = tmp;
    });
    return env.useDb((db) => Future.wait([
          db.patch(_accountsCollecton, {'ordinal': to.ordinal}, to.id),
          db.patch(_accountsCollecton, {'ordinal': from.ordinal}, from.id),
        ]));
  }

  @computed
  String get _accountsCollecton => 'accounts_$network';

  final _disposers = <ReactionDisposer>[];

  // ignore: cancel_subscriptions
  StreamSubscription<StegosNodeMessage> _nodeClientSubscription;

  @override
  Future<void> activate() async {
    _disposers.add(reaction((_) => client.connected, _syncNodeStatus));
    _disposers.add(
        reaction((_) => client.connected && !env.securityService.needAppUnlock, (bool connected) {
      if (connected) _syncAccounts();
    }));
    _nodeClientSubscription = client.stream.listen(_onNodeMessage);
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

  Future<void> _onUpdateBalance(StegosNodeMessage msg) {
    final acc = accounts[msg.accountId];
    if (acc == null) {
      return Future.value();
    }
    if (log.isFine) {
      log.info('Update balance: ${msg}');
    }
    return env.useDb((db) {
      acc._updateFromBalanceMessage(msg);
      return db.patchOrPut(_accountsCollecton, acc, acc.id);
    });
  }

  void _onNodeMessage(StegosNodeMessage msg) {
    switch (msg.type) {
      case 'balance_changed':
        unawaited(_onUpdateBalance(msg));
        break;
    }
  }

  void _syncNodeStatus(bool connected) {
    if (!connected) {
      return;
    }
    unawaited(client.sendAndAwait({'type': 'status_info'}).then((msg) {
      runInAction(() {
        synchronized = msg.json['is_synchronized'] as bool ?? false;
      });
    }));
  }

  Future<void> _syncAccountsInfos(Iterable<int> ids, {bool forceSealing = false}) =>
      Future.forEach(ids, (int id) {
        return _syncAccountInfo(id, forceSealing: forceSealing).catchError((err, StackTrace st) {
          log.warning('Error getting account info #${id}', err, st);
          accounts.remove(id);
        });
      });

  Future<AccountStore> _syncAccountInfo(int id, {bool forceSealing = false}) async {
    final acc = await _unsealAccount(id, force: forceSealing);
    try {
      final msg = await client.sendAndAwait({'type': 'balance_info', 'account_id': '$id'});
      await env.useDb((db) {
        acc._updateFromBalanceMessage(msg);
        return db.patchOrPut(_accountsCollecton, acc, id);
      });
    } finally {
      await _sealAccount(id, force: forceSealing);
    }
    if (log.isFine) {
      log.fine('Fetched account info: ${acc}');
    }
    return acc;
  }

  Future<AccountStore> _sealAccount(int id, {bool force = false}) {
    if (log.isFine) {
      log.fine('Sealing account: #${id}');
    }
    final acc = _account(id);
    if (!force && acc.sealed) {
      return Future.value(acc);
    }
    return client.sendAndAwait({'type': 'seal', 'account_id': '$id'}).catchError((err) {
      if (err is StegosNodeErrorMessage && err.accountIsSealed) {
        // Account is sealed already
        return Future<StegosNodeMessage>.value();
      } else {
        return Future<StegosNodeMessage>.error(err);
      }
    }).then((_) {
      runInAction(() {
        acc.sealed = true;
      });
      if (log.isFine) {
        log.fine('Account#${id} is sealed');
      }
      return acc;
    });
  }

  Future<AccountStore> _unsealAccount(int id, {bool force = false}) async {
    final acc = _account(id);
    if (!force && !acc.sealed) {
      return acc;
    }
    _UnsealAccountStatus status;
    final pwp = await env.securityService.acquirePasswordForApp();
    if (acc._password != null && acc._iv != null) {
      // We have own pin protected account password
      final apwp =
          env.securityService.recoverPinProtectedPassword(pwp.second, acc._password, acc._iv);
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
        await client.sendAndAwait(
            {'type': 'change_password', 'account_id': '$id', 'new_password': pwp.first});
      } else {
        final pw = await appShowDialog<String>(
            builder: (context) => PasswordScreen(
                  title: 'Unlock account ${acc.humanName}',
                  caption: 'It seems that account is locked by unknown password.',
                  titleStatus: 'Please provide account password to unlock',
                  titleSubmitButton: 'UNLOCK',
                  unlocker: (password) async {
                    status = await _unsealAccountRaw(acc, password);
                    if (status.invalidPassword) {
                      return Pair(null, 'Invalid password provided');
                    }
                    final pwp = await env.securityService.acquirePasswordForApp();
                    final pp = env.securityService.setupPinProtectedPassword(password, pwp.second);
                    acc._password = pp.first;
                    acc._iv = pp.second;
                    await env.useDb((db) => db.patchOrPut(
                        _accountsCollecton, {'password': acc._password, 'iv': acc._iv}, id));
                    return Pair(password, null);
                  },
                ));
        if (pw == null) {
          // User cannot unlock this account
          throw Exception('Failed to unlock account: ${acc.humanName} skipping it');
        }
      }
    }
    return acc;
  }

  Future<_UnsealAccountStatus> _unsealAccountRaw(AccountStore acc, String password) {
    if (log.isFine) {
      log.fine('Unsealing account raw #${acc.id}');
    }
    return client
        .sendAndAwait({'type': 'unseal', 'account_id': '${acc.id}', 'password': password})
        .then((_) => const _UnsealAccountStatus(unsealed: true))
        .catchError((err) {
          if (err is StegosNodeErrorMessage) {
            if (err.accountAlreadyUnsealed) {
              return const _UnsealAccountStatus(unsealed: true);
            } else if (err.invalidPassword) {
              return const _UnsealAccountStatus(unsealed: false, invalidPassword: true);
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

  Future<Map<String, dynamic>> _listRawAccounts() => client.sendAndAwait(
      {'type': 'list_accounts'}).then((msg) => msg.json['accounts'] as Map<String, dynamic> ?? {});

  Future<Map<String, dynamic>> _detectNetworkAndSetupInitialAccounts() async {
    var nodeAccounts = await _listRawAccounts();
    if (nodeAccounts.isEmpty) {
      final pwp = await env.securityService.acquirePasswordForApp();
      await client.sendAndAwait({'type': 'create_account', 'password': pwp.first});
      nodeAccounts = await _listRawAccounts();
      if (nodeAccounts.isEmpty) {
        throw StegosUserException('Unable to create an initial account and determine network type');
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

  Future<void> _syncAccounts() async {
    final nodeAccounts = await _detectNetworkAndSetupInitialAccounts();
    final ids = nodeAccounts.keys.map(int.parse).toList();
    // Cleanup not matched accounts
    runInAction(() {
      accounts.removeWhere((k, v) => !ids.contains(k));
    });
    if (ids.isEmpty) {
      return Future.value();
    }
    return env.useDb((db) async {
      await for (final doc
          in db.createQuery('/[id in :?]', _accountsCollecton).setJson(0, ids).execute()) {
        final id = doc.object['id'] as int;
        final acc = accounts[id];
        if (log.isFine) {
          log.fine('Loaded db account: ${doc}');
        }
        if (acc == null) {
          runInAction(() {
            accounts[id] = AccountStore._fromJBDOC(doc);
          });
        } else {
          acc._updateFromJBDOC(doc);
        }
      }
      runInAction(() {
        ids.forEach((id) {
          AccountStore acc = accounts[id];
          if (acc == null) {
            acc = AccountStore.empty(id);
            accounts[id] = acc;
          }
          final ainfo = nodeAccounts['$id'];
          if (ainfo != null) {
            acc.pkey = ainfo['account_pkey'] as String;
            acc.networkPkey = ainfo['network_pkey'] as String;
          }
        });
      });
    }).then((_) {
      return _syncAccountsInfos(ids, forceSealing: true);
    });
  }
}
