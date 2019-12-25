import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:stegos_wallet/services/service_node.dart';
import 'package:stegos_wallet/ui/app.dart';
import 'package:stegos_wallet/ui/qr_generator/qr_generator.dart';
import 'package:stegos_wallet/ui/routes.dart';
import 'package:stegos_wallet/ui/themes.dart';

class AccountCard extends StatelessWidget {
  AccountCard({
    @required ValueKey<AccountStore> key,
    @required this.collapsed,
    this.onTap,
    this.backgroundAlignment,
  }) : super(key: key);
  final bool collapsed;
  final void Function() onTap;
  final Alignment backgroundAlignment;

  AccountStore get account => (key as ValueKey<AccountStore>).value;

  double get aspectRation => collapsed ? 302 / 48 : 302 / 174.06;

  @override
  Widget build(BuildContext context) => Observer(builder: (context) {
        final bgAlignment =
            backgroundAlignment ?? Alignment(0, (account.ordinal % 3 - 1).toDouble());
        return Container(
          width: MediaQuery.of(context).size.width - 60,
          margin: EdgeInsets.symmetric(vertical: collapsed ? 4 : 15),
          color: StegosColors.backgroundColor,
          child: Material(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3.0)),
            type: MaterialType.transparency,
            clipBehavior: Clip.antiAliasWithSaveLayer,
            child: Ink.image(
              image: const AssetImage('assets/images/account_card_bg.png'),
              fit: BoxFit.cover,
              alignment: bgAlignment,
              child: InkWell(
                borderRadius: BorderRadius.circular(3.0),
                onTap:
                    onTap ?? () => Navigator.pushNamed(context, Routes.account, arguments: account),
                child: AspectRatio(
                    aspectRatio: aspectRation,
                    child: Stack(
                      children: <Widget>[
                        Container(
                            alignment: Alignment.centerRight,
                            padding: EdgeInsets.only(right: collapsed ? 52 : 19),
                            child: Text('${account.humanBalance} STG',
                                style: TextStyle(fontSize: collapsed ? 18 : 32))),
                        Container(
                            padding: EdgeInsets.only(
                              left: 15,
                              bottom: collapsed ? 13 : 10,
                              right: 20,
                            ),
                            alignment: Alignment.bottomCenter,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(account.humanName, style: const TextStyle(fontSize: 12)),
                                GestureDetector(
                                  onTap: showQRCode,
                                  child: const Image(
                                      image: AssetImage('assets/images/qr.png'),
                                      width: 20,
                                      height: 20),
                                ),
                              ],
                            ))
                      ],
                    )),
              ),
            ),
          ),
        );
      });

  Future<String> showQRCode() {
    return StegosApp.navigatorState.push(MaterialPageRoute(
      builder: (BuildContext context) => QrGenerator(
        title: 'QR code for ${account.humanName}',
        qrData: account.pkey,
      ),
      fullscreenDialog: true,
    ));
  }
}
