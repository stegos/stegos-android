import 'package:stegos_wallet/env.dart';
import 'package:stegos_wallet/env_stegos.dart';
import 'package:stegos_wallet/main_common.dart';

class StegosEnvProduction extends StegosEnv {
  StegosEnvProduction() {
    type = EnvType.PRODUCTION;
  }

  @override
  String name = 'stegos_prod';

  @override
  int configSplashScreenTimeoutMs = 3000;
}

void main() {
  mainEntry(() async => StegosEnvProduction());
}
