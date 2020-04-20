import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'package:bson/bson.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import './query_selector.dart';

export 'query_selector.dart';

// TODO: maybe using 'BsonObject' instead 'dynamic'
class BsonDocument {
  final Map<String, dynamic> _map;

  Map<String, dynamic> get map => _map;

  /// Creates a document instance initialized with the given map.
  /// or an empty Document instance if not provided.
  const BsonDocument([this._map]);

  String toJson() => jsonEncode(_map ?? Map<String, dynamic>());
}

class MongoDocument {
  final Map<String, dynamic> _map = LinkedHashMap<String, dynamic>();

  Map<String, Object> get map => _map;

  /// Create a Document instance initialized with the given key/value pair.
  MongoDocument.single(String key, dynamic value) {
    _map[key] = value;
  }

  /// Creates a Document instance initialized with the given map.
  /// or an empty Document instance if not provided.
  MongoDocument(Map<String, dynamic> map) {
    if (map != null) {
      _map.addAll(map);
    }
  }

  static fixMapMismatchedTypes(Map map){
    final map2 = map.entries.toList();
    var result;
    if (map2.length == 1 && map2[0].key.contains("\$")) {
      switch (map2[0].key.substring(1)) {
      // Convert 'ObjectId' type
        case "oid":
          result = ObjectId.fromHexString(map2[0].value);
          break;

      // Convert 'Int64' type
        case "numberLong":
          result = int.parse(map2[0].value);
          break;

      // Convert 'Date' type
        case "date":
          if (map2[0].value is int)
            result = DateTime.fromMillisecondsSinceEpoch(map2[0].value,
                isUtc: true);
          else if (map2[0].value is String)
            result = DateTime.parse(map2[0].value);
          break;
      }
    }

    // fix 'Object' attribute types
    else {
      map.forEach((key, value) {
        if (value is LinkedHashMap) {
          map[key] = fixMapMismatchedTypes(value);
        }
      });
      result = map;

    }

    return result;
  }

  /// Parses a string in MongoDB Extended JSON format to a Document
  static MongoDocument parse(String jsonString) {
    Map<String, dynamic> map = json.decode(jsonString);

    // fix MongoDB bullshit
    map.forEach((key, value) {
      if (value is LinkedHashMap) {
        map[key] = fixMapMismatchedTypes(value);
      }
    });

    return MongoDocument(map);
  }

  /// Put the given key/value pair into this Document and return this.
  /// Useful for chaining puts in a single expression, e.g.
  /// doc.append("a", 1).append("b", 2)
  MongoDocument append(String key, Object value) {
    _map[key] = value;
    return this;
  }

  String toJson() => jsonEncode(_map);
}

class MongoCollection {
  final String collectionName;
  final String databaseName;

  MongoCollection({@required this.collectionName, @required this.databaseName});

  // DONE!
  Future insertOne(MongoDocument document) async {
    await Mongostitchflutter._insertDocument(
      collectionName: this.collectionName,
      databaseName: this.databaseName,
      data: document.map,
    );
  }

  // TODO: implement this
  void insertMany(List<MongoDocument> documents) {
    Mongostitchflutter._insertDocuments(
      collectionName: this.collectionName,
      databaseName: this.databaseName,
      list: documents.map((doc) => jsonEncode(doc._map)).toList(),
    );
  }

  /// FILTER ANDROID+IOS WORK!
  Future<int> deleteOne([Map<String, dynamic> filter]) async {
    // force sending an empty filter instead asserting
    if (filter == null) {
      filter = Map<String, dynamic>();
    }

    // convert 'QuerySelector' into map, too
    filter.forEach((key, value) {
      if (value is QuerySelector){
        filter[key] = value.values;
      }
    });

    var result = await Mongostitchflutter._deleteDocument(
      collectionName: this.collectionName,
      databaseName: this.databaseName,
      filter: BsonDocument(filter).toJson(),
    );

    return result;
  }

  /// FILTER ANDROID+IOS WORK!
  Future<int> deleteMany([Map<String, dynamic> filter]) async {
    // force sending an empty filter instead asserting
    if (filter == null) {
      filter = Map<String, dynamic>();
    }

    // convert 'QuerySelector' into map, too
    filter.forEach((key, value) {
      if (value is QuerySelector){
        filter[key] = value.values;
      }
    });

    var result = await Mongostitchflutter._deleteDocuments(
      collectionName: this.collectionName,
      databaseName: this.databaseName,
      filter: BsonDocument(filter).toJson(),
    );

    return result;
  }

  /// FILTER ANDROID+IOS WORK!
  Future<List<MongoDocument>> find([Map<String, dynamic> filter]) async {
    // fix map
    // ex. {"year": { "$gt": 2014 }}

    // {"year":{"$gt":2014}}


    // Me
    // {"year":{"$gt":2010,"$lte":2014}}

    // Site
    // {"year": { "$gt": 2010, "$lte": 2014 }}

    // convert 'QuerySelector' into map, too
    filter.forEach((key, value) {
      if (value is QuerySelector){
       filter[key] = value.values;
      }
    });


    List<dynamic> resultJson = await Mongostitchflutter._findDocuments(
      collectionName: this.collectionName,
      databaseName: this.databaseName,
      filter: BsonDocument(filter).toJson(),
    );

    var result = resultJson.map((string) {
      return MongoDocument.parse(string);
    }).toList();

    return result;
  }


