import 'package:flutter_mongodb_realm/database/mongo_document.dart';

import 'stitch_credential.dart';

@deprecated
class FunctionCredential extends StitchCredential {
  final MongoDocument arguments;

  FunctionCredential(this.arguments);
}
