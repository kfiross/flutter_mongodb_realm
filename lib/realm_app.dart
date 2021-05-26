import 'package:flutter/services.dart';
import 'package:flutter_mongodb_realm/auth/auth.dart';
import 'package:flutter_mongodb_realm/plugin.dart';

class RealmApp {
  RealmApp._();

  static final RealmApp _instance = RealmApp._();

  factory RealmApp() => _instance;

  static Future init(String appID) async {
    try {
      await FlutterMongoRealm.connectToMongo(appID);
    } on PlatformException catch (_) {
      // to ignore re-setting default app can twice
    }
    _auth = MongoRealmAuth();
  }

  static late MongoRealmAuth _auth;

  Future<CoreRealmUser?> login(StitchCredential credential) async {
    // ignore: deprecated_member_use_from_same_package
    return _auth.loginWithCredential(credential);
  }

  Future<bool?> logout() => _auth.logout();

  Future<String?> getUserId() => _auth.getUserId();

  Future<bool> registerUser(String email, String password) =>
      _auth.registerWithEmail(email: email, password: password);

  Future<bool> sendResetPasswordEmail(String email) =>
      _auth.sendResetPasswordEmail(email);

  Future<CoreRealmUser?> get currentUser => _auth.user;

  Stream authListener() => _auth.authListener();
}
