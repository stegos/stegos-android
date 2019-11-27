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

  @override
  int get hashCode => id.hashCode;

  @override
  bool operator ==(dynamic other) => other is _AccountStore && other.id == id;

  @action
  void _update(JBDOC doc) {
    name = doc.object['name'] as String;
    balanceIsFinal = doc.object['balance_is_final'] as bool;
    balanceCurrent = doc.object['balance_current'] as int ?? balanceCurrent;
    balanceAvailable = doc.object['balance_available'] as int ?? balanceAvailable;
    balanceStakeCurrent = doc.object['balance_stake_current'] as int ?? balanceStakeCurrent;
    balanceStakeAvailable = doc.object['balance_stake_available'] as int ?? balanceStakeAvailable;
    balancePublicCurrent = doc.object['balance_public_current'] as int ?? balancePublicCurrent;
    balancePublicAvailable =
        doc.object['balance_public_available'] as int ?? balancePublicAvailable;
    balancePaymentCurrent = doc.object['balance_payment_current'] as int ?? balancePaymentCurrent;
    balancePaymentAvailable =
        doc.object['balance_payment_available'] as int ?? balancePaymentAvailable;
  }

  dynamic toJson() => {
        'id': id,
        'name': name,
        'balance_is_final': balanceIsFinal,
        'balance_current': balanceCurrent,
        'balance_available': balanceAvailable,
        'balance_stake_current': balanceStakeCurrent,
        'balance_stake_available': balanceStakeAvailable,
        'balance_public_current': balancePublicCurrent,
        'balance_public_available': balancePublicAvailable,
        'balance_payment_current': balancePaymentCurrent,
        'balance_payment_available': balancePaymentAvailable,
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

  void _onNodeMessage(StegosNodeMessage msg) {
    print('!!!!!! ON NODE  ${msg}');
    //{"account_id":"2","type":"balance_changed",
    //"payment":{"current":2000000,"availamessageble":2000000},
    //"public_payment":{"current":0,"available":0},
    //"stake":{"current":0,"available":0},
    //"current":2000000,"available":2000000,
    //"is_final":false}
  }

  void _syncNodeStatus(bool connected) {
    if (!connected) {
      return;
    }
    unawaited(client.sendAndAwait({'type': 'status_info'}).then((msg) {
      final json = msg.json;
      runInAction(() {
        synchronized = json['is_synchronized'] as bool ?? false;
      });
      _syncAccounts();
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
      acc.balanceIsFinal = msg.at('/is_final').transform((v) => v as bool).or(false);
      acc.balanceCurrent = msg.at('/current').transform((v) => v as int).or(0);
      acc.balanceAvailable = msg.at('/available').transform((v) => v as int).or(0);
      acc.balancePaymentCurrent = msg.at('/payment/current').transform((v) => v as int).or(0);
      acc.balancePaymentAvailable = msg.at('/payment/available').transform((v) => v as int).or(0);
      acc.balancePublicCurrent = msg.at('/public_payment/current').transform((v) => v as int).or(0);
      acc.balancePublicAvailable =
          msg.at('/public_payment/available').transform((v) => v as int).or(0);
      acc.balanceStakeCurrent = msg.at('/stake/current').transform((v) => v as int).or(0);
      acc.balanceStakeAvailable = msg.at('/stake/available').transform((v) => v as int).or(0);
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
    final pw = await env.securityService.acquirePasswordForAccount(accountId: id);
    var status = await _unsealAccountRaw(acc, pw);
    if (status.unsealed) {
      return acc;
    }
    if (status.invalidPassword) {
      // Maybe default empty password is used?
      status = await _unsealAccountRaw(acc, '');
      if (status.unsealed) {
        // Try to change password
        print('!!!!! PW=${pw}');
        log.warning('Trying to change default password for account: $id');
        await client
            .sendAndAwait({'type': 'change_password', 'account_id': '$id', 'new_password': pw});
      } else {
        log.warning('It seems what wrong password entered');
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
        if (acc == null) {
          runInAction(() {
            accounts[id] = AccountStore._fromJBDOC(doc);
          });
        } else {
          acc._update(doc);
        }
      }
      ids.forEach((id) {
        if (!accounts.containsKey(id)) {
          accounts[id] = AccountStore.empty(id);
        }
      });
      // todo:
    }).then((_) => _syncAccountsInfos(ids.sublist(0, 1), forceSealing: true));
  }
}
