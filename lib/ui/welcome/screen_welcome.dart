import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mobx/mobx.dart';
import 'package:pedantic/pedantic.dart';
import 'package:provider/provider.dart';
import 'package:stegos_wallet/stores/store_stegos.dart';
import 'package:stegos_wallet/ui/routes.dart';
import 'package:stegos_wallet/ui/themes.dart';
import 'package:stegos_wallet/widgets/widget_scaffold_body_wrapper.dart';

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Theme(
        data: StegosThemes.welcomeTheme,
        child: Scaffold(
          body: ScaffoldBodyWrapperWidget(
              builder: (context) => Container(
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/welcome_background.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: ListView(
                      children: <Widget>[
                        const Image(
                          image: AssetImage('assets/images/logo.png'),
                        ),
                        Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 48),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                RaisedButton(
                                  onPressed: () => _onNewUser(context),
                                  child: const Text('I`M NEW USER'),
                                ),
                                FlatButton(
                                  textTheme: ButtonTextTheme.accent,
                                  onPressed: () => _onHaveAccount(context),
                                  child: const Text(
                                    'I ALREADY HAVE ACCOUNT',
                                  ),
                                )
                              ],
                            )),
                      ],
                    ),
                  )),
        ),
      );

  void _onHaveAccount(BuildContext context) {
    Navigator.pushReplacementNamed(context, Routes.recover);
  }

  void _onNewUser(BuildContext context) {
    Navigator.pushReplacementNamed(context, Routes.wallet);
    final store = Provider.of<StegosStore>(context);
    Future.microtask(() => runInAction(() => unawaited(store.mergeSingle('needWelcome', false))));
  }
}
