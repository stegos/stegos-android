import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';
import 'package:provider/provider.dart';
import 'package:stegos_wallet/env_stegos.dart';
import 'package:stegos_wallet/ui/app.dart';
import 'package:stegos_wallet/ui/recover/store_screen_recover.dart';
import 'package:stegos_wallet/ui/routes.dart';
import 'package:stegos_wallet/ui/seed_phraze/seed_phraze.dart';
import 'package:stegos_wallet/ui/themes.dart';
import 'package:stegos_wallet/widgets/widget_app_bar.dart';
import 'package:stegos_wallet/widgets/widget_scaffold_body_wrapper.dart';

class RecoverScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _RecoverScreenState();
}

class _RecoverScreenState extends State<RecoverScreen> {
  static const _iconBackImage = AssetImage('assets/images/arrow_back.png');
  final _store = RecoverScreenStore(24);

  @override
  Widget build(BuildContext context) => Theme(
        data: StegosThemes.backupTheme,
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
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text('Recover Stegos account'),
          ),
          body: ScaffoldBodyWrapperWidget(
              builder: (context) => Column(
                    children: <Widget>[
                      Padding(
                        padding: StegosThemes.defaultPaddingHorizontal,
                        child: Column(
                          children: const <Widget>[
                            Text(
                              'Please write down account restore the phase',
                              textAlign: TextAlign.center,
                              style: StegosThemes.defaultCaptionTextStyle,
                            ),
                            SizedBox(height: 10),
                            Text(
                              'All fields are case sensitive',
                              textAlign: TextAlign.center,
                              style: StegosThemes.defaultSubCaptionTextStyle,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                            child: SeedPhraze(
                          words: _store.keys.asMap(),
                          onChanged: _onTextFieldChanged,
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

  Widget _buildRecoverButton() => Observer(builder: (context) {
        final env = Provider.of<StegosEnv>(context);
        return RaisedButton(
          elevation: 8,
          disabledElevation: 8,
          onPressed: (!_store.recovering && _store.valid && env.nodeService.operable)
              ? () => _onRecover(env)
              : null,
          child: _store.recovering ? const Text('RECOVERING...') : const Text('RECOVER'),
        );
      });

  void _onRecover(StegosEnv env) async {
    final keys = _store.keys;
    runInAction(() {
      _store.recovering = true;
    });
    try {
      await env.nodeService.recoverAccount(keys).then((_) {
        StegosApp.navigatorState.pushReplacementNamed(Routes.wallet);
      }).then((_) {
        keys.fillRange(0, keys.length, '');
      }).catchError(defaultErrorHandler(env));
    } finally {
      runInAction(() {
        _store.recovering = false;
      });
    }
  }
}
