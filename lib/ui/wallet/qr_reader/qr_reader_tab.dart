import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:stegos_wallet/env_stegos.dart';
import 'package:stegos_wallet/ui/app.dart';
import 'package:stegos_wallet/ui/pay/screen_pay.dart';
import 'package:stegos_wallet/ui/routes.dart';
import 'package:stegos_wallet/ui/themes.dart';
import 'package:stegos_wallet/ui/wallet/contacts/contacts.dart';
import 'package:stegos_wallet/ui/wallet/qr_reader/qr_reader.dart';

class QrReaderTab extends StatefulWidget {
  const QrReaderTab({Key key, this.isScanning = true}) : super(key: key);

  final bool isScanning;

  @override
  _QrReaderTabState createState() => _QrReaderTabState();
}

class _QrReaderTabState extends State<QrReaderTab> {
  bool isScanning = true;

  @override
  Widget build(BuildContext context) {
    return QrReader(
      isScanning: isScanning && widget.isScanning,
      onStegosAddressFound: onStegosAddressFound,
    );
  }

  void showActions(String address) {
    showModalBottomSheet(
        backgroundColor: StegosColors.backgroundColor,
        context: context,
        builder: (BuildContext bc) => Container(
              height: 211,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  ListTile(
                    title: const Text('Add to contacts'),
                    onTap: () {
                      setState(() {
                        isScanning = false;
                      });
                      StegosApp.navigatorState
                          .pushReplacementNamed(Routes.editContact, arguments: Contact(address: address));
                    },
                  ),
                  ListTile(
                    title: const Text('Send funds'),
                    onTap: () {
                      final env = Provider.of<StegosEnv>(context);
                      if (!env.nodeService.operable) {
                        return;
                      }
                      final account = env.nodeService.accountsList[0];
                      setState(() {
                        isScanning = false;
                      });
                      StegosApp.navigatorState.pushReplacementNamed(Routes.pay,
                          arguments:
                              PayScreenArguments(account: account, recepientAddress: address));
                    },
                  ),
                  ListTile(
                    title: const Text('Cancel'),
                    onTap: () {
                      setState(() {
                        isScanning = true;
                      });
                      StegosApp.navigatorState.pop();
                    },
                  ),
                ],
              ),
            ),
        isDismissible: false);
  }

  void onStegosAddressFound(String address) {
    setState(() {
      isScanning = false;
    });
    showActions(address);
  }
}
