import 'dart:async';
import 'package:flutter/services.dart';

class Mongoatlasflutter {
  static const MethodChannel _channel =
      const MethodChannel('mongoatlasflutter');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future connectToMongo() async {
    final appId = "mystitchapp-fjpmn";
    await _channel.invokeMethod('connectMongo', {'app_id': appId});
  }

//  static Future MongoCollection() async {
//    final collectionName = "myCollection";
//    final databaseName = "test";
//    final x = await _channel.invokeMethod('getMongoCollection', {
//      'database_name': databaseName,
//      'collection_name': collectionName,
//    });
//
//    return x;
//  }

  static Future insertDocument() async {
    final collectionName = "my_collection";
    final databaseName = "test";
    final data = {
      "time": DateTime.now().millisecondsSinceEpoch,
      "user_id": "abcdefg"
    };

    final result = await _channel.invokeMethod('insertDocument', {
      'database_name': databaseName,
      'collection_name': collectionName,
      'data': data
    });
  }
}
