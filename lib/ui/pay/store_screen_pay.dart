import 'package:mobx/mobx.dart';
import 'package:stegos_wallet/services/service_node.dart';

part 'store_screen_pay.g.dart';

class PayScreenStore = _PayScreenStore with _$PayScreenStore;

abstract class _PayScreenStore with Store {
  @observable
  AccountStore senderAccount;

  @observable
  String toAddress;

  @observable
  double amount = 0.0;

  @observable
  double fee = stegosFeeStandard / 1e6;

  @observable
  bool generateCertificate = false;

  @action
  void reset() {
    fee = stegosFeeStandard / 1e6;
    senderAccount = null;
    toAddress = null;
    generateCertificate = false;
  }
}
