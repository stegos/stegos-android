import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:stegos_wallet/ui/recover/store_screen_recover.dart';
import 'package:stegos_wallet/ui/seed_phraze/seed_phraze.dart';
import 'package:stegos_wallet/ui/themes.dart';
import 'package:stegos_wallet/widgets/widget_app_bar.dart';
import 'package:stegos_wallet/widgets/widget_scaffold_body_wrapper.dart';

class AccountBackup extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AccountBackupState();
}

class _AccountBackupState extends State<AccountBackup> {
  final _store = RecoverScreenStore(24);

  bool isWritingPhrase = true;

  String get title => isWritingPhrase
      ? 'Please white down the phase in case to restore your account'
      : 'Please repeat your phrase to save it';

  @override
  Widget build(BuildContext context) => Theme(
        data: StegosThemes.backupTheme,
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
            title: const Text('Account back up'),
          ),
          body: ScaffoldBodyWrapperWidget(
              builder: (context) => Column(
                    children: <Widget>[
                      Padding(
                        padding: StegosThemes.defaultPaddingHorizontal,
                        child: Column(
                          children: <Widget>[
                            Text(
                              title,
                              textAlign: TextAlign.center,
                              style: StegosThemes.defaultCaptionTextStyle,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'The field is case sensitive ',
                              textAlign: TextAlign.center,
                              style: StegosThemes.defaultSubCaptionTextStyle,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                            child: SeedPhraze(
                          words: _store.keys.asMap().entries.toList(),
                          onChanged: _onTextFieldChanged,
                          readOnly: isWritingPhrase,
                        )),
                      ),
                      SizedBox(width: double.infinity, height: 50, child: _buildRecoverButton())
                    ],
                  )),
        ),
      );

  void _onTextFieldChanged(int idx, String val) {
    _store.setKey(idx, val);
  }

  Widget _buildRecoverButton() => Observer(
      builder: (context) => RaisedButton(
            elevation: 8,
            disabledElevation: 8,
            onPressed: isWritingPhrase ? _written : _store.valid ? _verify : null,
            child: Text(isWritingPhrase ? 'YES, I HAVE WRITTEN IT DOWN' : 'VERIFY'),
          ));

  void _written() {
    setState(() {
      isWritingPhrase = false;
      _store.clearKeys();
    });
  }

  void _verify() {
    print('VERIFY');
  }
}
