import 'package:flutter/cupertino.dart';

import 'stitch_credential.dart';

class GoogleCredential extends StitchCredential {
  final List<String> scopes;
  final String serverClientId;

  GoogleCredential({@required this.serverClientId, this.scopes});
}
