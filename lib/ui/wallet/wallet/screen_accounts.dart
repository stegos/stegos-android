import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:stegos_wallet/ui/themes.dart';
import 'package:stegos_wallet/widgets/reorderable_list.dart';

import 'account_card.dart';

class AccountsScreen extends StatefulWidget {
  AccountsScreen({Key key}) : super(key: key);

  @override
  AccountsScreenState createState() => AccountsScreenState();
}

class AccountsScreenState extends State<AccountsScreen> {
  final SvgPicture accountsIcon = SvgPicture.asset('assets/images/accounts.svg');

  final Image qrIcon =
      Image(image: const AssetImage('assets/images/qr.png'), width: 20, height: 20);
  List<Account> accountsList = <Account>[
    Account(name: 'Account 1', balance: 345, qrUrl: null, order: 0),
    Account(name: 'Account 2', balance: 126, qrUrl: null, order: 1),
    Account(name: 'Account 3', balance: 0.302, qrUrl: null, order: 2),
    Account(name: 'Account 4', balance: -11, qrUrl: null, order: 3),
  ];

  bool collapsed = false;

  Container _buildTotalBalanceContainer() => Container(
        height: 130,
        color: StegosColors.backgroundColor,
        child: Stack(children: [
          Container(
            alignment: Alignment.bottomCenter,
            padding: const EdgeInsets.only(bottom: 42),
            child: Container(
              width: double.infinity,
              color: StegosColors.splashBackground,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text('Total balance'),
                  const SizedBox(
                    height: 15,
                  ),
                  Text('0 STG', style: TextStyle(fontSize: 24, color: StegosColors.primaryColor))
                ],
              ),
            ),
          ),
          Container(
            alignment: Alignment.bottomLeft,
//            padding: const EdgeInsets.only(left: 15, bottom: 8),
            decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: StegosColors.primaryColorDark))),
            child: FlatButton(
              onPressed: () {
                setState(() {
                  collapsed = !collapsed;
                  print(collapsed);
                });
              },
              child: Row(
                children: <Widget>[
                  accountsIcon,
                  const SizedBox(width: 15),
                  const Text('Accounts'),
                ],
              ),
            ),
          ),
        ]),
      );

  void _settingModalBottomSheet(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) => Container(
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: <Widget>[
                  ListTile(
                    title: const Text(
                      'New account',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  ListTile(
                      leading: Icon(Icons.restore_page),
                      title: const Text('Recover account'),
                      onTap: () => {Navigator.pushNamed(context, '/restore')}),
                  ListTile(
                    leading: Icon(Icons.add),
                    title: const Text('Create new account'),
                    onTap: () => {_showMaterialDialog()},
                  ),
                ],
              ),
            ));
  }

  void _showMaterialDialog() {
    _dismissDialog();
    showDialog(
        context: context,
        builder: (context) {
          var accountName = '';
          return AlertDialog(
            title: const Text('New account'),
            content: TextField(
              onChanged: (text) {
                accountName = text;
              },
            ),
            actions: <Widget>[
              FlatButton(
                  onPressed: () {
                    print('cancel dialog');
                    _dismissDialog();
                  },
                  child: const Text('CANCEL')),
              FlatButton(
                onPressed: () {
                  print('create account $accountName');
                  _dismissDialog();
                },
                child: const Text('CREATE'),
              )
            ],
          );
        });
  }

  void _dismissDialog() => Navigator.pop(context);

  List<Widget> _accountsArray(List<Account> accounts) {
    final list = accounts
        .map<AccountCard>((item) => AccountCard(
              key: ValueKey(item),
              collapsed: collapsed,
              order: item.order,
            ))
        .toList();
    return list;
  }

  Widget _buildCollapsedCards() => ReorderableList(
      onReorder: (int oldIndex, int newIndex) {
        // These two lines are workarounds for ReorderableListView
        if (newIndex > accountsList.length) newIndex = accountsList.length;
        if (oldIndex < newIndex) newIndex--;
        setState(() {
          final Account item = accountsList[oldIndex];
          accountsList.remove(item);
          accountsList.insert(newIndex, item);
          accountsList.asMap().forEach((index, value) => value.order = index);
        });
      },
      padding: EdgeInsets.only(bottom: 80, top: collapsed ? 22 : 15, left: 30, right: 30),
      children: _accountsArray(accountsList));

  Widget _buildNormalCards() => ListView(
      padding: EdgeInsets.only(bottom: 80, top: collapsed ? 22 : 15, left: 30, right: 30),
      children: _accountsArray(accountsList));

  Widget _buildCards() => collapsed ? _buildCollapsedCards() : _buildNormalCards();

  @override
  Widget build(BuildContext context) => Theme(
        data: StegosThemes.accountsTheme,
        child: Scaffold(
          body: Stack(alignment: Alignment.topCenter, children: <Widget>[
            _buildTotalBalanceContainer(),
            Container(
                padding: const EdgeInsets.only(top: 130),
                child: _buildCards())

          ]),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              _settingModalBottomSheet(context);
            },
            child: Icon(Icons.add),
          ),
        ),
      );
}
