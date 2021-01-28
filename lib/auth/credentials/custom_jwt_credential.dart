import 'stitch_credential.dart';

class CustomJwtCredential extends StitchCredential {
  final String token;
  CustomJwtCredential(this.token);
}