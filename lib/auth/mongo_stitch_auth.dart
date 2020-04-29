import 'package:flutter/foundation.dart';

import '../plugin.dart';
import 'core_stitch_user.dart';
import 'credentials/credentials.dart';

/// MongoStitchAuth manages authentication for any Stitch based client.
class MongoStitchAuth {
  /// Logs in as a user with the given credentials associated with an
  /// authentication provider.
  Future<CoreStitchUser> loginWithCredential(
      StitchCredential credential) async {
    var result;

    if (credential is AnonymousCredential) {
      result = await FlutterMongoStitch.signInAnonymously();
    } else if (credential is UserPasswordCredential) {
      result = await FlutterMongoStitch.signInWithUsernamePassword(
        credential.username,
        credential.password,
      );
    } else {
      throw UnimplementedError();
    }

    return result;
  }

  Future<bool> logout() async {
    var result = await FlutterMongoStitch.logout();
    return result;
  }

  Future<bool> getUserId() async {
    var result = await FlutterMongoStitch.getUserId();
    return result;
  }

  Future<bool> registerWithEmail(
      {@required String email, @required String password}) async {
    var result = await FlutterMongoStitch.registerWithEmail(email, password);
    return result;
  }
}
