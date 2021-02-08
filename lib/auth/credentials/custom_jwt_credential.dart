import 'stitch_credential.dart';

@deprecated
class CustomJwtCredential extends StitchCredential {
  final String token;

  CustomJwtCredential(this.token);
}
