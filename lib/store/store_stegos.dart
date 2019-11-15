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

  @override
  @action
  Future<void> activate() async {
    final env = this.env;
    final db = await env.getDb();

    settings.clear();

    await db.getOptional('settings', DOC_SETTINGS_ID).then((oval) async {
      if (oval.isPresent) {
        final doc = oval.value.object as Map<dynamic, dynamic>;
        doc.entries.forEach((e) {
          settings[e.key.toString()] = e.value;
        });
        return oval.value.id;
      } else {
        settings.addAll(<String, dynamic>{'needWelcome': true});
        return flushSettings();
      }
    });
  }

  @override
  void dispose() {}

  Future<int> flushSettings() => env.useDb((db) => db.put(
      'settings', settings.map((k, v) => MapEntry<dynamic, dynamic>(k, v)), DOC_SETTINGS_ID));
}
