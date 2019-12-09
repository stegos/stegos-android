import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:stegos_wallet/ui/account/screen_account.dart';
import 'package:stegos_wallet/ui/certificate/screen_certificate.dart';
import 'package:stegos_wallet/ui/themes.dart';

class TransactionsList extends StatefulWidget {
  TransactionsList([this.transactions]);

  final List<Transaction> transactions;

  final txTowDateFormatter = DateFormat('yyyy-MM-dd hh:mm:ss');

  @override
  _TransactionsListState createState() => _TransactionsListState();
}

class _TransactionsListState extends State<TransactionsList> with TickerProviderStateMixin {
  AnimationController rotationController;

  @override
  void initState() {
    rotationController = AnimationController(duration: const Duration(seconds: 20), vsync: this);
    rotationController.repeat();
    super.initState();
  }

  @override
  Widget build(BuildContext context) => Theme(
        data: StegosThemes.AccountTheme,
        child: Container(
          alignment: Alignment.topCenter,
          child: widget.transactions.isEmpty
              ? const Text(
                  'There were no transactions yet',
                  style: TextStyle(fontSize: 14),
                  textAlign: TextAlign.center,
                )
              : ListView(
                  children: widget.transactions.map(_buildTransactionRow).toList(),
                ),
        ),
      );

  Widget _buildTransactionRow(Transaction transaction) => Padding(
        padding: const EdgeInsets.only(left: 20, right: 10, top: 25, bottom: 25),
        child: Container(
            height: 39,
            child: Stack(
              children: <Widget>[
                Container(
                    alignment: Alignment.topLeft,
                    child: Row(
                      children: <Widget>[
                        Padding(
                            padding: const EdgeInsets.only(right: 5),
                            child: transaction.finished
                                ? Icon(Icons.check, size: 16, color: const Color(0xff32ff6b))
                                : RotationTransition(
                                    turns:
                                        Tween(begin: 0.0, end: 2 * pi).animate(rotationController),
                                    child: Icon(Icons.autorenew,
                                        size: 16, color: StegosColors.accentColor))),
                        Text(
                          transaction.amount > 0 ? 'Received' : 'Sent',
                          style: const TextStyle(fontSize: 16, color: StegosColors.white),
                        )
                      ],
                    )),
                Container(
                    alignment: Alignment.bottomLeft,
                    child: Text(
                      widget.txTowDateFormatter.format(transaction.created),
                      style: const TextStyle(fontSize: 12, color: StegosColors.white),
                    )),
                Container(
                  alignment: Alignment.topRight,
                  margin: const EdgeInsets.only(right: 54),
                  child: Text(
                    '${transaction.amount.toString()} STG',
                    style: TextStyle(
                        fontSize: 16,
                        color: transaction.amount > 0 ? const Color(0xff32ff6b) : Colors.white),
                  ),
                ),
                Container(
                  alignment: Alignment.topRight,
                  child: transaction.certificateURL != null
                      ? InkResponse(
                          onTap: _openCertificate,
                          child: SvgPicture.asset(
                            'assets/images/certificate.svg',
                            width: 24,
                            height: 24,
                          ),
                        )
                      : null,
                )
              ],
            )),
      );

  void _openCertificate() {
    Navigator.push(
        context,
        MaterialPageRoute<Null>(
          builder: (BuildContext context) => CertificateScreen(),
          fullscreenDialog: true,
        ));
  }
}
