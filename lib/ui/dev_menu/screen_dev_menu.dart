import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:stegos_wallet/ui/themes.dart';
import 'package:stegos_wallet/widgets/widget_app_bar.dart';
import 'package:stegos_wallet/widgets/widget_scaffold_body_wrapper.dart';

class DevMenuScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _DevMenuScreenState();
}

class _DevMenuScreenState extends State<DevMenuScreen> {
  static const _iconBackImage = AssetImage('assets/images/arrow_back.png');

  @override
  Widget build(BuildContext context) => Theme(
        data: StegosThemes.baseTheme,
        child: Scaffold(
          appBar: AppBarWidget(
            centerTitle: false,
            backgroundColor: Theme.of(context).colorScheme.primary,
            leading: IconButton(
              icon: const SizedBox(
                width: 24,
                height: 24,
                child: Image(image: _iconBackImage),
              ),
              onPressed: () => Navigator.pop(context, false),
            ),
            title: const Text('Develop'),
          ),
          body: ScaffoldBodyWrapperWidget(
              builder: (context) => ListView(
                    children: <Widget>[
                      ListTile(
                        onTap: _showAddressDialog,
                        title: Text('Node address:'),
                        subtitle: Text('ws://10.0.2.2:2135'),
                      )
                    ],
                  )),
        ),
      );

  void _showAddressDialog() {
    showDialog(
        context: context,
        builder: (context) {
          var address = '';
          return AlertDialog(
            title: const Text('Node address'),
            content: TextField(
              onChanged: (text) {
                address = text;
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
                  print('create account $address');
                  _dismissDialog();
                },
                child: const Text('SAVE'),
              )
            ],
          );
        });
  }

  void _dismissDialog() => Navigator.pop(context);
}
