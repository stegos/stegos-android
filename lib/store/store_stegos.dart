import 'package:mobx/mobx.dart';
import 'package:stegos_wallet/env_stegos.dart';
import 'package:stegos_wallet/store/store_common.dart';

part 'store_stegos.g.dart';

class StegosStore = _StegosStore with _$StegosStore;

abstract class _StegosStore extends StoreSupport with Store {
  _StegosStore(this.env);

  final StegosEnv env;

  /// Is user is logged in
  @observable
  bool loggedIn = false;

  @override
  @action
  Future<void> activate() async {
    //await Future.delayed(Duration(microseconds: 1000));
    //print('Activated!!!!');

  }

  @override
  void dispose() {}
}
