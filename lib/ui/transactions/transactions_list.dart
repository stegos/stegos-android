import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_svg/svg.dart';
import 'package:stegos_wallet/services/service_node.dart';
import 'package:stegos_wallet/ui/app.dart';
import 'package:stegos_wallet/ui/certificate/screen_certificate.dart';
import 'package:stegos_wallet/ui/themes.dart';
import 'package:stegos_wallet/ui/transaction-data/transaction_data.dart';

class TransactionsList extends StatefulWidget {
  TransactionsList(this.account);

  final AccountStore account;

  @override
  _TransactionsListState createState() => _TransactionsListState();
}

class _TransactionsListState extends State<TransactionsList> with TickerProviderStateMixin {
  AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(duration: const Duration(seconds: 20), vsync: this);
    _rotationController.repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Theme(
        data: StegosThemes.AccountTheme,
        child: Container(
          alignment: Alignment.topCenter,
          child: Observer(
            builder: (context) {
              return widget.account.txList.isEmpty
                  ? const Text('No transactions yet',
                      style: TextStyle(fontSize: 14), textAlign: TextAlign.center)
                  : ListView(children: widget.account.txList.map(_buildTransactionRow).toList());
            },
          ),
        ),
      );

  Widget _buildTransactionRow(TxStore tx) {
    Widget prefixIcon;
    if (tx.failed) {
      prefixIcon = Icon(Icons.error_outline, size: 16, color: Colors.redAccent);
    } else if (tx.pending) {
      prefixIcon = RotationTransition(
          turns: Tween(begin: 0.0, end: 2 * pi).animate(_rotationController),
          child: Icon(Icons.autorenew, size: 16, color: StegosColors.accentColor));
    } else {
      prefixIcon = Icon(Icons.check, size: 16, color: const Color(0xff32ff6b));
    }
    return InkWell(
      onTap: () => _openTxDetails(tx),
      child: Padding(
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
                          child: prefixIcon,
                        ),
                        Text(
                          tx.humanStatus,
                          style: const TextStyle(fontSize: 16, color: StegosColors.white),
                        )
                      ],
                    )),
                Container(
                    alignment: Alignment.bottomLeft,
                    child: Text(
                      tx.humanCreationTime,
                      style: const TextStyle(fontSize: 12, color: StegosColors.white),
                    )),
                Container(
                  alignment: Alignment.topRight,
                  margin: const EdgeInsets.only(right: 54),
                  child: Text(
                    '${tx.humanAmount} STG',
                    style: TextStyle(
                        fontSize: 16, color: !tx.send ? const Color(0xff32ff6b) : Colors.white),
                  ),
                ),
                Container(
                  alignment: Alignment.topRight,
                  child: tx.hasCert
                      ? InkResponse(
                          onTap: () => _openCertificate(tx),
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
      ),
    );
  }

  void _openCertificate(TxStore tx) {
    StegosApp.navigatorState.push(MaterialPageRoute(
      builder: (BuildContext context) => CertificateScreen(transaction: tx),
    ));
  }

  Future<String> _openTxDetails(TxStore tx) {
    return StegosApp.navigatorState.push(MaterialPageRoute(
      builder: (BuildContext context) => TransactionDataScreeen(
        transaction: tx,
      ),
    ));
  }
}
