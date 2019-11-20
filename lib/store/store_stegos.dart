import 'package:flutter/widgets.dart';
import 'package:mobx/mobx.dart';
import 'package:stegos_wallet/env_stegos.dart';
import 'package:stegos_wallet/store/store_common.dart';

part 'store_stegos.g.dart';

class StegosStore = _StegosStore with _$StegosStore;

abstract class _StegosStore extends StoreSupport with Store {
  _StegosStore(this.env);

  static const int DOC_SETTINGS_ID = 1;

  final StegosEnv env;

  /// Basic settings
  final settings = ObservableMap<String, dynamic>();

  @computed
  bool get needWelcome => settings['needWelcome'] as bool ?? true;

  final lastRoute = Observable<RouteSettings>(null);

  Future<void> persistLastRoute(RouteSettings settings) => _mergeSettings({
        'lastRoute': {'name': settings.name, 'arguments': settings.arguments}
      }).then((_) {
        _updateLastRoute(settings);
      });

  @action
  void _updateLastRoute(RouteSettings settings) {
    lastRoute.value = settings;
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
      _updateLastRoute(RouteSettings(name: v['name'] as String, arguments: v['arguments']));
    }
  }

  @override
  Future<void> disposeAsync() {
    return _flushSettings();
  }

  Future<int> _flushSettings() => env.useDb((db) => db.put(
      'settings', settings.map((k, v) => MapEntry<dynamic, dynamic>(k, v)), DOC_SETTINGS_ID));

  Future<void> _mergeSettings(Map<String, dynamic> update) => env.useDb((db) async {
        update.entries.forEach((e) {
          if (e.value == null) {
            settings.remove(e.key);
          } else {
            settings[e.key] = e.value;
          }
          return db.patch('settings', update, DOC_SETTINGS_ID);
        });
      });
}
