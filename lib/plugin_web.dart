@JS('stitch')
library stitch.js;

import 'dart:async';
import 'dart:html' as html;


import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import "package:js/js.dart";

@JS('Stitch.initializeDefaultAppClient')
external StitchAppClient initializeDefaultAppClient(String id);


@JS("Stitch.defaultAppClient")
external StitchAppClient get stitchAppClient;

@JS("RemoteMongoClient.factory")
external dynamic get remoteMongoClientFactory;


@JS()
class StitchAppClient{
  external RemoteMongoClient getServiceClient(StitchClientOptions options);
}


@JS()
class RemoteMongoClient{
  external RemoteMongoDatabase db(String name);
}

@JS()
class RemoteMongoDatabase{
  external String get name;
  external RemoteMongoCollection collection(String name);
}

@JS()
class RemoteMongoCollection{

}


@JS()
@anonymous
class StitchClientOptions{
  external get factory;
  external String get serviceName;

  external factory StitchClientOptions({factory, String serviceName});
}

// Invokes the JavaScript getter window.stitch`.
//external Stitch get stitch;

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
        return _connectMongo(appId);

      case 'insertDocument':
        final String databaseName = call.arguments['database_name'];
        final String collectionName = call.arguments['collection_name'];
        final Map data = call.arguments['data'];
        _insertDocument(databaseName, collectionName, data);


        return true;

      default:
        throw PlatformException(
            code: 'Unimplemented',
            details: "The plugin for web doesn't implement "
                "the method '${call.method}'");
    }
  }


  _connectMongo(String appId) {
    print(50);


    try {
      var client = initializeDefaultAppClient(appId);
      var mongoClient = client.getServiceClient(StitchClientOptions(serviceName: "mongodb-atlas"));
    }
    on Exception catch (e){
      print(e);
      print("error");
    }
    var x = 0;
    print(59);

    return true;

  }

  void _insertDocument(String databaseName, String collectionName, data) {
    print(115);
//    var mongoClient = stitchAppClient.getServiceClient(
//        StitchClientOptions(factory: remoteMongoClientFactory, serviceName: "mongodb-atlas")
//    );
    print(119);

    var db = mongoClient.db(databaseName);
    print(db.name);
    var c =  db.collection(collectionName);


  }
}