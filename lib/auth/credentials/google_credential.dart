import 'stitch_credential.dart';

class GoogleCredential2 extends StitchCredential {
  final String authCode;

  GoogleCredential2(this.authCode);

  @override
  Map<String, Object> toJson() {
    return {
      "type": "google",
      "authCode": authCode
    };
  }
}
