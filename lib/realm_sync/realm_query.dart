import 'dart:convert';

import 'package:flutter_mongodb_realm/plugin.dart';

class RealmQuery{
  Type type;
  RealmQuery(this.type);
  String filter;

  Future findAll() async{
    var results = await FlutterRealm.findAll(this.type.runtimeType.toString());
    return jsonDecode(results);
  }

  Future findFirst() async {
    var results = await FlutterRealm.findFirst(this.type.runtimeType.toString());
    return results;
  }
}