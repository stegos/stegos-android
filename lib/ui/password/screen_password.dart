import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:stegos_wallet/ui/app.dart';
import 'package:stegos_wallet/ui/themes.dart';
import 'package:stegos_wallet/utils/cont.dart';
import 'package:stegos_wallet/widgets/widget_app_bar.dart';
import 'package:stegos_wallet/widgets/widget_scaffold_body_wrapper.dart';

class PasswordScreen extends StatefulWidget {
  const PasswordScreen(
      {Key key,
      @required this.caption,
      @required this.titleStatus,
      @required this.unlocker,
      this.title = '',
      this.titleSubmitButton = 'OK',
      this.obscureText = true})
      : super(key: key);
  final String caption;
  final String title;
  final String titleStatus;
  final String titleSubmitButton;
  final bool obscureText;
  final Future<Pair<String, String>> Function(String) unlocker;
  @override
  State<StatefulWidget> createState() => _PasswordScreenState();
}

class _PasswordScreenState extends State<PasswordScreen> {
  static const _iconBackImage = AssetImage('assets/images/arrow_back.png');

  String _titleStatus;

  String _password;

  @override
  void initState() {
    super.initState();
    _titleStatus = widget.titleStatus;
  }

  @override
  Widget build(BuildContext context) => Theme(
        data: StegosThemes.passwordTheme,
        child: Scaffold(
          appBar: AppBarWidget(
            centerTitle: true,
            backgroundColor: Theme.of(context).colorScheme.primary,
            leading: IconButton(
              icon: const SizedBox(
                width: 24,
                height: 24,
                child: Image(image: _iconBackImage),
              ),
              onPressed: _onCancel,
            ),
            title: Text(widget.title),
            actions: <Widget>[
              FlatButton.icon(onPressed: _onCancel, icon: Container(), label: const Text('Cancel'))
            ],
          ),
          body: ScaffoldBodyWrapperWidget(
              builder: (context) => Column(
                    children: <Widget>[
                      Padding(
                        padding: StegosThemes.defaultPaddingHorizontal,
                        child: Column(
                          children: <Widget>[
                            Text(
                              widget.caption,
                              textAlign: TextAlign.center,
                              style: StegosThemes.defaultCaptionTextStyle,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              _titleStatus,
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
                              onChanged: (val) => {_password = val},
                              style: StegosThemes.defaultInputTextStyle,
                              obscureText: widget.obscureText, // todo
                            )),
                      ),
                      SizedBox(width: double.infinity, height: 50, child: _buildSubmitButton())
                    ],
                  )),
        ),
      );

  Widget _buildSubmitButton() => RaisedButton(
        elevation: 8,
        disabledElevation: 8,
        onPressed: _onSubmit,
        child: Text(widget.titleSubmitButton),
      );

  void _onSubmit() async {
    final password = _password;
    final result = await widget.unlocker(password);
    if (result.second != null) {
      setState(() {
        _titleStatus = result.second;
      });
    } else {
      // Pop this screen
      StegosApp.navigatorState.pop(result.first);
    }
  }

  void _onCancel() {
    StegosApp.navigatorState.pop();
  }
}
