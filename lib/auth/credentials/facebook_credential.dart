import 'stitch_credential.dart';

@deprecated
class FacebookCredential extends StitchCredential {
  final String accessToken;

  FacebookCredential(this.accessToken);

  @override
  Map<String, Object?> toJson() {
    return {
      "type": "facebook",
      "accessToken": accessToken
    };
  }
}
