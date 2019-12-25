import 'package:ejdb2_flutter/ejdb2_flutter.dart';
import 'package:flutter/widgets.dart';
import 'package:mobx/mobx.dart';
import 'package:stegos_wallet/env_stegos.dart';
import 'package:stegos_wallet/log/loggable.dart';
import 'package:stegos_wallet/stores/store_common.dart';
import 'package:stegos_wallet/services/service_node.dart';

part 'store_stegos.g.dart';

class ContactStore extends _ContactStore {
  ContactStore._(String name, String pkey, {int ordinal})
      : super(name, pkey, ordinal: ordinal);

  factory ContactStore._fromJBDOC(JBDOC doc) =>
      ContactStore._(doc.object['name'] as String, doc.object['pkey'] as String,
          ordinal: doc.object['ordinal'] as int);

  dynamic toJson() => {
    'name': name,
    'pkey': pkey,
    'ordinal': ordinal,
  };
}

abstract class _ContactStore with Store {
  _ContactStore(this.name, this.pkey, {this.ordinal});

  @observable
  String name;

  String pkey;

  int ordinal = 0;
}

class StegosStore extends _StegosStore with _$StegosStore {
  StegosStore(StegosEnv env) : super(env) {
    nodeService = NodeService(this);
  }
}

class ErrorState implements Exception {
  ErrorState(this.message);
  final String message;
}

abstract class _StegosStore extends MainStoreSupport with Store, Loggable<StegosStore> {
  _StegosStore(this.env);

  static const int DOC_SETTINGS_ID = 1;

  String _contactsCollectionName = 'contact';

  final StegosEnv env;

  /// Basic settings
  final settings = ObservableMap<String, dynamic>();

  final contacts = ObservableMap<String, ContactStore>();

  @computed
  List<ContactStore> get contactsList =>
      contacts.values.toList(growable: false)
        ..sort((a, b) => a.ordinal.compareTo(b.ordinal));

  /// True if need to show welcome screen as first app screen
  @computed
  bool get needWelcome => settings['needWelcome'] as bool ?? true;

  /// True if allow to unlock wallet with fingerprint
  @computed
  bool get allowBiometricsProtection => settings['allowBiometricsProtection'] as bool ?? false;

  set allowBiometricsProtection(bool val) => mergeSingle('allowBiometricsProtection', val);

  @computed
  String get nodeWsEndpoint => settings['nodeWsEndpoint'] as String ?? env.configNodeWsEndpoint;

  set nodeWsEndpoint(String val) => mergeSingle('nodeWsEndpoint', val);

  @computed
  String get nodeWsEndpointApiToken =>
      settings['wsApiToken'] as String ?? env.configNodeWsEndpointApiToken;

  /// Last known active route
  final lastRoute = Observable<RouteSettings>(null);

  /// Current error state text of `null`
  final error = Observable<ErrorState>(null);

  /// Stegos not substore
  NodeService nodeService;

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

  Future<void> mergeSingle(String key, dynamic value) =>
      mergeSettings(<String, dynamic>{key: value});

  Future<void> mergeSettings(Map<String, dynamic> update) => env.useDb((db) async {
        runInAction(() {
          update.entries.forEach((e) {
            if (e.value == null) {
              settings.remove(e.key);
            } else {
              settings[e.key] = e.value;
            }
          });
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
    final db = await env.getDb();
    await db.getOptional('settings', DOC_SETTINGS_ID).then((ov) {
      if (ov.isPresent) {
        untracked(() {
          final doc = ov.value.object as Map<dynamic, dynamic>;
          doc.entries.forEach((e) {
            settings[e.key.toString()] = e.value;
          });
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
    await _initContacts();
    // Activate substores
    return Future.forEach(<StoreLifecycle>[nodeService], (StoreLifecycle e) => e.activate());
  }

  @override
  Future<void> disposeAsync() =>
      Future.forEach(<StoreLifecycle>[nodeService], (StoreLifecycle e) => e.disposeAsync())
          .whenComplete(_flushSettings);

  Future<int> _flushSettings() => env.useDb((db) => db.put(
      'settings', settings.map((k, v) => MapEntry<dynamic, dynamic>(k, v)), DOC_SETTINGS_ID));

  Future<void> _initContacts() {
    return env.useDb((db) async {
      final contactsList = await db
          .createQuery('/*', _contactsCollectionName)
          .execute()
          .map((doc) => ContactStore._fromJBDOC(doc)).toList();
      runInAction(() {
        for (final c in contactsList) {
          contacts[c.pkey] = c;
        }
      });
    });
  }

  @action
  Future<void> addContact(String name, String pkey) async {
    //todo check if contact with that pkey already exists
    final newContact = ContactStore._(name, pkey, ordinal: contacts.length);
    runInAction(() => contacts.putIfAbsent(pkey, () => newContact));
    await env.useDb((db) async {
      await db.put(_contactsCollectionName, newContact.toJson());
    });
  }

  @action
  Future<void> removeContact(String pkey) async {
    runInAction(() => contacts.remove(pkey));
    await env.useDb((db) async {
      await db
          .createQuery('/[pkey = :?] | del', _contactsCollectionName)
          .setString(0, pkey)
          .first();
      contacts.remove(pkey);
    });
  }
}
