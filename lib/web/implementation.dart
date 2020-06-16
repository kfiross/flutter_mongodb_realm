@JS()
library stitch.js;

import 'dart:async';
import 'dart:convert';
import 'dart:js_util';


import "package:js/js.dart";


@JS('Mongo')
class Mongo{
  external Mongo();

  external void connectMongo(String appId);

  external insertDocument(String databaseName, String collectionName , data);
  external insertDocuments(String databaseName, String collectionName ,List listData);
  external deleteDocument(String databaseName, String collectionName, String filter);
  external deleteDocuments(String databaseName, String collectionName, String filter);
  external findDocument(String databaseName, String collectionName, String filter);
  external findDocuments(String databaseName, String collectionName, String filter);
  external countDocuments(String databaseName, String collectionName, String filter);

  external loginAnonymously();
}

class MyMongoClient{
  var _mongo = Mongo();

  void connectMongo(String appId) => _mongo.connectMongo(appId);

  //////

  Future<bool> insertDocument(String databaseName, String collectionName, Map data) async{
    await promiseToFuture(
        _mongo.insertDocument(databaseName, collectionName, json.encode(data)));
    return true;
  }

  Future<bool> insertDocuments(String databaseName, String collectionName, List listData) async{
    await promiseToFuture(
        _mongo.insertDocuments(databaseName, collectionName, listData));
    return true;
  }

  Future deleteDocument(String databaseName, String collectionName, String filter) async{
    var result = await promiseToFuture(
        _mongo.deleteDocument(databaseName, collectionName, filter));
    return result;
  }

  Future deleteDocuments(String databaseName, String collectionName, String filter) async{
    var result = await promiseToFuture(
        _mongo.deleteDocuments(databaseName, collectionName, filter));
    return result;
  }

  Future<String> findDocument(String databaseName, String collectionName, String filter) async {
    var docs =  await promiseToFuture(_mongo.findDocument(databaseName, collectionName, filter));
    return docs;
  }

  Future<List<dynamic>> findDocuments(String databaseName, String collectionName, String filter) async {
    var docs =  await promiseToFuture(_mongo.findDocuments(databaseName, collectionName, filter));
    return docs;
  }

  Future<int> countDocuments(String databaseName, String collectionName, String filter) async {
    var docs =  await promiseToFuture(_mongo.countDocuments(databaseName, collectionName, filter));
    return docs;
  }


  //////


  Future<Map> loginAnonymously() async {
    String result = await promiseToFuture(_mongo.loginAnonymously());
    print(result);
    Map userMap = json.decode(result);
    return {"id": userMap['id']};
  }
}


