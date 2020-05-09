import 'package:flutter/foundation.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:flutter_mongo_stitch/auth/credentials/google_credential.dart';
import 'package:flutter_mongo_stitch/google_sign_in_git_mock/google_sign_in.dart';

import '../plugin.dart';
import 'core_stitch_user.dart';
import 'credentials/credentials.dart';

/// MongoStitchAuth manages authentication for any Stitch based client.
class MongoStitchAuth {

  // embedded Login providers wrappers for better handling
  static var _googleLoginWrapper = _GoogleLoginWrapper();
  static var _facebookLoginWrapper = _FacebookLoginWrapper();


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
    }
    else if (credential is GoogleCredential){
      _googleLoginWrapper.init(
          serverClientId: "${credential.serverClientId}.apps.googleusercontent.com",
          scopes: credential.scopes,
      );

      try {
        var authCode = await _googleLoginWrapper
            .handleSignInAndGetAuthServerCode();
        result = await FlutterMongoStitch.signInWithGoogle(authCode);
      }
      on Exception catch(e){
        print(e);
      }
    }
    else if (credential is FacebookCredential){
      var accessToken = await _facebookLoginWrapper.handleSignInAndGetToken(
          credential.permissions);
      result = await FlutterMongoStitch.signInWithFacebook(accessToken);
    }
    else {
      throw UnimplementedError();
    }

    return result;
  }

  Future<bool> logout() async {
    var result = await FlutterMongoStitch.logout();

    bool loggedWithGoogle = await _googleLoginWrapper.isLogged;
    bool loggedWithFacebook = await _facebookLoginWrapper.isLogged;

    if (loggedWithGoogle)
      await _googleLoginWrapper.handleSignOut();

    if (loggedWithFacebook)
      await _facebookLoginWrapper.handleSignOut();

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



class _FacebookLoginWrapper{
  final FacebookLogin _facebookSignIn = FacebookLogin();

  Future<bool> get isLogged => _facebookSignIn.isLoggedIn;

  Future<String> handleSignInAndGetToken([List<String> permissions]) async {
    var x = await _facebookSignIn.isLoggedIn;
    print(x);

    String token;
    _facebookSignIn.loginBehavior = FacebookLoginBehavior.webViewOnly;
    final FacebookLoginResult result = await _facebookSignIn.logIn(permissions ?? []);

    switch (result.status) {
      case FacebookLoginStatus.loggedIn:
        final FacebookAccessToken accessToken = result.accessToken;
        print('''
         Logged in!
         
         Token: ${accessToken.token}
         User id: ${accessToken.userId}
         Expires: ${accessToken.expires}
         Permissions: ${accessToken.permissions}
         Declined permissions: ${accessToken.declinedPermissions}
         ''');
        token = accessToken.token;
        break;
      case FacebookLoginStatus.cancelledByUser:
        print('Login cancelled by the user.');
        break;
      case FacebookLoginStatus.error:
        print('Something went wrong with the login process.\n'
            'Here\'s the error Facebook gave us: ${result.errorMessage}');
        break;
    }

    return token;
  }

  Future<void> handleSignOut() => _facebookSignIn.logOut();
}

class _GoogleLoginWrapper{
  GoogleSignIn _googleSignIn;

  Future<bool> get isLogged => _googleSignIn==null? Future.value(false) : _googleSignIn.isSignedIn();

  init({@required String serverClientId, List<String> scopes}){
    _googleSignIn = GoogleSignIn(
      serverClientId: serverClientId,
      scopes: scopes
    );
  }

  Future<String> handleSignInAndGetAuthServerCode() async {
    assert(_googleSignIn!=null);

    String code;
    try {
      var account = await _googleSignIn.signIn();
      if (account != null)
        code =  account.serverAuthCode;

    } on Exception catch (error) {
      print(error);
    }

    return code;
  }

  Future<void> handleSignOut() => _googleSignIn.disconnect();
}