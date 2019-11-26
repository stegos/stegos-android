import 'package:mobx/mobx.dart';
import 'package:pedantic/pedantic.dart';
import 'package:stegos_wallet/log/loggable.dart';
import 'package:stegos_wallet/services/service_node_client.dart';
import 'package:stegos_wallet/store/store_common.dart';
import 'package:stegos_wallet/store/store_stegos.dart';

part 'store_node.g.dart';

class StegosNodeStore = _StegosNodeStore with _$StegosNodeStore;

abstract class _StegosNodeStore with Store, StoreLifecycle, Loggable<StegosNodeStore> {
  _StegosNodeStore(this.parent);

  final StegosStore parent;

  StegosNodeClient get client => parent.env.nodeClient;

  @computed
  bool get connected => client.connected;

  @computed
  bool get operable => client.connected && synchronized;

  @observable
  bool synchronized = false;

  @override
  Future<void> activate() async {
    reaction((_) => client.connected, _syncNodeStatus);
  }

  @override
  Future<void> disposeAsync() async {}

  void _syncNodeStatus(bool connected) {
    if (!connected) {
      return;
    }
    unawaited(client.sendAndAwait({'type': 'status_info'}).then((msg) {
      final json = msg.json;
      runInAction(() {
        synchronized = json['is_synchronized'] as bool ?? false;
      });
    }));
  }
}
