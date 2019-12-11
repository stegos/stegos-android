import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:stegos_wallet/services/service_node.dart';
import 'package:stegos_wallet/ui/themes.dart';
import 'package:stegos_wallet/widgets/widget_app_bar.dart';

class TransactionDataScreeen extends StatefulWidget {

  TransactionDataScreeen({@required this.transaction});

  final TxStore transaction;

  @override
  _TransactionDataScreeenState createState() => _TransactionDataScreeenState();
}

class _TransactionDataScreeenState extends State<TransactionDataScreeen> {

  final EdgeInsets defaultPadding = const EdgeInsets.all(16.0);

  @override
  Widget build(BuildContext context) {
    final TxStore tx = widget.transaction;
    return Theme(
        data: StegosThemes.AccountTheme,
        child: Scaffold(
          appBar: AppBarWidget(
            centerTitle: false,
            backgroundColor: Theme.of(context).colorScheme.primary,
            leading: IconButton(
              icon: const Image(
                image: AssetImage('assets/images/arrow_back.png'),
                width: 24,
                height: 24,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              )
            ],
            title: const Text('Transaction'),
          ),
          body: Column(
            children: <Widget>[
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Container(
                    child: Container(
                        padding: const EdgeInsets.only(top: 15),
                        color: StegosColors.splashBackground,
                        child: Column(
                          children: <Widget>[
                            Container(
                              padding: const EdgeInsets.only(left: 15, right: 15),
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(tx.humanCreationTime, style: const TextStyle(fontSize: 14)),
                                    Text(tx.humanStatus,  style: const TextStyle(fontSize: 14)),
                                  ]),
                            ),
                            const SizedBox(height: 34),
                            Text('${tx.humanAmount} STG', style: const TextStyle(fontSize: 32)),
                            const SizedBox(height: 22),
                          ],
                        ))),
              ]),
              Expanded(
                child: Stack(
                  children: <Widget>[
                    SingleChildScrollView(
                        padding: const EdgeInsets.only(top: 57, left: 30, right: 30),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            _buildTxValue('Comment', tx.comment),
                            const SizedBox(height: 10),
                            _buildTxValue('Hash', tx.hash),
                            const SizedBox(height: 10),
                          ],
                        ))
                  ],
                ),
              )
            ],
          ),
        ));
  }

  Widget _buildTxValue(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
          border: Border(bottom: BorderSide(width: 1, color: StegosColors.white.withOpacity(0.5)))
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(label, style: TextStyle(fontSize: 12, color: StegosColors.white.withOpacity(0.54)),),
          const SizedBox(height: 10),
          SelectableText(value, style: TextStyle(fontSize: 12, color: StegosColors.white.withOpacity(0.87))),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
