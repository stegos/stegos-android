import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Transaction {
  Transaction({this.amount = 0, this.created, this.certificateURL});

  final int amount;
  final DateTime created;
  final String certificateURL;
}

class AccountScreen extends StatefulWidget {
  AccountScreen({Key key}) : super(key: key);

  final title = 'Account 1';

  @override
  AccountScreenState createState() => AccountScreenState();
}

class AccountScreenState extends State<AccountScreen> {
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
  Widget build(BuildContext context) => Column(
        children: <Widget>[
          Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Container(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 30),
                    child: Column(
                      children: <Widget>[
                        const Image(
                          image: AssetImage('assets/images/qr.png'),
                          width: 38,
                          height: 38,
                        ),
                        const SizedBox(height: 18),
                        Text('Balance', style: TextStyle(fontSize: 16)),
                        const SizedBox(height: 11),
                        Text('0 STG', style: TextStyle(fontSize: 20)),
                        const SizedBox(height: 37),
                        Container(
                            height: 40,
                            decoration: BoxDecoration(
                                border: Border.all(color: const Color(0xffeaeaea)),
                                borderRadius: BorderRadius.circular(20)),
                            child: Center(
                                child: SelectableText('0xf7da9EFFF07539840CF329B71De910ecc7447e41',
                                    style: TextStyle(fontSize: 10)))),
                        Container(
                          height: 100,
                          padding: const EdgeInsets.only(top: 30),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              Expanded(
                                child: FlatButton(
                                  onPressed: () {
                                    print('send');
                                  },
                                  color: const Color(0xffececec),
                                  child: Text(
                                    'Send',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: const Color(0xff656565)),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 13),
                              Expanded(
                                child: FlatButton(
                                  onPressed: () {
                                    print('create red packet');
                                  },
                                  color: const Color(0xffececec),
                                  child: Text(
                                    'Create Red Packet',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: const Color(0xff656565)),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    ))),
            Container(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: const Color(0xff979797)))),
                child: Text(
                  'Transactions',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18, color: const Color(0xff656565)),
                ))
          ]),
          Expanded(
            child: _buildTransactionsList(),
          )
        ],
      );
}
