export 'stitch_credential.dart';
export 'anonymous_credential.dart';
export 'user_password_credentinal.dart';
export 'google_credential.dart';
export 'facebook_credential.dart';
export 'custom_jwt_credential.dart';
export 'custom_function_credential.dart';

import 'package:flutter_mongodb_realm/auth/credentials/apple_credential.dart';
import 'package:flutter_mongodb_realm/database/mongo_document.dart';

import '../auth.dart';
import 'anonymous_credential.dart';
import 'custom_function_credential.dart';
import 'user_password_credentinal.dart';
import 'google_credential.dart';
import 'facebook_credential.dart';
import 'custom_jwt_credential.dart';

class Credentials {
  // ignore: deprecated_member_use_from_same_package
  static StitchCredential anonymous() => AnonymousCredential();

  static StitchCredential emailPassword(String username, String password) =>
      // ignore: deprecated_member_use_from_same_package
      UserPasswordCredential(username: username, password: password);

  static StitchCredential google(
          {String? serverClientId, List<String>? scopes}) =>
      // ignore: deprecated_member_use_from_same_package
      GoogleCredential(serverClientId: serverClientId, scopes: scopes);

  static StitchCredential facebook(String accessToken) =>
      // ignore: deprecated_member_use_from_same_package
      FacebookCredential(accessToken);

  // ignore: deprecated_member_use_from_same_package
  static StitchCredential jwt(String token) => CustomJwtCredential(token);

  static StitchCredential customFunction(MongoDocument arguments) =>
      // ignore: deprecated_member_use_from_same_package
      FunctionCredential(arguments);

  // ignore: deprecated_member_use_from_same_package
  static StitchCredential apple(String idToken) => AppleCredential(idToken);
}
