import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:streams_channel/streams_channel.dart';

import 'auth/auth.dart';

class FlutterMongoStitch {
  static const MethodChannel _channel =
      const MethodChannel('flutter_mongo_stitch');

  static StreamsChannel _streamsChannel =
      StreamsChannel('streams_channel_test');

  static Future connectToMongo(String appId) async {
    await _channel.invokeMethod('connectMongo', {'app_id': appId});
  }

  static Future<CoreStitchUser> signInWithUsernamePassword(
      String username, String password) async {
    final LinkedHashMap result = await _channel.invokeMethod(
        'signInWithUsernamePassword',
        {'username': username, 'password': password});

    var map = <String, dynamic>{};
    result.forEach((key, value) {
      map[key] = value;
    });

    return CoreStitchUser.fromMap(map);
  }

  static Future signInAnonymously() async {
    final result = await _channel.invokeMethod('signInAnonymously');

    var map = <String, dynamic>{};
    result.forEach((key, value) {
      map[key] = value;
    });

    return CoreStitchUser.fromMap(map);
  }

  static Future logout() async {
    final result = await _channel.invokeMethod('logout');

    return result;
  }

  static Future getUserId() async {
    final result = await _channel.invokeMethod('getUserId');

    return result;
  }

  static Future<bool> registerWithEmail(String email, String password) async {
    final result = await _channel.invokeMethod(
        'registerWithEmail', {'email': email, 'password': password});

    return result;
  }

  /// /////////////////////////////////////////////////////////////////

  static Future insertDocument({
    @required String collectionName,
    @required String databaseName,
    @required Map<String, Object> data,
  }) async {
    await _channel.invokeMethod('insertDocument', {
      'database_name': databaseName,
      'collection_name': collectionName,
      'data': data
    });
  }

  static Future insertDocuments({
    @required String collectionName,
    @required String databaseName,
    @required List<String> list,
  }) async {
    await _channel.invokeMethod('insertDocuments', {
      'database_name': databaseName,
      'collection_name': collectionName,
      'list': list
    });
  }

  static Future findDocuments(
      {String collectionName, String databaseName, dynamic filter, String projection, int limit}) async {
    final result = await _channel.invokeMethod('findDocuments', {
      'database_name': databaseName,
      'collection_name': collectionName,
      'filter': filter,
      'projection': projection,
      'limit': limit
    });

    return result;
  }

  static Future findFirstDocument(
      {String collectionName, String databaseName, dynamic filter, String projection}) async {
    final result = await _channel.invokeMethod('findDocument', {
      'database_name': databaseName,
      'collection_name': collectionName,
      'filter': filter,
      'projection': projection,
    });

    return result;
  }

  static Future deleteDocument(
      {String collectionName, String databaseName, dynamic filter}) async {
    final result = await _channel.invokeMethod('deleteDocument', {
      'database_name': databaseName,
      'collection_name': collectionName,
      'filter': filter
    });

    return result;
  }

  static Future deleteDocuments(
      {String collectionName, String databaseName, dynamic filter}) async {
    final result = await _channel.invokeMethod('deleteDocuments', {
      'database_name': databaseName,
      'collection_name': collectionName,
      'filter': filter
    });

    return result;
  }

  static Future countDocuments(
      {String collectionName, String databaseName, dynamic filter}) async {
    final size = await _channel.invokeMethod('countDocuments', {
      'database_name': databaseName,
      'collection_name': collectionName,
      'filter': filter
    });

    return size;
  }

  ///
  static Future updateDocument(
      {String collectionName,
      String databaseName,
      String filter,
      String update}) async {
    final results = await _channel.invokeMethod('updateDocument', {
      'database_name': databaseName,
      'collection_name': collectionName,
      'filter': filter,
      'update': update
    });

    return results;
  }

  static Future updateDocuments(
      {String collectionName,
      String databaseName,
      String filter,
      String update}) async {
    final results = await _channel.invokeMethod('updateDocuments', {
      'database_name': databaseName,
      'collection_name': collectionName,
      'filter': filter,
      'update': update
    });

    return results;
  }

  static Stream watchCollection({
    @required String collectionName,
    @required String databaseName,
    String filter,
  }) {
    // continuous stream of events from platform side
    return _streamsChannel.receiveBroadcastStream({
      "database": databaseName,
      "collection": collectionName,
      "filter": filter
    });
  }

  static Future callFunction(String name, {List args, int requestTimeout}) async{
    final result = _channel.invokeMethod('callFunction', {
      "name": name,
      "args": args,
      "timeout": requestTimeout
    });

    return result;
  }
}
