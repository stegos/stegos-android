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
  static const _iconBackImage = AssetImage('assets/images/arrow_back.png');

  @override
  Widget build(BuildContext context) => Theme(
        data: StegosThemes.backupTheme,
        child: Scaffold(
          appBar: AppBarWidget(
            centerTitle: false,
            backgroundColor: Theme.of(context).colorScheme.primary,
            leading: IconButton(
              icon: SizedBox(
                width: 24,
                height: 24,
                child: Image(image: _iconBackImage),
              ),
              onPressed: () => Navigator.pop(context, false),
            ),
            title: const Text('Account back up'),
          ),
          body: Column(
            children: <Widget>[
              Padding(
                padding: StegosThemes.defaultPaddingHorizontal,
                child: Column(
                  children: <Widget>[
                    Text(
                      'Please white down the phase in case to restore your account',
                      textAlign: TextAlign.center,
                      style: StegosThemes.defaultCaptionTextStyle,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'The field is case sensitive',
                      textAlign: TextAlign.center,
                      style: StegosThemes.defaultSubCaptionTextStyle,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(child: _buildForm()),
              ),
              SizedBox(width: double.infinity, height: 50, child: _buildRestoreButton())
            ],
          ),
        ),
      );

  Widget _buildRestoreButton() => Observer(
      builder: (_) => RaisedButton(
            elevation: 8,
            disabledElevation: 8,
            onPressed: _store.valid ? _onRestore : null,
            child: const Text('VERIFY'),
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

  Widget _buildTextEntry(int idx, String text) => Stack(
        alignment: Alignment.centerLeft,
        children: <Widget>[
          Builder(
              builder: (context) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 13.0, vertical: 6.0),
                    child: Text(
                      '${idx + 1}.',
                      style: StegosThemes.defaultInputTextStyle,
                    ),
                  )),
          TextField(
            onChanged: (val) => _store.setKey(idx, val),
            style: StegosThemes.defaultInputTextStyle,
          )
        ],
      );

  void _onRestore() {
    // todo:
    print('On restore');
  }
}
