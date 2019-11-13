import 'package:flutter/widgets.dart';
import 'package:stegos_wallet/ui/accounts/screen_accounts.dart';
import 'package:stegos_wallet/ui/splash/screen_splash.dart';
import 'package:stegos_wallet/ui/welcome/screen_welcome.dart';

mixin Routes {
  static const splash = 'splash';
  static const welcome = 'welcome';
  static const accounts = 'accounts';

  static final routes = <String, WidgetBuilder>{
    splash: (BuildContext context) => const SplashScreen(),
    welcome: (BuildContext context) => WelcomeScreen(),
    accounts: (BuildContext context) => AccountsScreen()
  };
}
