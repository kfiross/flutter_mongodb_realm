import 'package:flutter/services.dart';

import 'auth/auth.dart';
import 'database/database.dart';
import 'plugin.dart';

/// The MongoStitchClient is the entry point for working with data in MongoDB
/// remotely via Stitch.
class MongoStitchClient {
  final MongoStitchAuth auth = MongoStitchAuth();

  static Future initializeApp(String appID) async {
    try {
      await FlutterMongoStitch.connectToMongo(appID);
    } on PlatformException catch (_) {
      // to ignore re-setting default app can twice
    }
  }

  MongoDatabase getDatabase(String name) {
    return MongoDatabase(name);
  }

  /// Calls the specified Stitch function
  Future callFunction(String name, {List args, int requestTimeout}) async {
    var result = await FlutterMongoStitch.callFunction(
      name,
      args: args,
      requestTimeout: requestTimeout,
    );

    return result;
  }
}
