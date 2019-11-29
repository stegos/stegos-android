import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';
import 'package:pedantic/pedantic.dart';
import 'package:provider/provider.dart';
import 'package:stegos_wallet/env_stegos.dart';
import 'package:stegos_wallet/log/loggable.dart';
import 'package:stegos_wallet/ui/app.dart';
import 'package:stegos_wallet/ui/pinprotect/store_screen_pinprotect.dart';
import 'package:stegos_wallet/widgets/widget_pinpad.dart';
import 'package:stegos_wallet/widgets/widget_scaffold_body_wrapper.dart';

Future<String> _setupPassword(StegosEnv env, String pin) async {
  final ss = env.securityService;
  final pw = ss.createRandomPassword();
  await ss.setupAppPassword(pw, pin);
  return pw;
}

Future<String> _unlockPassword(StegosEnv env, String pin) =>
    env.securityService.recoverAppPassword(pin);

class PinProtectScreen extends StatefulWidget {
  const PinProtectScreen({Key key, this.nextRoute, @required this.unlock}) : super(key: key);

  final RouteSettings nextRoute;

  final bool unlock;

  @override
  State<StatefulWidget> createState() => _PinProtectScreenState();
}

class _PinProtectScreenState extends State<PinProtectScreen> with Loggable<PinProtectScreen> {
  PinprotectScreenStore store;

  @override
  void initState() {
    super.initState();
    store = PinprotectScreenStore(widget.unlock ? 1 : 0);
  }

  void _onDone(String result, String pin) {
    if (widget.nextRoute != null) {
      StegosApp.navigatorKey.currentState.pushReplacementNamed(widget.nextRoute.name,
          result: result, arguments: widget.nextRoute.arguments);
    } else {
      StegosApp.navigatorKey.currentState.pop(result);
    }
  }

  void _onPinReady(String pin) {
    final env = Provider.of<StegosEnv>(context);
    runInAction(() {
      if (store.firstPin == null || store.secondPin != null) {
        store.firstPin = pin;
        store.secondPin = null;
      } else if (pin == store.firstPin) {
        unawaited(_setupPassword(env, pin).then((r) => _onDone(r, pin)));
      } else {
        store.secondPin = pin;
      }
    });
  }

  void _onUnlockPinready(String pin) {
    final env = Provider.of<StegosEnv>(context);
    unawaited(_unlockPassword(env, pin).then((r) => _onDone(r, pin)).catchError((err) {
      if (err != null) {
        log.warning('Error unlocking app', err);
      }
      runInAction(() {
        store.unlockAttempt += 1;
      });
    }));
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
              onPinReady: store.unlockAttempt > 0 ? _onUnlockPinready : _onPinReady,
            );
          },
        ),
      ));
}
