import 'dart:async';
import 'dart:convert';

import 'package:bson/bson.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_mongodb_realm/stream_interop/stream_interop.dart';
import 'package:flutter_mongo_stitch_platform_interface/flutter_mongo_stitch_platform_interface.dart';
import 'package:meta/meta.dart';
import 'package:universal_html/html.dart';

import 'auth/core_realm_user.dart';

class FlutterMongoRealm {
  static Future connectToMongo(String appId) async {
    return await FlutterMongoStitchPlatform.instance.connectToMongo(appId);
  }

  static Future signInAnonymously() async {
    var details = await FlutterMongoStitchPlatform.instance.signInAnonymously();
    return CoreRealmUser.fromMap(details);
  }

  static Future<CoreRealmUser?> signInWithUsernamePassword(
      String username, String password) async {
    var details = await FlutterMongoStitchPlatform.instance
        .signInWithUsernamePassword(username, password);
    return CoreRealmUser.fromMap(details);
  }

  static Future<CoreRealmUser?> signInWithGoogle(String authCode) async {
    var details =
        await FlutterMongoStitchPlatform.instance.signInWithGoogle(authCode);
    return CoreRealmUser.fromMap(details);
  }

  static Future<CoreRealmUser?> signInWithFacebook(String accessToken) async {
    var details = await FlutterMongoStitchPlatform.instance
        .signInWithFacebook(accessToken);
    return CoreRealmUser.fromMap(details);
  }

  static Future<CoreRealmUser?> signInWithCustomJwt(String token) async {
    var details =
        await FlutterMongoStitchPlatform.instance.signInWithCustomJwt(token);
    return CoreRealmUser.fromMap(details);
  }

  static Future<CoreRealmUser?> signInWithApple(String idToken) async {
    var details =
        await FlutterMongoStitchPlatform.instance.signInWithApple(idToken);
    return CoreRealmUser.fromMap(details);
  }

  static Future<CoreRealmUser?> signInWithCustomFunction(String json) async {
    var details = await FlutterMongoStitchPlatform.instance
        .signInWithCustomFunction(json);
    return CoreRealmUser.fromMap(details);
  }

  static Future logout() async {
    return await FlutterMongoStitchPlatform.instance.logout();
  }

  static Future getUserId() async {
    return await FlutterMongoStitchPlatform.instance.getUserId();
  }

  static Future<bool> registerWithEmail(String email, String password) async {
    return await FlutterMongoStitchPlatform.instance
        .registerWithEmail(email, password) ?? false;
  }

  static Future<CoreRealmUser?> getUser() async {
    var details = await FlutterMongoStitchPlatform.instance.getUser();
    return CoreRealmUser.fromMap(details);
  }

  static Future<bool> sendResetPasswordEmail(String email) async {
    return await FlutterMongoStitchPlatform.instance
        .sendResetPasswordEmail(email) ?? false;
  }

  ///

  static Future insertDocument({
    required String collectionName,
    required String databaseName,
    required Map<String, Object> data,
  }) async {
    return await FlutterMongoStitchPlatform.instance.insertDocument(
      collectionName: collectionName,
      databaseName: databaseName,
      data: data,
    );
  }

  static Future insertDocuments({
    required String collectionName,
    required String databaseName,
    required List<String> list,
  }) async {
    return await FlutterMongoStitchPlatform.instance.insertDocuments(
      collectionName: collectionName,
      databaseName: databaseName,
      list: list,
    );
  }

  static Future findDocuments(
      {required String collectionName,
      required String databaseName,
      required dynamic filter,
      String? projection,
      required int limit,
      String? sort}) async {
    return await FlutterMongoStitchPlatform.instance.findDocuments(
      collectionName: collectionName,
      databaseName: databaseName,
      filter: filter,
      limit: limit,
      sort: sort!,
      projection: projection!,
    );
  }

  static Future findFirstDocument(
      {required String collectionName,
      required String databaseName,
      required dynamic filter,
      String? projection}) async {
    return await FlutterMongoStitchPlatform.instance.findFirstDocument(
      collectionName: collectionName,
      databaseName: databaseName,
      filter: filter,
      projection: projection!,
    );
  }

  static Future deleteDocument(
      {required String collectionName, required String databaseName, required dynamic filter}) async {
    return await FlutterMongoStitchPlatform.instance.deleteDocument(
      collectionName: collectionName,
      databaseName: databaseName,
      filter: filter,
    );
  }

