import 'stitch_credential.dart';

@deprecated
class AppleCredential extends StitchCredential {
  final String idToken;

  AppleCredential(this.idToken);

  @override
  Map<String, Object> toJson() {
    return {
      "type": "apple",
      "idToken": idToken
    };
  }
}
