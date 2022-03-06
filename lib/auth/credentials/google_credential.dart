import 'stitch_credential.dart';

@deprecated
class GoogleCredential extends StitchCredential {
  final List<String>? scopes;
  final String? serverClientId;

  GoogleCredential({required this.serverClientId, this.scopes});
}

class GoogleCredential2 extends StitchCredential {
  final String accessToken;

  GoogleCredential2(this.accessToken);
}
