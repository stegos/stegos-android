import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pedantic/pedantic.dart';
import 'package:provider/provider.dart';
import 'package:stegos_wallet/env_stegos.dart';
import 'package:stegos_wallet/log/loggable.dart';
import 'package:stegos_wallet/services/service_node.dart';
import 'package:stegos_wallet/ui/app.dart';
import 'package:stegos_wallet/ui/routes.dart';
import 'package:stegos_wallet/ui/themes.dart';
import 'package:stegos_wallet/ui/wallet/wallet/account_card.dart';
import 'package:stegos_wallet/utils/dialogs.dart';
import 'package:stegos_wallet/widgets/reorderable_list.dart';
import 'package:stegos_wallet/widgets/widget_scaffold_body_wrapper.dart';

class AccountsScreen extends StatefulWidget {
  AccountsScreen({Key key}) : super(key: key);

  @override
  AccountsScreenState createState() => AccountsScreenState();
}

class AccountsScreenState extends State<AccountsScreen>
    with Loggable<AccountsScreenState>, TickerProviderStateMixin {
  AccountsScreenState() {
    animationController =
        AnimationController(duration: const Duration(milliseconds: 700), vsync: this);
  }

  AnimationController animationController;
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

  Widget _buildFloatingActionButton(BuildContext context) => Observer(builder: (context) {
        final env = Provider.of<StegosEnv>(context);
        if (!env.nodeService.operable) {
          return const SizedBox.shrink();
        }
        return FloatingActionButton(
          onPressed: env.nodeService.operable
              ? () {
                  _settingModalBottomSheet(context);
                }
              : null,
          child: Icon(Icons.add),
        );
      });

  Widget _buildAccountsHeader(BuildContext context) {
    final env = Provider.of<StegosEnv>(context);
    final node = env.nodeService;
    return Container(
      height: 130,
      color: StegosColors.backgroundColor,
      child: Stack(children: [
        Container(
          alignment: Alignment.bottomCenter,
          padding: const EdgeInsets.only(bottom: 48),
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
          alignment: Alignment.bottomCenter,
          decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: StegosColors.primaryColorDark))),
          child: FlatButton(
            onPressed: () {
              setState(() {
                collapsed = !collapsed;
              });
            },
            shape: Border.all(color: Colors.transparent, width: 0),
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
    int index = 0;
    return env.nodeService.accountsList.map((acc) {
      final ValueKey<AccountStore> key = ValueKey(acc);
      return Listener(
          key: key,
          onPointerMove: (PointerMoveEvent event) {
            final double size = MediaQuery.of(context).size.width - 60;
            animationController.value = 1 - (event.position.dx / size);
          },
          child: Dismissible(
            key: key,
            onDismissed: (DismissDirection direction) {
              if (direction == DismissDirection.endToStart) {
                _onDeleteAccount(acc, index++);
              }
            },
            direction: DismissDirection.endToStart,
            confirmDismiss: (DismissDirection direction) => _confirmDeleting(acc),
            background: FadeTransition(
              opacity: animationController,
              child: Container(
                margin: EdgeInsets.symmetric(vertical: (collapsed ? 4 : 15) + 3.0, horizontal: 3.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3.0),
                  color: StegosColors.splashBackground.withOpacity(0.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    const Text(
                      'Delete',
                    ),
                    const SizedBox(width: 10),
                    Icon(Icons.delete_forever),
                    const SizedBox(width: 25),
                  ],
                ),
              ),
            ),
            child: AccountCard(key: key, collapsed: collapsed),
          ));
    }).toList();
  }

  Future<bool> _confirmDeleting(AccountStore account) => appShowDialog<bool>(
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Delete account ${account.humanName}?'),
            content: const Text('Please make an account backup if you with to restore it later.'),
            actions: <Widget>[
              FlatButton(
                onPressed: () {
                  StegosApp.navigatorState.pop(false);
                },
                child: const Text('CANCEL'),
              ),
              FlatButton(
                onPressed: () {
                  StegosApp.navigatorState.pop(true);
                  final env = Provider.of<StegosEnv>(context);
                  env.nodeService.deleteAccount(account);
                },
                child: const Text('DELETE'),
              )
            ],
          );
        },
      );

  void _onDeleteAccount(AccountStore account, int index) {
    Scaffold.of(context).removeCurrentSnackBar();
    Scaffold.of(context).showSnackBar(SnackBar(
      content: Text('${account.humanName} was removed!'),
      duration: const Duration(seconds: 2),
    ));
  }

  Widget _buildCollapsedAccountsList() {
    final env = Provider.of<StegosEnv>(context);
    return ReorderableList(
        onReorder: (int oldIndex, int newIndex) {
          final alist = env.nodeService.accountsList;
          // These two lines are workarounds for ReorderableListView
          if (newIndex > alist.length) newIndex = alist.length;
          if (oldIndex < newIndex) newIndex--;
          unawaited(
              env.nodeService.swapAccounts(oldIndex, newIndex).catchError((err, StackTrace st) {
            log.warning('Failed to reorder accounts: ', err, st);
          }));
        },
        padding: EdgeInsets.only(bottom: 80, top: collapsed ? 22 : 15, left: 30, right: 30),
        children: _accountsArray());
  }

  Widget _buildExpandedAccountsList() => ListView(
      padding: EdgeInsets.only(bottom: 80, top: collapsed ? 22 : 15, left: 30, right: 30),
      children: _accountsArray());

  Widget _buildAccountsList(BuildContext context) =>
      collapsed ? _buildCollapsedAccountsList() : _buildExpandedAccountsList();

  void _showCreateNewAccountDialog() {
    _dismissDialog();
    appShowDialog(builder: (context) {
      var accountName = '';
      return AlertDialog(
        title: const Text('New account'),
        content: TextField(
          onChanged: (text) {
            accountName = text;
          },
        ),
        actions: <Widget>[
          FlatButton(onPressed: _dismissDialog, child: const Text('CANCEL')),
          FlatButton(
            onPressed: () {
              final env = Provider.of<StegosEnv>(context);
              _dismissDialog();
              unawaited(Future(() => env.nodeService.createNewAccount(accountName))
                  .catchError(defaultErrorHandler(env)));
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
                              onPressed: _showCreateNewAccountDialog,
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
