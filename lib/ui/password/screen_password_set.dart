import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:stegos_wallet/ui/app.dart';
import 'package:stegos_wallet/ui/themes.dart';
import 'package:stegos_wallet/widgets/widget_app_bar.dart';
import 'package:stegos_wallet/widgets/widget_scaffold_body_wrapper.dart';

class PasswordSetScreen extends StatefulWidget {
  PasswordSetScreen({Key key, this.title = '', this.titleSubmitButton = 'OK'}) : super(key: key);

  final String title;

  final String titleSubmitButton;

  @override
  _PasswordSetScreenState createState() => _PasswordSetScreenState();
}

class _PasswordSetScreenState extends State<PasswordSetScreen> {
  final _formKey = GlobalKey<FormState>();

  String _password = '';

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
                child: Image(image: AssetImage('assets/images/arrow_back.png')),
              ),
              onPressed: _onCancel,
            ),
            title: Text(widget.title),
            actions: <Widget>[
              FlatButton.icon(onPressed: _onCancel, icon: Container(), label: const Text('Cancel'))
            ],
          ),
          body: ScaffoldBodyWrapperWidget(
            builder: (context) => Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: StegosThemes.defaultPaddingHorizontal,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Account password',
                          style: TextStyle(fontSize: 12, color: StegosColors.primaryColorDark),
                        ),
                        TextFormField(
                          initialValue: _password,
                          validator: _validator,
                          obscureText: true,
                          onChanged: (v) => _password = v.trim(),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Confirm password',
                          style: TextStyle(fontSize: 12, color: StegosColors.primaryColorDark),
                        ),
                        TextFormField(
                          initialValue: _password,
                          validator: _validator,
                          obscureText: true,
                        ),
                      ],
                    ),
                  ),
                  const Expanded(child: SizedBox.shrink()),
                  SizedBox(width: double.infinity, height: 50, child: _buildSubmitButton())
                ],
              ),
            ),
          ),
        ),
      );

  String _validator(String input) {
    if (input.isEmpty) {
      return 'Please enter password';
    }
    if (input != _password) {
      return 'Passwords are not matched';
    }
    return null;
  }

  Widget _buildSubmitButton() => RaisedButton(
        elevation: 8,
        disabledElevation: 8,
        onPressed: _onSubmit,
        child: Text(widget.titleSubmitButton),
      );

  void _onSubmit() async {
    if (_formKey.currentState.validate()) {
      StegosApp.navigatorState.pop(_password);
    }
  }

  void _onCancel() {
    StegosApp.navigatorState.pop();
  }
}
