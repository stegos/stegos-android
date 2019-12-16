import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:stegos_wallet/env_stegos.dart';
import 'package:stegos_wallet/ui/seed_phraze/seed_phraze.dart';
import 'package:stegos_wallet/ui/themes.dart';
import 'package:stegos_wallet/widgets/widget_app_bar.dart';
import 'package:stegos_wallet/widgets/widget_scaffold_body_wrapper.dart';

class AccountBackup extends StatefulWidget {
  AccountBackup({@required this.words});

  final List<String> words;

  @override
  State<StatefulWidget> createState() => _AccountBackupState();
}

class _AccountBackupState extends State<AccountBackup> {
  Map<int, String> writtenWords = List<String>.filled(24, '').asMap();

  bool isWritingPhrase = true;

  String get title => isWritingPhrase
      ? 'Please white down the phase in case to restore your account'
      : 'Please repeat your phrase to save it';

  @override
  Widget build(BuildContext context) {
    return Theme(
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
            onPressed: _onBack,
          ),
          title: const Text('Account backup'),
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
                            'All fields field are case sensitive ',
                            textAlign: TextAlign.center,
                            style: StegosThemes.defaultSubCaptionTextStyle,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                          child: SeedPhraze(
                        words: isWritingPhrase ? widget.words.asMap() : writtenWords,
                        onChanged: _onTextFieldChanged,
                        readOnly: isWritingPhrase,
                      )),
                    ),
                    SizedBox(width: double.infinity, height: 50, child: _buildRecoverButton())
                  ],
                )),
      ),
    );
  }

  void _onTextFieldChanged(int idx, String val) {
    writtenWords.update(idx, (v) => val);
  }

  Widget _buildRecoverButton() => RaisedButton(
            elevation: 8,
            disabledElevation: 8,
            onPressed: isWritingPhrase ? _written : _verify,
            child: Text(isWritingPhrase ? 'YES, I HAVE WRITTEN IT DOWN' : 'VERIFY'),
          );


  bool get _isValid {
    bool valid = true;
    widget.words.asMap().forEach((int key, String val) {
      if (writtenWords[key] != val) {
        valid = false;
      }
    });
    return valid;
  }

  void _written() {
    setState(() {
      isWritingPhrase = false;
    });
  }

  void _verify() {
    final env = Provider.of<StegosEnv>(context);
    if (_isValid) {
      Navigator.pop(context, true);
    } else {
      env.setError('Your phrase is incorrect. Please check it or return to previous step.');
    }
  }

  void _onBack() {
    if (!isWritingPhrase) {
      final env = Provider.of<StegosEnv>(context);
      env.resetError();
      setState(() {
        isWritingPhrase = true;
      });
    } else {
      Navigator.pop(context, false);
    }
  }
}
