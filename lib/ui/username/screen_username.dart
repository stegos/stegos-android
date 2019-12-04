import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:stegos_wallet/ui/app.dart';
import 'package:stegos_wallet/ui/themes.dart';
import 'package:stegos_wallet/widgets/widget_app_bar.dart';
import 'package:stegos_wallet/widgets/widget_scaffold_body_wrapper.dart';

class UsernameScreen extends StatefulWidget {
  const UsernameScreen({Key key, @required this.id}) : super(key: key);

  final int id;

  @override
  State<StatefulWidget> createState() => _UsernameScreenState();
}

class _UsernameScreenState extends State<UsernameScreen> {
  static const _iconBackImage = AssetImage('assets/images/arrow_back.png');

  String _username;

  @override
  void initState() {
    super.initState();
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
            title: Text('Account name'),
          ),
          body: ScaffoldBodyWrapperWidget(
              builder: (context) => Column(
                    children: <Widget>[
                      Expanded(
                        child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
                            child: TextField(
                              onChanged: (val) => {_username = val},
                              style: StegosThemes.defaultInputTextStyle,

                              decoration: const InputDecoration(
                                labelText: 'Account name',
                                contentPadding: EdgeInsets.zero
                              ),
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
        child: Text('SAVE'),
      );

  void _onSubmit() {
    StegosApp.navigatorState.pop();
  }

  void _onCancel() {
    StegosApp.navigatorState.pop();
  }
}
