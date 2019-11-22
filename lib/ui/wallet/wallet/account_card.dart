import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class Account {
  Account({this.name = '', this.balance = 0, this.qrUrl = ''});

  String name;
  double balance;
  String qrUrl;
}

class AccountCard extends StatefulWidget {
  AccountCard({Key key, this.account, this.collapsed = false}) : super(key: key);

  final Account account;
  final bool collapsed;

  @override
  AccountCardState createState() => AccountCardState(account, collapsed);
}

class AccountCardState extends State<AccountCard> {

  const  normalAspectRatio = 302 / 174.06;
  AccountCardState(this.account, this.collapsed);

  final Account account;

  final SvgPicture accountsIcon = SvgPicture.asset('assets/images/accounts.svg');

  final Image qrIcon =
      Image(image: const AssetImage('assets/images/qr.png'), width: 20, height: 20);
  final AssetImage backgroundImage = const AssetImage('assets/images/account_card_bg.png');

  bool collapsed;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 30.0),
        child: Ink.image(
          image: backgroundImage,
          fit: BoxFit.fill,
          child: InkWell(
            borderRadius: BorderRadius.circular(3.0),
            onTap: () {},
            child: AspectRatio(
              aspectRatio: 1.73,
              child: Container(
                  padding: const EdgeInsets.only(left: 15, bottom: 10, right: 20),
                  child: Stack(
                    children: <Widget>[
                      Align(
                          alignment: Alignment.centerRight,
                          child: Text('${account.balance} STG', style: TextStyle(fontSize: 32))),
                      Align(
                          alignment: Alignment.bottomRight,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(account.name, style: TextStyle(fontSize: 12)),
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
