import 'package:bson/bson.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mongodb_realm/flutter_mongo_realm.dart';
import 'package:flutter_mongodb_realm/realm_sync/reflector.dart';

@RealmClass
class User2 extends RealmObject {
  @PrimaryKey
  final ObjectId id;

  @MapTo("name")
  final String name;

  @MapTo("age")
  final int age;

  User2({
    @required this.id,
    @required this.name,
    @required this.age,
  });
}
