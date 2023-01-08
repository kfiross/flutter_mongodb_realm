import 'stitch_credential.dart';

@deprecated
class AnonymousCredential extends StitchCredential {
  @override
  Map<String, Object> toJson() {
    return {
      "type": "anon",
    };
  }
}
