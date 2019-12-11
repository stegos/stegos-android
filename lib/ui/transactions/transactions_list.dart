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

  Widget _buildTransactionRow(TxStore transaction) {
    Widget prefixIcon;
    if (transaction.finished) {
      prefixIcon = Icon(Icons.check, size: 16, color: const Color(0xff32ff6b));
    } else if (transaction.pending) {
      prefixIcon = RotationTransition(
          turns: Tween(begin: 0.0, end: 2 * pi).animate(_rotationController),
          child: Icon(Icons.autorenew, size: 16, color: StegosColors.accentColor));
    } else if (transaction.failed) {
      prefixIcon = Icon(Icons.error_outline, size: 16, color: Colors.redAccent);
    }

    return InkWell(
      onTap: () => _openTxDetails(transaction),
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
                          transaction.send ? 'Sent' : 'Received',
                          style: const TextStyle(fontSize: 16, color: StegosColors.white),
                        )
                      ],
                    )),
                Container(
                    alignment: Alignment.bottomLeft,
                    child: Text(
                      transaction.humanCreationTime,
                      style: const TextStyle(fontSize: 12, color: StegosColors.white),
                    )),
                Container(
                  alignment: Alignment.topRight,
                  margin: const EdgeInsets.only(right: 54),
                  child: Text(
                    '${transaction.humanAmount} STG',
                    style: TextStyle(
                        fontSize: 16,
                        color: !transaction.send ? const Color(0xff32ff6b) : Colors.white),
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
      ),
    );
  }

  void _openCertificate() {
    StegosApp.navigatorState.push(MaterialPageRoute(
      builder: (BuildContext context) => CertificateScreen(),
      fullscreenDialog: true,
    ));
  }

  Future<String> _openTxDetails(TxStore transaction) {
    return StegosApp.navigatorState.push(MaterialPageRoute(
      builder: (BuildContext context) => TransactionDataScreeen(
        transaction: transaction,
      ),
      fullscreenDialog: true,
    ));
  }
}
