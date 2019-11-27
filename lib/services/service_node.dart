import 'dart:async';

import 'package:ejdb2_flutter/ejdb2_flutter.dart';
import 'package:mobx/mobx.dart';
import 'package:pedantic/pedantic.dart';
import 'package:stegos_wallet/env_stegos.dart';
import 'package:stegos_wallet/log/loggable.dart';
import 'package:stegos_wallet/services/service_node_client.dart';
import 'package:stegos_wallet/stores/store_common.dart';
import 'package:stegos_wallet/stores/store_stegos.dart';

part 'service_node.g.dart';

class StegosNodeStore = _StegosNodeStore with _$StegosNodeStore;

class AccountStore extends _AccountStore with _$AccountStore {
  AccountStore._(int id, String name, int balanceCurrent, int balanceAvailable)
      : super(id, name, balanceCurrent, balanceAvailable);

  factory AccountStore._fromJBDOC(JBDOC doc) {
    final id = doc.object['id'] as int;
    final name = doc.object['name'] as String;
    final balanceCurrent = doc.object['balance_current'] as int ?? 0;
    final balanceAvailable = doc.object['balance_available'] as int ?? 0;
    return AccountStore._(id, name, balanceCurrent, balanceAvailable);
  }
}

abstract class _AccountStore with Store {
  _AccountStore(this.id, this.name, this.balanceCurrent, this.balanceAvailable);

  final int id;

  @observable
  String name;

  @observable
  int balanceCurrent;

  @observable
  int balanceAvailable;

  @observable
  bool sealed = true;

  @override
  int get hashCode => id.hashCode;

  @override
  bool operator ==(dynamic other) => other is _AccountStore && other.id == id;

  @action
  void _update(JBDOC doc) {
    name = doc.object['name'] as String;
    balanceCurrent = doc.object['balance_current'] as int ?? balanceCurrent;
    balanceAvailable = doc.object['balance_available'] as int ?? balanceAvailable;
  }

  @override
  String toString() => 'AccountStore{id=${id}'
      ', name=${name}'
      ', balanceCurrent=${balanceCurrent}'
      ', balanceAvailable=${balanceAvailable}'
      '}';
}

abstract class _StegosNodeStore with Store, StoreLifecycle, Loggable<StegosNodeStore> {
  _StegosNodeStore(this.parent);

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

  Future<void> _syncAccountsBalances(Iterable<int> ids) {
    // todo:
    // if (env.store.accountPassword == null) {
    // }
  }

  Future<void> _syncAccountBalance(int id) async {
    // todo:
  }

  Future<void> _sealAccount(int id) async {
    // todo:
  }

  Future<void> _unsealAccount(int id) async {
    // todo:
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
    }).then((_) => _syncAccountsBalances(ids));
  }
}
