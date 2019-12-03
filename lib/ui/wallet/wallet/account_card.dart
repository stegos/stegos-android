import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:stegos_wallet/services/service_node.dart';
import 'package:stegos_wallet/ui/routes.dart';
import 'package:stegos_wallet/ui/themes.dart';

class AccountCard extends StatefulWidget {
  AccountCard({@required ValueKey<AccountStore> key, @required this.collapsed}) : super(key: key);
  final bool collapsed;

  AccountStore get account => (key as ValueKey<AccountStore>).value;

  @override
  AccountCardState createState() => AccountCardState();
}

class AccountCardState extends State<AccountCard> {
  double get aspectRation => widget.collapsed ? 302 / 48 : 302 / 174.06;

  @override
  Widget build(BuildContext context) => Observer(builder: (context) {
        final acc = widget.account;
        final bgAlignment = (() {
          switch (acc.ordinal % 3) {
            case 1:
              return Alignment.topCenter;
            case 2:
              return Alignment.center;
            default:
              return Alignment.bottomCenter;
          }
        })();

        return Container(
          width: MediaQuery.of(context).size.width - 60,
          margin: EdgeInsets.symmetric(vertical: widget.collapsed ? 4 : 15),
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
                onTap: () => Navigator.pushNamed(context, Routes.account),
                child: AspectRatio(
                    aspectRatio: aspectRation,
                    child: Stack(
                      children: <Widget>[
                        Container(
                            alignment: Alignment.centerRight,
                            padding: EdgeInsets.only(right: widget.collapsed ? 52 : 19),
                            child: Text('${acc.humanBalance} STG',
                                style: TextStyle(fontSize: widget.collapsed ? 18 : 32))),
                        Container(
                            padding: EdgeInsets.only(
                              left: 15,
                              bottom: widget.collapsed ? 13 : 10,
                              right: 20,
                            ),
                            alignment: Alignment.bottomCenter,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(acc.humanName, style: const TextStyle(fontSize: 12)),
                                const Image(
                                    image: AssetImage('assets/images/qr.png'),
                                    width: 20,
                                    height: 20),
                              ],
                            ))
                      ],
                    )),
              ),
            ),
          ),
        );
      });
}
