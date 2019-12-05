import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:stegos_wallet/env_stegos.dart';
import 'package:stegos_wallet/services/service_node.dart';
import 'package:stegos_wallet/ui/account/transactions_list.dart';
import 'package:stegos_wallet/ui/routes.dart';
import 'package:stegos_wallet/ui/themes.dart';
import 'package:stegos_wallet/ui/transactions/screen_transactions.dart';
import 'package:stegos_wallet/widgets/widget_app_bar.dart';

class Transaction {
  Transaction({this.amount = 0, this.created, this.certificateURL});

  final double amount;
  final DateTime created;
  final String certificateURL;
}

class AccountScreen extends StatefulWidget {
  AccountScreen({Key key, this.id}) : super(key: key);

  final int id;

  @override
  AccountScreenState createState() => AccountScreenState();
}

class AccountScreenState extends State<AccountScreen> {
  static const _iconBackImage = AssetImage('assets/images/arrow_back.png');

  final EdgeInsets defaultPadding = const EdgeInsets.all(16.0);

  final List<Transaction> transactions = [
    Transaction(amount: 10, created: DateTime.now(), certificateURL: 'URL to certificate document'),
    Transaction(amount: -1230, created: DateTime.now(), certificateURL: null),
    Transaction(amount: -1.1235, created: DateTime.now(), certificateURL: null),
    Transaction(amount: 3250, created: DateTime.now(), certificateURL: null),
    Transaction(amount: 1.0001, created: DateTime.now(), certificateURL: null),
    Transaction(amount: 10, created: DateTime.now(), certificateURL: 'URL to certificate document'),
    Transaction(amount: -1230, created: DateTime.now(), certificateURL: null),
    Transaction(amount: -1.1235, created: DateTime.now(), certificateURL: null),
    Transaction(amount: 3250, created: DateTime.now(), certificateURL: null),
    Transaction(amount: 1.0001, created: DateTime.now(), certificateURL: null),
    Transaction(amount: 10, created: DateTime.now(), certificateURL: 'URL to certificate document'),
    Transaction(amount: -1230, created: DateTime.now(), certificateURL: null),
    Transaction(amount: -1.1235, created: DateTime.now(), certificateURL: null),
    Transaction(amount: 3250, created: DateTime.now(), certificateURL: null),
    Transaction(amount: 1.0001, created: DateTime.now(), certificateURL: null)
  ];

  @override
  Widget build(BuildContext context) {
    final env = Provider.of<StegosEnv>(context);
    final AccountStore acc = env.nodeService.accountsList.firstWhere((AccountStore a) => a.id == widget.id);
    return Theme(
        data: StegosThemes.AccountTheme,
        child: Scaffold(
          appBar: AppBarWidget(
            centerTitle: false,
            backgroundColor: Theme.of(context).colorScheme.primary,
            leading: IconButton(
              icon: const Image(
                image: _iconBackImage,
                width: 24,
                height: 24,
              ),
              onPressed: () => Navigator.pop(context, false),
            ),
            actions: <Widget>[
              IconButton(
                icon: SvgPicture.asset(
                  'assets/images/gear.svg',
                  width: 22,
                  height: 22,
                ),
                onPressed: () => Navigator.pushNamed(context, Routes.settings, arguments: acc.id),
              )
            ],
            title: Text(acc.humanName),
          ),
          body: Column(
            children: <Widget>[
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Container(
                    child: Container(
                        padding: const EdgeInsets.only(top: 30),
                        color: StegosColors.splashBackground,
                        child: Column(
                          children: <Widget>[
                            const Text('Balance', style: TextStyle(fontSize: 14)),
                            const SizedBox(height: 7),
                            Text('${acc.humanBalance} STG',
                                style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w500,
                                    color: StegosColors.primaryColor)),
                            const SizedBox(height: 26),
                            Container(
                                height: 40,
                                margin: const EdgeInsets.symmetric(horizontal: 22),
                                decoration: const BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(color: StegosColors.white, width: 1)),
                                ),
                                child: Center(
                                  child: SelectableText(
                                      acc.pkey,
                                      style: const TextStyle(fontSize: 10)),
                                )),
                            Container(
                                alignment: Alignment.topRight,
                                padding: const EdgeInsets.only(top: 14, right: 22, bottom: 19),
                                child: SvgPicture.asset(
                                  'assets/images/qr.svg',
                                  width: 34,
                                  height: 34,
                                )),
                            _buildButtons()
                          ],
                        ))),
              ]),
              Expanded(
                child: Stack(
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      height: 57,
                      alignment: Alignment.center,
                      child: Text(
                        'Transactions',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        height: 57,
                        alignment: Alignment.centerRight,
                        child: transactions.isNotEmpty
                            ? GestureDetector(
                                onTap: _seeAll,
                                child: Text(
                                  'See all',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                              )
                            : null),
                    Container(
                        alignment: Alignment.topCenter,
                        padding: const EdgeInsets.only(top: 57),
                        child: TransactionsList(transactions)),
                  ],
                ),
              )
            ],
          ),
        ));
  }

  Container _buildButtons() => Container(
        color: StegosColors.backgroundColor,
        child: Container(
          padding: const EdgeInsets.only(top: 33, bottom: 25),
          margin: const EdgeInsets.symmetric(horizontal: 10),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: StegosColors.white, width: 1)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    width: 65,
                    height: 65,
                    child: RaisedButton(
                      padding: const EdgeInsets.all(10),
                      onPressed: () {Navigator.pushNamed(context, Routes.pay);},
                      color: StegosColors.splashBackground,
                      child: SvgPicture.asset('assets/images/send.svg'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Send',
                    style: TextStyle(fontSize: 12),
                  )
                ],
              ),
              const SizedBox(width: 75),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    width: 65,
                    height: 65,
                    child: RaisedButton(
                      padding: const EdgeInsets.all(10),
                      onPressed: () {},
                      color: StegosColors.splashBackground,
                      child: SvgPicture.asset('assets/images/red_packet.svg'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: 71,
                    child: const Text(
                      'Generate Red Packet',
                      style: TextStyle(fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      );

  void _seeAll() {
    Navigator.push(
        context,
        MaterialPageRoute<Null>(
          builder: (BuildContext context) => TransactionsScreen(transactions),
          fullscreenDialog: true,
        ));
  }
}
