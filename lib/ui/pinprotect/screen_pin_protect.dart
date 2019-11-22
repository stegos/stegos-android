import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';
import 'package:provider/provider.dart';
import 'package:stegos_wallet/env_stegos.dart';
import 'package:stegos_wallet/ui/pinprotect/store_screen_pinprotect.dart';
import 'package:stegos_wallet/widgets/widget_pinpad.dart';
import 'package:stegos_wallet/widgets/widget_scaffold_body_wrapper.dart';

class PinProtectScreen extends StatefulWidget {
  const PinProtectScreen({Key key, @required this.nextRoute}) : super(key: key);

  final String nextRoute;

  @override
  State<StatefulWidget> createState() => _PinProtectScreenState();
}

class _PinProtectScreenState extends State<PinProtectScreen> {
  final store = PinprotectScreenStore();

  void _onPinReady(String pin) {
    runInAction(() {
      if (store.firstPin == null || store.secondPin != null) {
        store.firstPin = pin;
        store.secondPin = null;
      } else if (pin == store.firstPin) {
        Navigator.of(context).pushReplacementNamed(widget.nextRoute);
      } else {
        store.secondPin = pin;
      }
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
          body: ScaffoldBodyWrapperWidget(
        builder: (context) => Observer(
          builder: (context) {
            final env = Provider.of<StegosEnv>(context);
            return PinpadWidget(
              key: UniqueKey(),
              digits: 6,
              title: store.title,
              fingerprint: env.configAllowFingerprintWalletProtection,
              onPinReady: _onPinReady,
            );
          },
        ),
      ));
}
