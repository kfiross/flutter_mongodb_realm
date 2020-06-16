import 'dart:collection';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_mongo_stitch/web/implementation.dart';
import 'package:js/js_util.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

class FlutterMongoStitchPlugin {
  static void registerWith(Registrar registrar) async {
    final MethodChannel channel = MethodChannel(
      'flutter_mongo_stitch',
      const StandardMethodCodec(),
      registrar.messenger,
    );

    final instance = FlutterMongoStitchPlugin();
    channel.setMethodCallHandler(instance.handleMethodCall);
  }

  var _mongoClient = MyMongoClient();

  Future<dynamic> handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'connectMongo':
        return _connectMongo(call);

      // Database
      case 'insertDocument':
        return await _insertDocument(call);

      case 'insertDocuments':
        return await _insertDocuments(call);

      case 'deleteDocument':
        return await _deleteDocument(call);

      case 'deleteDocuments':
        return await _deleteDocuments(call);

      case 'findDocuments':
        return await _findDocuments(call);

      case 'findDocument':
        return await _findDocument(call);

      case 'countDocuments':
        return await _countDocuments(call);

      case 'updateDocument':
        return await _updateDocument(call);

      case 'updateDocuments':
        return await _updateDocuments(call);

      case 'aggregate':
        return await _aggregate(call);


      // Auth
      case 'signInAnonymously':
        return await _signInAnonymously();

      case 'signInWithUsernamePassword':
        return await _signInWithUsernamePassword(call);

      case 'signInWithGoogle':
        return await _signInWithGoogle(call);

      case 'signInWithFacebook':
        return await _signInWithFacebook(call);


      // Stitch Functions
      case 'callFunction':
        return await _callFunction(call);


      default:
        throw PlatformException(
            code: 'Unimplemented',
            details: "The plugin for web doesn't implement "
                "the method '${call.method}'");
    }
  }

  _connectMongo(MethodCall call) {
    final String appId = call.arguments['app_id'];
    _mongoClient.connectMongo(appId);
    return true;
  }

  ///==========================================================

  _insertDocument(MethodCall call) async{
    final String databaseName = call.arguments['database_name'];
    final String collectionName = call.arguments['collection_name'];
    final HashMap data = call.arguments["data"];

    await _mongoClient.insertDocument(databaseName, collectionName, data);
    return true;
  }

  _insertDocuments(MethodCall call) async{
    final String databaseName = call.arguments['database_name'];
    final String collectionName = call.arguments['collection_name'];
    final List list = call.arguments["list"];

    await _mongoClient.insertDocuments(databaseName, collectionName, list);
    return true;
  }

  _deleteDocument(MethodCall call) async{
    final String databaseName = call.arguments['database_name'];
    final String collectionName = call.arguments['collection_name'];
    final String filter = call.arguments['filter'];

    String resultString =  await _mongoClient.deleteDocument(databaseName, collectionName, filter);
    Map<String, dynamic> map = json.decode(resultString);

    return map["deletedCount"];
  }

  _deleteDocuments(MethodCall call) async{
    final String databaseName = call.arguments['database_name'];
    final String collectionName = call.arguments['collection_name'];
    final String filter = call.arguments['filter'];

    String resultString =  await _mongoClient.deleteDocuments(databaseName, collectionName, filter);
    Map<String, dynamic> map = json.decode(resultString);

    return map["deletedCount"];
  }

  _findDocuments(MethodCall call) async {
    final String databaseName = call.arguments['database_name'];
    final String collectionName = call.arguments['collection_name'];
    final String filter = call.arguments['filter'];

    var list = await _mongoClient.findDocuments(databaseName, collectionName, filter);
    return list;
  }

  _findDocument(MethodCall call) async{
    final String databaseName = call.arguments['database_name'];
    final String collectionName = call.arguments['collection_name'];
    final String filter = call.arguments['filter'];
    final String projection = call.arguments['projection'];


    var list = await _mongoClient.findDocument(databaseName, collectionName, filter);
    return list;

  }

  _countDocuments(MethodCall call) async{
    final String databaseName = call.arguments['database_name'];
    final String collectionName = call.arguments['collection_name'];
    final String filter = call.arguments['filter'];

    var size = await _mongoClient.countDocuments(databaseName, collectionName, filter);
    return size;
  }

  _updateDocument(MethodCall call) async{
    final String databaseName = call.arguments['database_name'];
    final String collectionName = call.arguments['collection_name'];
    final String filter = call.arguments['filter'];
    final String update = call.arguments['update'];

    String resultString = await _mongoClient.updateDocument(databaseName, collectionName, filter, update);
    Map<String, dynamic> map = json.decode(resultString);

    return <int>[map["matchedCount"] , map["modifiedCount"]];

  }

  _updateDocuments(MethodCall call) async{
    final String databaseName = call.arguments['database_name'];
    final String collectionName = call.arguments['collection_name'];
    final String filter = call.arguments['filter'];
    final String update = call.arguments['update'];

    String resultString = await _mongoClient.updateDocuments(databaseName, collectionName, filter, update);
    Map<String, dynamic> map = json.decode(resultString);
    print(186);

    return [map["matchedCount"] , map["modifiedCount"]];
  }

  _aggregate(MethodCall call) async{}

  ///====================================================================

  _signInAnonymously() async {
    var authResult = await _mongoClient.loginAnonymously();
    return authResult;
  }

  _signInWithUsernamePassword(MethodCall call) async{}

  _signInWithGoogle(MethodCall call) async{}

  _signInWithFacebook(MethodCall call) async{}

  _registerWithEmail(MethodCall call) async{}

  _logout(MethodCall call) async{}

  _getUserId(MethodCall call) async{}

  _getUser(MethodCall call) async{}

  _sendResetPasswordEmail(MethodCall call) async{}

  ///====================================================================

  _callFunction(MethodCall call) {}
}
