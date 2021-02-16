import 'stitch_credential.dart';

@deprecated
class FacebookCredential extends StitchCredential {
  final String accessToken;

  FacebookCredential(this.accessToken);
}
