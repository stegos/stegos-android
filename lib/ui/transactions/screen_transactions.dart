import 'package:flutter/material.dart';
import 'package:stegos_wallet/ui/account/screen_account.dart';
import 'package:stegos_wallet/ui/account/transactions_list.dart';
import 'package:stegos_wallet/ui/themes.dart';
import 'package:stegos_wallet/widgets/widget_app_bar.dart';

class TransactionsScreen extends StatefulWidget {
  TransactionsScreen([this.transactions]);

  final List<Transaction> transactions;

  @override
  _TransactionsScreenState createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  static const _iconBackImage = AssetImage('assets/images/arrow_back.png');

  @override
  Widget build(BuildContext context) => Theme(
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
              onPressed: () => Navigator.pop(context),
            ),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              )
            ],
            title: const Text('Transactions'),
          ),
          body: TransactionsList(widget.transactions)));
}
