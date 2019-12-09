import 'package:mobx/mobx.dart';
import 'package:stegos_wallet/services/service_node.dart';

part 'store_screen_pay.g.dart';

class PayScreenStore = _PayScreenStore with _$PayScreenStore;

abstract class _PayScreenStore with Store {

  static final RegExp _stegosAddressRegExp = RegExp(
    r'^st[rgt]1[ac-hj-np-z02-9]{8,87}$',
    caseSensitive: false,
    multiLine: false,
  );

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

   @computed
   bool isValidToAddress() {
      if (toAddress == null) {
        return false;
      } else {
        return _stegosAddressRegExp.hasMatch(toAddress);
      }
   }
//  export const BECH32_STEGOS_ADDRESS_REGEX = /^st[rgt]1[ac-hj-np-z02-9]{8,87}$/;

//  export const isStegosAddress = str => BECH32_STEGOS_ADDRESS_REGEX.test(str);

}
