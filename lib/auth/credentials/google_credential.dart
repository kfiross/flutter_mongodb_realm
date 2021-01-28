import 'package:flutter/cupertino.dart';

import 'stitch_credential.dart';

@deprecated
class GoogleCredential extends StitchCredential {
  final List<String> scopes;
  final String serverClientId;

  GoogleCredential({@required this.serverClientId, this.scopes});
}
