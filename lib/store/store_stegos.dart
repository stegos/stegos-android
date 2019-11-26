import 'package:flutter/widgets.dart';
import 'package:mobx/mobx.dart';
import 'package:stegos_wallet/env_stegos.dart';
import 'package:stegos_wallet/log/loggable.dart';
import 'package:stegos_wallet/store/store_common.dart';
import 'package:stegos_wallet/store/store_node.dart';

part 'store_stegos.g.dart';

class StegosStore extends _StegosStore with _$StegosStore {
  StegosStore(StegosEnv env) : super(env) {
    storeNode = StegosNodeStore(this);
  }
}

class ErrorState implements Exception {
  ErrorState(this.message);
  final String message;
}

abstract class _StegosStore extends MainStoreSupport with Store, Loggable<StegosStore> {
  _StegosStore(this.env);

  static const int DOC_SETTINGS_ID = 1;

  final StegosEnv env;

  /// Basic settings
  final settings = ObservableMap<String, dynamic>();

  /// True if need to show welcome screen as first app screen
  @computed
  bool get needWelcome => settings['needWelcome'] as bool ?? true;

  /// User has pin protected password
  @computed
  bool get hasPinProtectedPassword => settings['password'] != null;

  @computed
  int get lastAppUnlockTs => settings['lastAppUnlockTs'] as int ?? 0;

  @computed
  bool get needAppUnlock =>
      DateTime.now().millisecondsSinceEpoch - lastAppUnlockTs >= env.configMaxAppUnlockedPeriod;

  @observable
  String accountPassword;

  @observable
  String prevAccountPassword;

  /// Last known active route
  final lastRoute = Observable<RouteSettings>(null);

  /// Current error state text of `null`
  final error = Observable<ErrorState>(null);

  /// Stegos not substore
  StegosNodeStore storeNode;

  /// Reset current error state
  @action
  void resetError() {
    if (error.value != null) {
      error.value = null;
    }
  }

  /// Setup error state
  @action
  void setError(String errorText) {
    error.value = ErrorState(errorText);
  }

  @action
  Future<void> touchAppUnlockedPeriod({String password, int touchTs}) {
    prevAccountPassword = accountPassword;
    accountPassword = password;
    if (password != null) {
      touchTs ??= DateTime.now().millisecondsSinceEpoch;
      return mergeSingle('lastAppUnlockTs', touchTs);
    } else {
      // Remove stored account passwords
      return mergeSettings({'password': null, 'iv': null, 'lastAppUnlockTs': null});
    }
  }

  Future<void> mergeSingle(String key, dynamic value) =>
      mergeSettings(<String, dynamic>{key: value});

  @action
  Future<void> mergeSettings(Map<String, dynamic> update) => env.useDb((db) async {
        update.entries.forEach((e) {
          if (e.value == null) {
            settings.remove(e.key);
          } else {
            settings[e.key] = e.value;
          }
        });
        return db.patch('settings', update, DOC_SETTINGS_ID);
      });

  Future<void> persistNextRoute(RouteSettings settings) {
    return mergeSettings({
      'lastRoute': {'name': settings.name, 'arguments': settings.arguments}
    }).then((_) {
      runInAction(() => lastRoute.value = settings);
    });
  }

  @override
  @action
  Future<void> activate() async {
    final env = this.env;
    await env.activate();

    settings.clear();
    final db = await env.getDb();
    await db.getOptional('settings', DOC_SETTINGS_ID).then((ov) {
      if (ov.isPresent) {
        final doc = ov.value.object as Map<dynamic, dynamic>;
        doc.entries.forEach((e) {
          settings[e.key.toString()] = e.value;
        });
        return ov.value.id;
      } else {
        settings.addAll(<String, dynamic>{'needWelcome': true});
        return _flushSettings();
      }
    });

    if (settings.containsKey('lastRoute')) {
      final v = settings['lastRoute'];
      final routeSettings = RouteSettings(name: v['name'] as String, arguments: v['arguments']);
      runInAction(() => lastRoute.value = routeSettings);
    }

    if (log.isFine) {
      log.fine(
          '\n\t${settings.entries.map((e) => 'settings: ${e.key} => ${e.value}').join('\n\t')}');
    }

    // Activate substores
    return Future.forEach(<StoreLifecycle>[storeNode], (StoreLifecycle e) => e.activate());
  }

  @override
  Future<void> disposeAsync() =>
      Future.forEach(<StoreLifecycle>[storeNode], (StoreLifecycle e) => e.disposeAsync())
          .whenComplete(_flushSettings);

  Future<int> _flushSettings() => env.useDb((db) => db.put(
      'settings', settings.map((k, v) => MapEntry<dynamic, dynamic>(k, v)), DOC_SETTINGS_ID));
}