  Future<void> findOne([Map<String, dynamic> filter]) async {
    String resultJson = await Mongostitchflutter._findFirstDocument(
      collectionName: this.collectionName,
      databaseName: this.databaseName,
      filter: BsonDocument(filter).toJson(),
    );

    // convert 'QuerySelector' into map, too
    filter.forEach((key, value) {
      if (value is QuerySelector){
        filter[key] = value.values;
      }
    });

    var result = MongoDocument.parse(resultJson);
    return result;
  }


  Future<int> count([Map<String, dynamic> filter]) async {

    // convert 'QuerySelector' into map, too
    filter.forEach((key, value) {
      if (value is QuerySelector){
        filter[key] = value.values;
      }
    });

    int size = await Mongostitchflutter._countDocuments(
      collectionName: this.collectionName,
      databaseName: this.databaseName,
      filter: BsonDocument(filter).toJson(),
    );

    return size;
  }
}

class MongoDatabase {
  final String _name;

  MongoDatabase(this._name);

  get name => _name;

  MongoCollection getCollection(String collectionName) {
    return MongoCollection(
      databaseName: this.name,
      collectionName: collectionName,
    );
  }
}

abstract class StitchCredential {}

class AnonymousCredential extends StitchCredential {}

class UserPasswordCredential extends StitchCredential {
  final String username;
  final String password;

  UserPasswordCredential({
    @required this.username,
    @required this.password,
  });
}

class MongoStitchAuth {
  Future<bool> loginWithCredential(StitchCredential credential) async {
    var result;

    if (credential is AnonymousCredential) {
      result = await Mongostitchflutter._signInAnonymously();
    } else if (credential is UserPasswordCredential) {
      result = await Mongostitchflutter._signInWithUsernamePassword(
        credential.username,
        credential.password,
      );
    } else {
      throw UnimplementedError();
    }

    return result;
  }

  Future<bool> logout() async {
    var result = await Mongostitchflutter._logout();
    return result;
  }

  Future<bool> getUserId() async {
    var result = await Mongostitchflutter._getUserId();
    return result;
  }

  Future<bool> registerWithEmail({@required String email,@required String password}) async {
    var result = await Mongostitchflutter._registerWithEmail(email, password);
    return result;
  }
}

class MongoStitchClient {
  final MongoStitchAuth auth = MongoStitchAuth();

  Future initializeApp(String appID) async {
    await Mongostitchflutter._connectToMongo(appID);
  }

  MongoDatabase getDatabase(String name) {
    return MongoDatabase(name);
  }
}

class Mongostitchflutter {
  static const MethodChannel _channel =
      const MethodChannel('mongostitchflutter');

  static Future _connectToMongo(String appId) async {
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

  static Future _signInWithUsernamePassword(
      String username, String password) async {
    final result = await _channel.invokeMethod('signInWithUsernamePassword',
        {'username': username, 'password': password});

    return result;
  }

  static Future _signInAnonymously() async {
    final result = await _channel.invokeMethod('signInAnonymously');

    return result;
  }

  static Future _logout() async {
    final result = await _channel.invokeMethod('logout');

    return result;
  }

  static Future _getUserId() async {
    final result = await _channel.invokeMethod('getUserId');

    return result;
  }

  static Future<bool> _registerWithEmail(String email, String password) async {
    final result = await _channel.invokeMethod(
        'registerWithEmail', {'email': email, 'password': password});

    return result;
  }

  /// /////////////////////////////////////////////////////////////////

  static Future _insertDocument({
    @required String collectionName,
    @required String databaseName,
    @required Map<String, Object> data,
  }) async {
    final result = await _channel.invokeMethod('insertDocument', {
      'database_name': databaseName,
      'collection_name': collectionName,
      'data': data
    });
  }

  static Future _insertDocuments({
    @required String collectionName,
    @required String databaseName,
    @required List<String> list,
  }) async {
    final result = await _channel.invokeMethod('insertDocuments', {
      'database_name': databaseName,
      'collection_name': collectionName,
      'list': list
    });
  }

  static Future _countDocuments(
      {String collectionName, String databaseName, dynamic filter}) async {
    final size = await _channel.invokeMethod('countDocuments', {
      'database_name': databaseName,
      'collection_name': collectionName,
      'filter': filter
    });

    return size;
  }

  static Future _findDocuments(
      {String collectionName, String databaseName, dynamic filter}) async {
    final result = await _channel.invokeMethod('findDocuments', {
      'database_name': databaseName,
      'collection_name': collectionName,
      'filter': filter
    });

    return result;
  }

  static Future _findFirstDocument(
      {String collectionName, String databaseName, dynamic filter}) async {
    final result = await _channel.invokeMethod('findDocument', {
      'database_name': databaseName,
      'collection_name': collectionName,
      'filter': filter
    });

    return result;
  }

  static Future _deleteDocument(
      {String collectionName, String databaseName, dynamic filter}) async {
    final result = await _channel.invokeMethod('deleteDocument', {
      'database_name': databaseName,
      'collection_name': collectionName,
      'filter': filter
    });

    return result;
  }

  static Future _deleteDocuments(
      {String collectionName, String databaseName, dynamic filter}) async {
    final result = await _channel.invokeMethod('deleteDocuments', {
      'database_name': databaseName,
      'collection_name': collectionName,
      'filter': filter
    });

    return result;
  }
}
