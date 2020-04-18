import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'package:bson/bson.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

//mixin ToAlias{}
//
//class BsonDocumentGeneric<T, U> {
//  Map<T, U> value;
//  BsonDocumentGeneric(this.value);
//
//  getValue(){
//    return value;
//  }
//}
//
//class BsonDocument = BsonDocumentGeneric<String, Object> with ToAlias;
//
//BsonDocument x = BsonDocument({"age": 5});
//x.getValue();

//class BsonDocument = Map<String, Object>;

// todo: maybe using 'BsonObject' instead 'dynamic'
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

  /// Parses a string in MongoDB Extended JSON format to a Document
  static MongoDocument parse(String jsonString) {
    Map<String, dynamic> map = json.decode(jsonString);

    // fix MongoDB bullshit
    map.forEach((key, value) {
      if (value is LinkedHashMap) {
        final map2 = value.entries.toList()[0];
        if (map2.key.contains("\$")) {
          switch (map2.key.substring(1)) {
            // Convert 'Int64' type
            case "numberLong":
              map[key] = int.parse(map2.value);
              break;

            // Convert 'Date' type
            case "date":
              map[key] =
                  DateTime.fromMillisecondsSinceEpoch(map2.value, isUtc: true);
              break;
          }
        }
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
    await Mongoatlasflutter._insertDocument(
      collectionName: this.collectionName,
      databaseName: this.databaseName,
      data: document.map,
    );
  }

  void insertMany(List<MongoDocument> documents) {
//    Mongoatlasflutter._insertDocument(
//      collectionName: this.collectionName,
//      databaseName: this.databaseName,
//      data: document.data,
//    );
  }

  /// FILTER ANDROID WORK!
  Future<int> deleteOne([Map<String, dynamic> filter]) async {
    // force sending an empty filter instead asserting
    if (filter == null) {
      filter = Map<String, dynamic>();
    }

    var result = await Mongoatlasflutter._deleteDocument(
      collectionName: this.collectionName,
      databaseName: this.databaseName,
      filter: BsonDocument(filter).toJson(),
    );

    return result;
  }

  /// FILTER ANDROID WORK!
  Future<int> deleteMany([Map<String, dynamic> filter]) async {
    // force sending an empty filter instead asserting
    if (filter == null) {
      filter = Map<String, dynamic>();
    }

    var result = await Mongoatlasflutter._deleteDocuments(
      collectionName: this.collectionName,
      databaseName: this.databaseName,
      filter: BsonDocument(filter).toJson(),
    );

    return result;
  }

  /// FILTER ANDROID WORK!
  Future<List<MongoDocument>> find([Map<String, dynamic> filter]) async {
    List<dynamic> resultJson = await Mongoatlasflutter._findDocuments(
      collectionName: this.collectionName,
      databaseName: this.databaseName,
      filter: BsonDocument(filter).toJson(),
    );

    var result = resultJson.map((string) {
      return MongoDocument.parse(string);
    }).toList();

    return result;
  }

  /// FILTER ANDROID WORK!
  Future<void> findOne([Map<String, dynamic> filter]) async {
    String resultJson = await Mongoatlasflutter._findFirstDocument(
      collectionName: this.collectionName,
      databaseName: this.databaseName,
      filter: BsonDocument(filter).toJson(),
    );

    var result = MongoDocument.parse(resultJson);
    return result;
  }

  /// FILTER ANDROID WORK!
  Future<int> count([Map<String, dynamic> filter]) async {
    int size = await Mongoatlasflutter._countDocuments(
      collectionName: this.collectionName,
      databaseName: this.databaseName,
      filter: BsonDocument(filter).toJson(),
    );

    return size;
  }

}

class MongoDatabase {
  final String name;

  MongoDatabase(this.name);

  MongoCollection getCollection(String collectionName) {
    return MongoCollection(
      databaseName: this.name,
      collectionName: collectionName,
    );
  }
}

class MongoAtlasClient {
  Future<void> initializeApp(String appID) async {
    await Mongoatlasflutter._connectToMongo(appID);
  }

  MongoDatabase getDatabase(String name) {
    return MongoDatabase(name);
  }
}

class Mongoatlasflutter {
  static const MethodChannel _channel =
      const MethodChannel('mongoatlasflutter');

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
