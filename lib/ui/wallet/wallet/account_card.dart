import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:stegos_wallet/ui/themes.dart';

class Account {
  Account({this.name = '', this.balance = 0, this.qrUrl = '', @required this.order});

  String name;
  double balance;
  String qrUrl;
  int order;
}

class AccountCard extends StatefulWidget {
  AccountCard({@required ValueKey<Account> key, this.collapsed = false, this.order = 0})
      : super(key: key);

  final bool collapsed;
  final int order;

  Account get account => (key as ValueKey<Account>).value;

  @override
  AccountCardState createState() => AccountCardState();
}

class AccountCardState extends State<AccountCard> {
  final double normalAspectRatio = 302 / 174.06;
  final double collapsedAspectRatio = 302 / 48;

  final SvgPicture accountsIcon = SvgPicture.asset('assets/images/accounts.svg');

  final Image qrIcon =
      Image(image: const AssetImage('assets/images/qr.png'), width: 20, height: 20);
  final AssetImage backgroundImage = const AssetImage('assets/images/account_card_bg.png');

  double get aspectRation => widget.collapsed ? collapsedAspectRatio : normalAspectRatio;

  Alignment get bgAlignment {
    switch (widget.order % 3) {
      case 0:
        return Alignment.topCenter;
      case 1:
        return Alignment.center;
      case 2:
        return Alignment.bottomCenter;
      default:
        return Alignment.topCenter;
    }
  }

  @override
  Widget build(BuildContext context) => Container(
        width: MediaQuery.of(context).size.width - 60,
        margin: EdgeInsets.symmetric(vertical: widget.collapsed ? 4 : 15),
        color: StegosColors.backgroundColor,
        child: Material(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3.0)),
          type: MaterialType.transparency,
          clipBehavior: Clip.antiAliasWithSaveLayer,
          child: Ink.image(
            image: backgroundImage,
            fit: BoxFit.cover,
            alignment: bgAlignment,
            child: InkWell(
              borderRadius: BorderRadius.circular(3.0),
              onTap: () {},
              child: AspectRatio(
                  aspectRatio: aspectRation,
                  child: Stack(
                    children: <Widget>[
                      Container(
                          alignment: Alignment.centerRight,
                          padding: EdgeInsets.only(right: widget.collapsed ? 52 : 19),
                          child: Text('${widget.account.balance} STG',
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
                              Text(widget.account.name, style: TextStyle(fontSize: 12)),
                              qrIcon,
                            ],
                          ))
                    ],
                  )),
            ),
          ),
        ),
      );
}
