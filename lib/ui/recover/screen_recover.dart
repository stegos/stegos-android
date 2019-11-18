import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:stegos_wallet/ui/recover/store_recover_screen.dart';
import 'package:stegos_wallet/ui/themes.dart';
import 'package:stegos_wallet/widgets/widget_app_bar.dart';

class RecoverScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _RecoverScreenState();
}

class _RecoverScreenState extends State<RecoverScreen> {
  final _store = RecoverScreenStore(24);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBarWidget(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context, false),
          ),
          title: const Text('Restore account'),
        ),
        body: Column(
          children: <Widget>[
            Padding(
              padding: StegosThemes.defaultPadding,
              child: Text(
                'In order to restore your existing account, please fill all '
                'words from the recovery phrase in correct order.',
                textAlign: TextAlign.center,
                style: StegosThemes.defaultCaptionTextStyle,
              ),
            ),
            Expanded(
              child: SingleChildScrollView(child: _buildForm()),
            ),
            SizedBox(
                width: double.infinity,
                child: Padding(padding: StegosThemes.defaultPadding, child: _buildRestoreButton()))
          ],
        ),
      );

  Widget _buildRestoreButton() => Observer(
      builder: (_) => RaisedButton(
            onPressed: _store.valid ? _onRestore : null,
            child: const Text('RESTORE'),
          ));

  Widget _buildForm() => Form(
        child: Column(
          children: _store.keys
              .asMap()
              .entries
              .map((e) => Container(
                    height: 65,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildTextEntry(e.key, e.value),
                  ))
              .toList(),
        ),
      );

  Widget _buildTextEntry(int idx, String text) => TextField(
        onChanged: (val) => _store.setKey(idx, val),
        decoration:
            InputDecoration(icon: Container(width: 24, child: Text('${idx + 1}.')), hintText: ''),
      );

  void _onRestore() {
    // todo:
    print('On restore');
  }
}
