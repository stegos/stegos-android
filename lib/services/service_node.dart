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
import 'package:stegos_wallet/utils/extensions_db.dart';

part 'service_node.g.dart';

class NodeService = _NodeService with _$NodeService;

class AccountStore extends _AccountStore with _$AccountStore {
  AccountStore.empty(int id) : super(id);
  AccountStore._(
      int id,
      String name,
      bool balanceIsFinal,
      int balanceCurrent,
      int balanceAvailable,
      int balanceStakeCurrent,
      int balanceStakeAvailable,
      int balancePublicCurrent,
      int balancePublicAvailable,
      int balancePaymentCurrent,
      int balancePaymentAvailable)
      : super(
            id,
            name,
            balanceIsFinal,
            balanceCurrent,
            balanceAvailable,
            balanceStakeCurrent,
            balanceStakeAvailable,
            balancePublicCurrent,
            balancePublicAvailable,
            balancePaymentCurrent,
            balancePaymentAvailable);

  factory AccountStore._fromJBDOC(JBDOC doc) {
    return AccountStore._(
        doc.object['id'] as int,
        doc.object['name'] as String,
        doc.object['balance_is_final'] as bool ?? false,
        doc.object['balance_current'] as int ?? 0,
        doc.object['balance_available'] as int ?? 0,
        doc.object['balance_stake_current'] as int ?? 0,
        doc.object['balance_stake_available'] as int ?? 0,
        doc.object['balance_public_current'] as int ?? 0,
        doc.object['balance_public_available'] as int ?? 0,
        doc.object['balance_payment_current'] as int ?? 0,
        doc.object['balance_payment_available'] as int ?? 0);
  }
}

abstract class _AccountStore with Store {
  _AccountStore(this.id,
      [this.name,
      this.balanceIsFinal,
      this.balanceCurrent,
      this.balanceAvailable,
      this.balanceStakeCurrent,
      this.balanceStakeAvailable,
      this.balancePublicCurrent,
      this.balancePublicAvailable,
      this.balancePaymentCurrent,
      this.balancePaymentAvailable]);

  final int id;

  String pkey;

  String networkPkey;

  @computed
  String get humanName => name ?? 'Account #${name}';

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

  final accounts = ObservableMap<int, AccountStore>();

  StegosEnv get env => parent.env;

  @computed
  bool get connected => client.connected;

  @computed
  bool get operable => client.connected && synchronized;

  @observable
  bool synchronized = false;

  // ignore: cancel_subscriptions
  StreamSubscription<StegosNodeMessage> _clientSubscription;

  final disposers = <ReactionDisposer>[];

  @override
  Future<void> activate() async {
    disposers.add(reaction((_) => client.connected, _syncNodeStatus));
    disposers.add(
        reaction((_) => client.connected && !env.securityService.needAppUnlock, (bool connected) {
      if (connected) {
        _syncAccounts();
      }
    }));
    _clientSubscription = client.stream.listen(_onNodeMessage);
  }

  @override
  Future<void> disposeAsync() async {
    disposers.forEach((d) => d());
    disposers.length = 0;
    if (_clientSubscription != null) {
      final subscription = _clientSubscription;
      _clientSubscription = null;
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
      return db.patchOrPut('accounts', acc, acc.id);
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
        return db.patchOrPut('accounts', acc, id);
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
    return client.sendAndAwait({'type': 'seal', 'account_id': '$id'}).then((_) {
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
    final pwpin = await env.securityService.acquirePasswordForApp();
    var status = await _unsealAccountRaw(acc, pwpin.first);
    if (status.unsealed) {
      return acc;
    }
    if (status.invalidPassword) {
      // Default empty password is used?
      status = await _unsealAccountRaw(acc, '');
      if (status.unsealed) {
        // If so try to change password
        log.warning('Trying to change default password for account: $id');
        await client.sendAndAwait(
            {'type': 'change_password', 'account_id': '$id', 'new_password': pwpin.first});
      } else {
        log.warning('It seems account has different password');
        // todo: ask user for password!!
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

  Future<void> _syncAccounts() async {
    final msg = await client.sendAndAwait({'type': 'list_accounts'});
    final nodeAccounts = msg.json['accounts'] as Map<String, dynamic> ?? {};
    final ids = nodeAccounts.keys.map(int.parse).toList();

    // Cleanup not matched accounts
    accounts.removeWhere((k, v) => !ids.contains(k));
    if (ids.isEmpty) {
      return Future.value();
    }
    return env.useDb((db) async {
      await for (final doc in db.createQuery('@accounts/[id in :?]').setJson(0, ids).execute()) {
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
