import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:stegos_wallet/ui/themes.dart';
import 'package:stegos_wallet/widgets/widget_app_bar.dart';

class Transaction {
  Transaction({this.amount = 0, this.created, this.certificateURL});

  final int amount;
  final DateTime created;
  final String certificateURL;
}

class AccountScreen extends StatefulWidget {
  AccountScreen({Key key}) : super(key: key);

  @override
  AccountScreenState createState() => AccountScreenState();
}

class AccountScreenState extends State<AccountScreen> {
  static const _iconBackImage = AssetImage('assets/images/arrow_back.png');
  static final txTowDateFormatter = DateFormat('yyyy-MM-dd');

  final EdgeInsets defaultPadding = const EdgeInsets.all(16.0);

  final List<Transaction> transactions = [
    Transaction(amount: 10, created: DateTime.now(), certificateURL: 'URL to certificate document'),
    Transaction(amount: -10, created: DateTime.now(), certificateURL: null)
  ];

  Widget _buildTransactionRow(Transaction transaction) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
            height: 54,
            decoration:
                const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xff979797)))),
            child: Row(
              children: <Widget>[
                SizedBox(
                  width: 17,
                  height: 5,
                  child: Transform.scale(
                    scale: transaction.amount.sign.toDouble(),
                    child: const Image(image: AssetImage('assets/images/down.png')),
                  ),
                ),
                Expanded(
                    child: Text(
                  txTowDateFormatter.format(transaction.created),
                  style: const TextStyle(fontSize: 18, color: Color(0xff676767)),
                )),
                Text(
                  '${transaction.amount.abs().toString()} STG',
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
                const SizedBox(width: 15),
                SizedBox(
                  width: 24,
                  height: 24,
                  child: transaction.certificateURL != null
                      ? const Image(image: AssetImage('assets/images/transactions.png'))
                      : null,
                )
              ],
            )),
      );

  Widget _buildTransactionsList() {
    if (transactions.isEmpty) {
      return Container(
        padding: const EdgeInsets.only(top: 53),
        child: const Text(
          'There has been no transaction yet',
          style: TextStyle(fontSize: 14),
        ),
      );
    } else {
      return ListView(
        children: transactions.map(_buildTransactionRow).toList(),
      );
    }
  }

  @override
  Widget build(BuildContext context) => Theme(
      data: StegosThemes.backupTheme,
      child: Scaffold(
        appBar: AppBarWidget(
          centerTitle: false,
          backgroundColor: Theme.of(context).colorScheme.primary,
          leading: IconButton(
            icon: const SizedBox(
              width: 24,
              height: 24,
              child: Image(image: _iconBackImage),
            ),
            onPressed: () => Navigator.pop(context, false),
          ),
          title: const Text('Account 1'),
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
                          const Text('0 STG',
                              style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w500,
                                  color: StegosColors.primaryColor)),
                          const SizedBox(height: 26),
                          Container(
                              height: 40,
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 20).copyWith(bottom: 67),
                              decoration: BoxDecoration(
                                border:
                                    Border(bottom: BorderSide(color: StegosColors.white, width: 1)),
                              ),
                              child: const Center(
                                  child: SelectableText(
                                      '0xf7da9EFFF07539840CF329B71De910ecc7447e41',
                                      style: TextStyle(fontSize: 10)))),
                          Container(
                            height: 165,
                            padding: const EdgeInsets.symmetric(vertical: 30),
                            color: StegosColors.backgroundColor,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                                        onPressed: () {},
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
                          )
                        ],
                      ))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: Color(0xff979797)))),
              )
            ]),
            Expanded(
              child: _buildTransactionsList(),
            )
          ],
        ),
      ));
}
