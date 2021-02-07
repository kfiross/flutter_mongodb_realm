import 'package:flutter_mongodb_realm/database/mongo_document.dart';

import 'stitch_credential.dart';

@deprecated
class CustomFunctionCredential extends StitchCredential {
  final MongoDocument arguments;
  CustomFunctionCredential(this.arguments);
}