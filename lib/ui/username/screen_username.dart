import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pedantic/pedantic.dart';
import 'package:provider/provider.dart';
import 'package:stegos_wallet/env_stegos.dart';
import 'package:stegos_wallet/log/loggable.dart';
import 'package:stegos_wallet/services/service_node.dart';
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

class _UsernameScreenState extends State<UsernameScreen> with Loggable<_UsernameScreenState> {
  static const _iconBackImage = AssetImage('assets/images/arrow_back.png');
  TextEditingController usernameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    if (usernameController.text.isEmpty) {
      final env = Provider.of<StegosEnv>(context);
      final AccountStore acc = env.nodeService.accounts[widget.id];
      usernameController.text = acc.name;
    }

    return Theme(
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
            onPressed: _onCancel,
          ),
          title: const Text('Account name'),
        ),
        body: ScaffoldBodyWrapperWidget(
            builder: (context) => Column(
                  children: <Widget>[
                    Expanded(
                      child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              Text(
                                'Account name',
                                style:
                                    TextStyle(fontSize: 12, color: StegosColors.primaryColorDark),
                              ),
                              Container(
                                padding: const EdgeInsets.only(bottom: 7),
                                child: TextField(
                                  controller: usernameController,
                                  style: StegosThemes.defaultInputTextStyle,
                                  decoration:
                                      const InputDecoration(contentPadding: EdgeInsets.zero),
                                ),
                              ),
                              Text(
                                'The user profile name can be a maximum of 48 characters',
                                style:
                                    TextStyle(fontSize: 12, color: StegosColors.primaryColorDark),
                              )
                            ],
                          )),
                    ),
                    SizedBox(width: double.infinity, height: 50, child: _buildSubmitButton())
                  ],
                )),
      ),
    );
  }

  Widget _buildSubmitButton() => RaisedButton(
        elevation: 8,
        disabledElevation: 8,
        onPressed: _onSubmit,
        child: const Text('SAVE'),
      );

  void _onSubmit() {
    final env = Provider.of<StegosEnv>(context);
    unawaited(env.nodeService.renameAccount(widget.id, usernameController.text).then<void>((_) {
      StegosApp.navigatorState.pop();
    }).catchError((err, StackTrace st) {
      log.warning('Failed to rename account: ', err, st);
    }));
  }

  void _onCancel() {
    StegosApp.navigatorState.pop();
  }
}