  static Future deleteDocuments(
      {required String collectionName, required String databaseName, required dynamic filter}) async {
    return await FlutterMongoStitchPlatform.instance.deleteDocuments(
      collectionName: collectionName,
      databaseName: databaseName,
      filter: filter,
    );
  }

  static Future countDocuments(
      {required String collectionName, required String databaseName, required dynamic filter}) async {
    return await FlutterMongoStitchPlatform.instance.countDocuments(
      collectionName: collectionName,
      databaseName: databaseName,
      filter: filter,
    );
  }

  ///
  static Future updateDocument(
      {required String collectionName,
      required String databaseName,
      required String filter,
      required String update}) async {
    return await FlutterMongoStitchPlatform.instance.updateDocument(
      collectionName: collectionName,
      databaseName: databaseName,
      filter: filter,
      update: update,
    );
  }

  static Future updateDocuments(
      {required String collectionName,
      required String databaseName,
      required String filter,
      required String update}) async {
    return await FlutterMongoStitchPlatform.instance.updateDocuments(
      collectionName: collectionName,
      databaseName: databaseName,
      filter: filter,
      update: update,
    );
  }

  static Stream watchCollection({
    required String collectionName,
    required String databaseName,
    List<String>? ids,
    String? filter,
    bool asObjectIds = true,
  }) {
    Stream nativeStream;

    if (kIsWeb) {
//      Stream<Event> jsStream =
//          document.on["watchEvent.$databaseName.$collectionName"];

      var jsStream = StreamInterop.getNativeStream(
          "watchEvent.$databaseName.$collectionName");

      // ignore: close_sinks
      var controller = StreamController<String>();

      // migrating events from the js-event to a dart event
      jsStream.listen((event) {
        var eventDetail = (event as CustomEvent).detail;

        var map = json.decode(eventDetail ?? "{}");

        if (map['_id'] is String == false) {
          map['_id'] = ObjectId.parse(map['_id']);
        }
        controller.add(jsonEncode(map));
      });

      nativeStream = controller.stream;
    } else {
      nativeStream = StreamInterop.getNativeStream({
        "handler": "watchCollection",
        "db": databaseName,
        "collection": collectionName,
        "filter": filter,
        "ids": ids,
        "as_object_ids": asObjectIds,
      });
    }

    return nativeStream;

    // continuous stream of events from platform side
//    return _streamsChannel.receiveBroadcastStream({
//      "handler": "watchCollection",
//      "db": databaseName,
//      "collection": collectionName,
//      "filter": filter,
//      "ids": ids,
//      "as_object_ids": asObjectIds,
//    });
  }

  static aggregate(
      {required String collectionName,
      required String databaseName,
      required List<String> pipeline}) async {
    return await FlutterMongoStitchPlatform.instance.aggregate(
      collectionName: collectionName,
      databaseName: databaseName,
      pipeline: pipeline,
    );
  }

  static Future callFunction(String name,
      {List? args, int? requestTimeout}) async {
    return await FlutterMongoStitchPlatform.instance.callFunction(
      name,
      args: args!,
      requestTimeout: requestTimeout!,
    );
  }

  static Stream authListener() {
    Stream nativeStream;

    if (kIsWeb) {
      //Stream<Event> jsStream = document.on["authChange"];
      var jsStream = StreamInterop.getNativeStream("authChange");

      // ignore: close_sinks
      var controller = StreamController<Map>();

      controller.onListen = () {
        controller.add(null!);
      };

      // migrating events from the js-event to a dart event
      jsStream.listen((event) {
        var eventDetail = (event as CustomEvent).detail;
        print(eventDetail);
        if (eventDetail == null) {
          controller.add(null!);
        } else {
          controller.add(eventDetail);
        }
      });

      nativeStream = controller.stream;
    } else {
      nativeStream = StreamInterop.getNativeStream({
        "handler": "auth",
      });
    }

    return nativeStream;

//    return _streamsChannel.receiveBroadcastStream({
//      "handler": "auth",
//    });
  }

  // WEB-specific helpers

  static Future setupWatchCollection(String collectionName, String databaseName,
      {List<String>? ids, bool? asObjectIds, String? filter}) async {
    await FlutterMongoStitchPlatform.instance.setupWatchCollection(
      collectionName,
      databaseName,
      ids: ids!,
      asObjectIds: asObjectIds!,
      filter: filter!,
    );
  }
}
