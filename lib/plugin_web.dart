@JS('stitch')
library stitch.js;

import 'dart:async';
import 'dart:html' as html;


import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import "package:js/js.dart";

@JS('stitch')
class Stitch {
   external static dynamic initializeDefaultAppClient(id);
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
//      var client = Stitch.initializeDefaultAppClient(appId);
    }
    on Exception catch (e){
      print(e);
    }
    var x = 0;

    return true;

  }
}