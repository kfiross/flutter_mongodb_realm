import 'stitch_credential.dart';

@deprecated
class UserPasswordCredential extends StitchCredential {
  final String username;
  final String password;

  UserPasswordCredential({
    required this.username,
    required this.password,
  });
}
