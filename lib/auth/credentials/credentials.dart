export 'stitch_credential.dart';
export 'anonymous_credential.dart';
export 'user_password_credentinal.dart';
export 'google_credential.dart';
export 'facebook_credential.dart';
export 'custom_jwt_credential.dart';

import '../auth.dart';
import 'anonymous_credential.dart';
import 'user_password_credentinal.dart';
import 'google_credential.dart';
import 'facebook_credential.dart';
import 'custom_jwt_credential.dart';

class Credentials{
  // ignore: deprecated_member_use_from_same_package
  static StitchCredential anonymous() => AnonymousCredential();
  // ignore: deprecated_member_use_from_same_package
  static StitchCredential emailPassword(String username, String password) => UserPasswordCredential(username: username, password: password);
  // ignore: deprecated_member_use_from_same_package
  static StitchCredential google({String serverClientId, List<String> scopes}) => GoogleCredential(serverClientId: serverClientId, scopes: scopes);
  // ignore: deprecated_member_use_from_same_package
  static StitchCredential facebook(String accessToken) => FacebookCredential(accessToken);
  // ignore: deprecated_member_use_from_same_package
  static StitchCredential jwt(String token) => CustomJwtCredential(token);
}

