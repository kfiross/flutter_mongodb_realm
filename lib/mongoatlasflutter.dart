import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class BsonDocument {}

class MongoDocument {
  Map<String, Object> _data;

  Map<String, Object> get data => _data;

  void append(String key, Object value) {
    _data[key] = value;
  }

  static MongoDocument fromMap(Map<String, Object> map) {
    var doc = MongoDocument();
    doc._data = Map<String, Object>();
    doc._data.addAll(map);

    return doc;
  }

  static MongoDocument fromJson(String jsonString) {
    Map<String, dynamic> map = json.decode(jsonString);

    // fix MongoDB bullshit
    map.forEach((key, value) {
      if (value is LinkedHashMap){
        final map2 = value.entries.toList()[0];
        if (map2.key.contains("\$")){
          switch (map2.key.substring(1)){
            case "numberLong":
              map[key] =  int.parse(map2.value);
          }
        }
      }
    });

    return MongoDocument.fromMap(map);
  }
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
      data: document.data,
    );
  }

  void insertMany(List<MongoDocument> documents) {
//    Mongoatlasflutter._insertDocument(
//      collectionName: this.collectionName,
//      databaseName: this.databaseName,
//      data: document.data,
//    );
  }


  Future<bool> deleteOne(BsonDocument filter) async {
    assert(filter != null);

    var result = await Mongoatlasflutter._deleteDocument(
      collectionName: this.collectionName,
      databaseName: this.databaseName,
      //filter: filter,
    );

    return result;
  }

  void deleteMany(BsonDocument filter) {
    assert(filter != null);
  }


  /// DONE!
  Future<List<MongoDocument>> find({BsonDocument filter}) async {
    List<dynamic> resultJson = await Mongoatlasflutter._findDocuments(
      collectionName: this.collectionName,
      databaseName: this.databaseName,
      filter: filter,
    );

    var result = resultJson.map((string) {
      return MongoDocument.fromJson(string);
    }).toList();

    return result;
  }

  ///        collection?.find()
  ///        collection?.find(filter)
  ///        collection?.find(null)

  /// DONE!
  Future<void> findOne({BsonDocument filter}) async {
    String resultJson = await Mongoatlasflutter._findFirstDocument(
      collectionName: this.collectionName,
      databaseName: this.databaseName,
      filter: filter,
    );

    var result = MongoDocument.fromJson(resultJson);
    return result;
  }

  ///        collection?.findOne()
  ///        collection?.findOne(filter)
  ///        collection?.findOne(null)

  /// DONE!
  Future<int> count({BsonDocument filter}) async {
    int size = await Mongoatlasflutter._countDocuments(
      collectionName: this.collectionName,
      databaseName: this.databaseName,
      filter: null, //document.data,
    );

    return size;
  }

  ///        collection?.count()
  ///        collection?.count(filter)
  ///        collection?.count(null)

//  collection?.insertOne(Document())
//  collection?.insertMany(listOf(Document(), Document(), Document()))
//

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
}
