import 'stitch_credential.dart';

class FacebookCredential extends StitchCredential {
  final String accessToken;
  FacebookCredential(this.accessToken);
}
