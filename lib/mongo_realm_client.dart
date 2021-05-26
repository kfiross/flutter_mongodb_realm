import 'package:flutter/services.dart';

import 'auth/auth.dart';
import 'database/database.dart';
import 'plugin.dart';

/// The MongoRealmClient is the entry point for working with data in MongoDB
/// remotely via Stitch.
class MongoRealmClient {
  @deprecated
  final MongoRealmAuth auth = MongoRealmAuth();

  @deprecated
  static Future initializeApp(String appID) async {
    try {
      await FlutterMongoRealm.connectToMongo(appID);
    } on PlatformException catch (_) {
      // to ignore re-setting default app can twice
    }
  }

  MongoDatabase getDatabase(String name) {
    return MongoDatabase(name);
  }

  /// Calls the specified Stitch function
  Future callFunction(String name, {List? args, int? requestTimeout}) async {
    var result = await FlutterMongoRealm.callFunction(
      name,
      args: args,
      requestTimeout: requestTimeout,
    );

    return result;
  }
}
