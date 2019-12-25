import 'package:flutter/material.dart';
import 'package:pedantic/pedantic.dart';
import 'package:provider/provider.dart';
import 'package:stegos_wallet/env_stegos.dart';
import 'package:stegos_wallet/services/service_node.dart';
import 'package:stegos_wallet/ui/themes.dart';
import 'package:stegos_wallet/utils/dialogs.dart';

class SelectAccount extends StatefulWidget {
  const SelectAccount({Key key, this.onAccountSelected}) : super(key: key);

  final void Function(AccountStore) onAccountSelected;

  @override
  _SelectAccountState createState() => _SelectAccountState();
}

class _SelectAccountState extends State<SelectAccount> {
  int _currrentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final env = Provider.of<StegosEnv>(context);
    final alist = env.nodeService.accountsList;
    return Stack(
      children: <Widget>[
        ListView.builder(
          itemBuilder: (BuildContext context, int index) {
            if (index == alist.length) {
              return Container(
                padding: const EdgeInsets.only(top: 60, left: 10),
                alignment: Alignment.centerLeft,
                child: FlatButton.icon(
                    onPressed: _showCreateNewAccountDialog,
                    icon: Icon(
                      Icons.add,
                      color: StegosColors.accentColor,
                    ),
                    label: const Text(
                      'Create new account',
                      style: TextStyle(fontSize: 18),
                    )),
              );
            }
            if (index > alist.length) {
              return null;
            }
            return RadioListTile(
              onChanged: (value) {
                setState(() {
                  _currrentIndex = index;
                  if (widget.onAccountSelected != null) {
                    widget.onAccountSelected(alist[_currrentIndex]);
                  }
                });
              },
              groupValue: alist[_currrentIndex],
              value: alist[index],
              selected: _currrentIndex == index,
              title: Text(alist[index].humanName),
              secondary: Text(
                '${alist[index].humanBalance} STG',
                style: const TextStyle(fontSize: 14),
              ),
            );
          },
        ),
      ],
    );
  }

  void _showCreateNewAccountDialog() {
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
}
