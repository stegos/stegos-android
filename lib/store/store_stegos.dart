import 'package:mobx/mobx.dart';
import 'package:stegos_wallet/env_stegos.dart';
import 'package:stegos_wallet/store/store_common.dart';

part 'store_stegos.g.dart';

class StegosStore = _StegosStore with _$StegosStore;

abstract class _StegosStore extends StoreSupport with Store {
  _StegosStore(this.env);

  final StegosEnv env;

  /// Current app route.
  @observable
  String route = '';

  @override
  Future<void> activate() async {}

  @override
  void dispose() {}
}
