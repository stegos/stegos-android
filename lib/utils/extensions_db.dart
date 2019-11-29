import 'package:ejdb2_flutter/ejdb2_flutter.dart';

extension ExtendedEJDB on EJDB2 {
  /// todo: Temporal solution for patch-or-put
  /// until it will be implemented in upstream
  Future<int> patchOrPut(String collection, dynamic json, int id) =>
      patch(collection, json, id).then((_) => id).catchError((err) {
        if (err is EJDB2Error && err.isNotFound()) {
          return put(collection, json, id);
        }
        return Future.error(err);
      });
}
