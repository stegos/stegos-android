import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:stegos_wallet/ui/themes.dart';
import 'package:stegos_wallet/widgets/widget_app_bar.dart';
import 'package:stegos_wallet/widgets/widget_scaffold_body_wrapper.dart';

class PasswordScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _PasswordScreenState();
}

class _PasswordScreenState extends State<PasswordScreen> {
  static const _iconBackImage = AssetImage('assets/images/arrow_back.png');

  @override
  Widget build(BuildContext context) => Theme(
        data: StegosThemes.passwordTheme,
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
            title: const Text('Account #1'),
          ),
          body: ScaffoldBodyWrapperWidget(
              builder: (context) => Column(
                    children: <Widget>[
                      Padding(
                        padding: StegosThemes.defaultPaddingHorizontal,
                        child: Column(
                          children: <Widget>[
                            Text(
                              'It seems what Account #1 is locked by different password.',
                              textAlign: TextAlign.center,
                              style: StegosThemes.defaultCaptionTextStyle,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Please provide password to unlock:',
                              textAlign: TextAlign.center,
                              style: StegosThemes.defaultSubCaptionTextStyle,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 30),
                            child: TextField(
                              onChanged: (val) => {},
                              style: StegosThemes.defaultInputTextStyle,
                              obscureText: true,
                            )),
                      ),
                      SizedBox(width: double.infinity, height: 50, child: _buildSubmitButton())
                    ],
                  )),
        ),
      );

  Widget _buildSubmitButton() => Observer(
      builder: (_) => RaisedButton(
            elevation: 8,
            disabledElevation: 8,
            onPressed: _onSubmit,
            child: const Text('SAVE'),
          ));


  void _onSubmit() {
    // todo:
    print('On submit');
  }
}
