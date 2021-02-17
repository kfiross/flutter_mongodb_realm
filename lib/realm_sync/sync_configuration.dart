import 'package:flutter_mongodb_realm/auth/auth.dart';

class SyncConfiguration{
  final String partition;
  final CoreRealmUser user;

  SyncConfiguration(this.partition, this.user);

}