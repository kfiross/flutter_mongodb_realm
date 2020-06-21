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
  external updateDocument(String databaseName, String collectionName, String filter, String update);
  external updateDocuments(String databaseName, String collectionName, String filter, String update);

  external loginAnonymously();
  external signInWithUsernamePassword(String username, String password);
  external signInWithGoogle(String authCode);
  external signInWithFacebook(String token);
  external registerWithEmail(String username, String password);
  external logout();
  external getUserId();
  external getUser();
  external sendResetPasswordEmail(String email);

  external callFunction(String name, List args);//, int timeout);

  ///STREAM SOLUTION
  external setupWatchCollection(String databaseName, String collectionName, filter);
  external setupAuthListener();
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
    var docsCount =  await promiseToFuture(_mongo.countDocuments(databaseName, collectionName, filter));
    return docsCount;
  }

  Future updateDocument(String databaseName, String collectionName, String filter, String update) async {
    var docsUpdatedCount =  await promiseToFuture(_mongo.updateDocument(databaseName, collectionName, filter, update));
    return docsUpdatedCount;
  }


  Future updateDocuments(String databaseName, String collectionName, String filter, String update) async {
    var docsUpdatedCount =  await promiseToFuture(_mongo.updateDocuments(databaseName, collectionName, filter, update));
    return docsUpdatedCount;
  }


  //////


  Future<Map> loginAnonymously() async {
    String result = await promiseToFuture(_mongo.loginAnonymously());
    print(result);
    Map userMap = json.decode(result);
    return {"id": userMap['id']};
  }

  Future<Map> signInWithUsernamePassword(String username, String password) async {
    String result = await promiseToFuture(
        _mongo.signInWithUsernamePassword(username, password));
    print(result);
    Map userMap = json.decode(result);
    return {"id": userMap['id']};
  }

  Future<Map> signInWithGoogle(String authCode) async{
    String result = await promiseToFuture(
        _mongo.signInWithGoogle(authCode));
    print(result);
    Map userMap = json.decode(result);
    return {"id": userMap['id']};
  }

  Future<Map> signInWithFacebook(String token) async{
    String result = await promiseToFuture(
        _mongo.signInWithFacebook(token));
    print(result);
    Map userMap = json.decode(result);
    return {"id": userMap['id']};
  }


  Future<bool> registerWithEmail(String username, String password) async {
    /*String result =*/ await promiseToFuture(
        _mongo.registerWithEmail(username, password));
    return true;
  }

  Future<bool> logout() async{
    await promiseToFuture(_mongo.logout());
    return true;
  }

  Future<String> getUserId() async =>
      await promiseToFuture(_mongo.getUserId());

  Future<Map> getUser() async{
    String result = await promiseToFuture(_mongo.getUser());
    Map userMap = json.decode(result);
    return userMap;
  }

  Future<bool> sendResetPasswordEmail(String email)async {
    await promiseToFuture(_mongo.sendResetPasswordEmail(email));
    return true;
  }

  Future callFunction(String name, List args/*, int timeout*/) async{
    var result = await promiseToFuture(_mongo.callFunction(name, args/*, timeout*/));
    return result;
  }

  /// WEB-only solution

  setupWatchCollection(String databaseName, String collectionName, [filter]) {
    _mongo.setupWatchCollection(databaseName, collectionName, filter);
  }

}


