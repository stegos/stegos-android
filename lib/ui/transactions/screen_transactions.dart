import 'package:flutter/material.dart';
import 'package:stegos_wallet/services/service_node.dart';
import 'package:stegos_wallet/ui/app.dart';
import 'package:stegos_wallet/ui/themes.dart';
import 'package:stegos_wallet/ui/transactions/transactions_list.dart';
import 'package:stegos_wallet/widgets/widget_app_bar.dart';
import 'package:stegos_wallet/widgets/widget_scaffold_body_wrapper.dart';

class TransactionsScreen extends StatelessWidget {
  TransactionsScreen({Key key, @required this.account}) : super(key: key);

  final AccountStore account;

  @override
  Widget build(BuildContext context) => Theme(
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
              onPressed: () => StegosApp.navigatorState.pop(),
            ),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.close),
                onPressed: () => StegosApp.navigatorState.pop(),
              )
            ],
            title: const Text('Transactions'),
          ),
          body: ScaffoldBodyWrapperWidget(builder: (context) => TransactionsList(account))));
}
