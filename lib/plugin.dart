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

  static Future signInAnonymously() async {
    final result = await _channel.invokeMethod('signInAnonymously');
    return CoreStitchUser.fromMap(result);
  }

  static Future<CoreStitchUser> signInWithUsernamePassword(
      String username, String password) async {
    final result = await _channel.invokeMethod(
        'signInWithUsernamePassword',
        {'username': username, 'password': password});

    return CoreStitchUser.fromMap(result);
  }

  static Future<CoreStitchUser> signInWithGoogle(String authCode) async{
    final LinkedHashMap result = await _channel.invokeMethod(
        'signInWithGoogle', {'code': authCode});
    return CoreStitchUser.fromMap(result);
  }

  static Future<CoreStitchUser> signInWithFacebook(String accessToken) async{
    final LinkedHashMap result = await _channel.invokeMethod(
        'signInWithFacebook', {'token': accessToken});

    return CoreStitchUser.fromMap(result);
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

  static Future<CoreStitchUser> getUser() async{
    final LinkedHashMap result = await _channel.invokeMethod('getUser');
    return CoreStitchUser.fromMap(result);
  }

  static Future<bool> sendResetPasswordEmail(String email) async {
    final result = await _channel.invokeMethod(
        'sendResetPasswordEmail', {'email': email});

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
      {String collectionName, String databaseName, dynamic filter,
        String projection, int limit, String sort}) async {
    final result = await _channel.invokeMethod('findDocuments', {
      'database_name': databaseName,
      'collection_name': collectionName,
      'filter': filter,
      'projection': projection,
      'limit': limit,
      'sort': sort
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
    List<String> ids,
    String filter, bool asObjectIds = true,
  }) {
    // continuous stream of events from platform side
    return _streamsChannel.receiveBroadcastStream({
      "handler": "watchCollection",
      "db": databaseName,
      "collection": collectionName,
      "filter": filter,
      "ids": ids,
      "as_object_ids": asObjectIds,
    });
  }

  static aggregate({ @required String collectionName,  @required String databaseName,
    List<String> pipeline}) async {
    final results = await _channel.invokeMethod('aggregate', {
      'database_name': databaseName,
      'collection_name': collectionName,
      'pipeline': pipeline,
    });

    return results;
  }

  static Future callFunction(String name, {List args, int requestTimeout}) async{
    final result = _channel.invokeMethod('callFunction', {
      "name": name,
      "args": args,
      "timeout": requestTimeout
    });

    return result;
  }

  static Stream authListener() {
    // continuous stream of events from platform side
    return _streamsChannel.receiveBroadcastStream({
      "handler": "auth",
    });
  }


}
