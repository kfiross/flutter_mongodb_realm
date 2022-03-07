import 'dart:async';
import 'dart:convert';

import 'package:flutter_mongodb_realm/auth/credentials/apple_credential.dart';

//import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:flutter_mongodb_realm/database/mongo_document.dart';
import 'package:flutter_mongodb_realm/google_sign_in_git_mock/google_sign_in.dart';
// import 'package:flutter_mongodb_realm/google_sign_in_git_mock/google_sign_in.dart';

import '../plugin.dart';
import 'core_realm_user.dart';
import 'credentials/credentials.dart';

/// MongoRealmAuth manages authentication for any Stitch based client.

class MongoRealmAuth {
  MongoRealmAuth._();

  static final MongoRealmAuth _instance = MongoRealmAuth._();

  factory MongoRealmAuth() => _instance;

  // embedded Login providers wrappers for better handling
  static var _googleLoginWrapper = _GoogleLoginWrapper();

//  static var _facebookLoginWrapper = _FacebookLoginWrapper();

  /// Logs in as a user with the given credentials associated with an
  /// authentication provider.
  @deprecated
  Future<CoreRealmUser?> loginWithCredential(
      StitchCredential credential) async {
    var result;

    if (credential is AnonymousCredential) {
      result = await FlutterMongoRealm.signInAnonymously();
    } else if (credential is UserPasswordCredential) {
      result = await FlutterMongoRealm.signInWithUsernamePassword(
        credential.username,
        credential.password,
      );
    } else if (credential is GoogleCredential2) {
      try {
        var accessToken = credential.accessToken;
        result = await FlutterMongoRealm.signInWithGoogle(accessToken);
      } on Exception catch (e) {
        print(e);
      }
    } else if (credential is GoogleCredential) {
      _googleLoginWrapper.init(
        serverClientId:
            "${credential.serverClientId}.apps.googleusercontent.com",
        scopes: credential.scopes,
      );

      try {
        var authCode =
            await _googleLoginWrapper.handleSignInAndGetAuthServerCode();
        result = await FlutterMongoRealm.signInWithGoogle(authCode ?? '');
      } on Exception catch (e) {
        print(e);
      }
    } else if (credential is FacebookCredential) {
      result =
          await FlutterMongoRealm.signInWithFacebook(credential.accessToken);
    } else if (credential is CustomJwtCredential) {
      result = await FlutterMongoRealm.signInWithCustomJwt(credential.token);
    } else if (credential is FunctionCredential) {
      final MongoDocument doc = credential.arguments;
      var args = json.encode(doc.map);
      result = await FlutterMongoRealm.signInWithCustomFunction(args);
    } else if (credential is AppleCredential) {
      result = await FlutterMongoRealm.signInWithApple(credential.idToken);
    } else {
      throw UnimplementedError();
    }

    return result;
  }

  Future<bool?> logout() async {
    var result = await FlutterMongoRealm.logout();

    bool loggedWithGoogle =
        await (_googleLoginWrapper.isLogged as FutureOr<bool>);
//    bool loggedWithFacebook = await _facebookLoginWrapper.isLogged;
//
    if (loggedWithGoogle) await _googleLoginWrapper.handleSignOut();
//
//    if (loggedWithFacebook)
//      await _facebookLoginWrapper.handleSignOut();

    return result;
  }

  Future<String?> getUserId() async {
    var result = await FlutterMongoRealm.getUserId();
    return result;
  }

  Future<bool> registerWithEmail(
      {required String email, required String password}) async {
    var result = await FlutterMongoRealm.registerWithEmail(email, password);
    return result;
  }

  Future<bool> sendResetPasswordEmail(String? email) async {
    var result = await FlutterMongoRealm.sendResetPasswordEmail(email);
    return result;
  }

  Future<CoreRealmUser?> get user async => await FlutterMongoRealm.getUser();

  Stream authListener() {
    var stream = FlutterMongoRealm.authListener();
    return stream;
  }
}

/// ////////////////////////////////////////////////////////////////

class _GoogleLoginWrapper {
  GoogleSignIn? _googleSignIn;

  Future<bool?> get isLogged =>
      _googleSignIn == null ? Future.value(false) : _googleSignIn!.isSignedIn();

  init({required String serverClientId, List<String>? scopes}) {
    _googleSignIn =
        GoogleSignIn(serverClientId: serverClientId, scopes: scopes);
  }

  Future<String?> handleSignInAndGetAuthServerCode() async {
    assert(_googleSignIn != null);

    String? code;
    // try {
    var account = await _googleSignIn!.signIn();

    if (account != null) code = account.serverAuthCode;
    // } on Exception catch (error) {
    //   print(error);
    // }

    return code;
  }

  Future<void> handleSignOut() => _googleSignIn!.disconnect();
}
