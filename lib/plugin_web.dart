@JS()
library stitch.js;

import 'dart:async';
import 'dart:convert';
import 'dart:js_util';


import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import "package:js/js.dart";


@JS()
external void connectMongo(String appId);

@JS()
external loginAnonymously();

@JS()
external findDocuments(String databaseName,String collectionName);

class FlutterMongoStitchPlugin {
  static void registerWith(Registrar registrar) {
    final MethodChannel channel = MethodChannel(
        'flutter_mongo_stitch',
        const StandardMethodCodec(),
        registrar.messenger,
    );

    final instance = FlutterMongoStitchPlugin();
    channel.setMethodCallHandler(instance.handleMethodCall);
  }

  Future<dynamic> handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'connectMongo':
        final String appId = call.arguments['app_id'];
        print(appId);
        connectMongo(appId);
        return true;

//      case 'insertDocument':
//        final String databaseName = call.arguments['database_name'];
//        final String collectionName = call.arguments['collection_name'];
//        final Map data = call.arguments['data'];
//        _insertDocument(databaseName, collectionName, data);
//        return true;

      case 'signInAnonymously':
        String result = await promiseToFuture(loginAnonymously());
        print(result);
        Map userMap = json.decode(result);
        return {"id": userMap['id']};


      case 'findDocuments':
        final String databaseName = call.arguments['database_name'];
        final String collectionName = call.arguments['collection_name'];
        var list = _findDocuments(databaseName, collectionName);
        return list;

      default:
        throw PlatformException(
            code: 'Unimplemented',
            details: "The plugin for web doesn't implement "
                "the method '${call.method}'");
    }
  }


  void _insertDocument(String databaseName, String collectionName, data) {
    //TODO: insertDocument(databaseName, collectionName);
  }

  Future<List<dynamic>> _findDocuments(String databaseName, String collectionName) async {
    var docs =  await promiseToFuture(findDocuments(databaseName, collectionName));
    return docs;
  }
}