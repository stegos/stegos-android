import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pedantic/pedantic.dart';
import 'package:provider/provider.dart';
import 'package:stegos_wallet/env_stegos.dart';
import 'package:stegos_wallet/log/loggable.dart';
import 'package:stegos_wallet/ui/routes.dart';
import 'package:stegos_wallet/ui/themes.dart';
import 'package:stegos_wallet/ui/wallet/wallet/account_card.dart';
import 'package:stegos_wallet/widgets/reorderable_list.dart';
import 'package:stegos_wallet/widgets/widget_scaffold_body_wrapper.dart';

class AccountsScreen extends StatefulWidget {
  AccountsScreen({Key key}) : super(key: key);

  @override
  AccountsScreenState createState() => AccountsScreenState();
}

class AccountsScreenState extends State<AccountsScreen> with Loggable<AccountsScreenState> {
  bool collapsed = false;

  @override
  Widget build(BuildContext context) => Theme(
        data: StegosThemes.accountsTheme,
        child: Scaffold(
          body: ScaffoldBodyWrapperWidget(
            builder: (context) => Stack(alignment: Alignment.topCenter, children: <Widget>[
              Observer(builder: _buildAccountsHeader),
              Container(
                  padding: const EdgeInsets.only(top: 130),
                  child: Observer(builder: _buildAccountsList))
            ]),
          ),
          floatingActionButton: _buildFloatingActionButton(context),
        ),
      );

  Widget _buildFloatingActionButton(BuildContext context) => FloatingActionButton(
        onPressed: () {
          _settingModalBottomSheet(context);
        },
        child: Icon(Icons.add),
      );

  Widget _buildAccountsHeader(BuildContext context) {
    final env = Provider.of<StegosEnv>(context);
    final node = env.nodeService;
    return Container(
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
                Text('${node.totalBalance} STG',
                    style: TextStyle(fontSize: 24, color: StegosColors.primaryColor))
              ],
            ),
          ),
        ),
        Container(
          alignment: Alignment.bottomLeft,
          decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: StegosColors.primaryColorDark))),
          child: FlatButton(
            onPressed: () {
              setState(() {
                collapsed = !collapsed;
              });
            },
            child: Row(
              children: <Widget>[
                SvgPicture.asset('assets/images/accounts.svg'),
                const SizedBox(width: 15),
                const Text('Accounts'),
              ],
            ),
          ),
        ),
      ]),
    );
  }

  List<Widget> _accountsArray() {
    final env = Provider.of<StegosEnv>(context);
    return env.nodeService.accountsList
        .map((acc) => AccountCard(key: ValueKey(acc), collapsed: collapsed))
        .toList();
  }

  Widget _buildCollapsedAccountsList(BuildContext context) {
    final env = Provider.of<StegosEnv>(context);
    return ReorderableList(
        onReorder: (int oldIndex, int newIndex) {
          final alist = env.nodeService.accountsList;
          // These two lines are workarounds for ReorderableListView
          // todo: review
          if (newIndex > alist.length) newIndex = alist.length;
          if (oldIndex < newIndex) newIndex--;
          unawaited(
              env.nodeService.swapAccounts(oldIndex, newIndex).catchError((err, StackTrace st) {
            log.severe('Failed to reorder accounts: ', err, st);
          }));
        },
        padding: EdgeInsets.only(bottom: 80, top: collapsed ? 22 : 15, left: 30, right: 30),
        children: _accountsArray());
  }

  Widget _buildExpandedAccountsList(BuildContext context) => ListView(
      padding: EdgeInsets.only(bottom: 80, top: collapsed ? 22 : 15, left: 30, right: 30),
      children: _accountsArray());

  Widget _buildAccountsList(BuildContext context) =>
      collapsed ? _buildCollapsedAccountsList(context) : _buildExpandedAccountsList(context);

  // todo:
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

  void _settingModalBottomSheet(BuildContext context) {
    showModalBottomSheet(
        backgroundColor: StegosColors.backgroundColor,
        context: context,
        builder: (BuildContext bc) => Container(
              height: 211,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Text(
                    'New Account',
                    style: TextStyle(color: StegosColors.primaryColor, fontSize: 18),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(
                            width: 65,
                            height: 65,
                            child: RaisedButton(
                              onPressed: () {
                                Navigator.pushNamed(context, Routes.recover);
                              },
                              color: StegosColors.splashBackground,
                              child: SvgPicture.asset('assets/images/restore_account.svg'),
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Restore account',
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
                              onPressed: _showMaterialDialog,
                              color: StegosColors.splashBackground,
                              child: SvgPicture.asset('assets/images/create_account.svg'),
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Create new account',
                            style: TextStyle(fontSize: 12),
                          )
                        ],
                      )
                    ],
                  ),
                ],
              ),
            ));
  }
}
