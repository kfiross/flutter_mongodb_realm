import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mongo_stitch/update_operator.dart';
import 'package:streams_channel/streams_channel.dart';

import 'query_operator.dart';
import 'bson_document.dart';
import 'mongo_document.dart';

export 'query_operator.dart';
export 'update_operator.dart';
export 'mongo_document.dart';



/// MongoCollection provides read and write access to documents.
class MongoCollection {
  final String collectionName;
  final String databaseName;

  MongoCollection({@required this.collectionName, @required this.databaseName});

  /// Inserts the provided document to the collection
  Future insertOne(MongoDocument document) async {
    await FlutterMongoStitch._insertDocument(
      collectionName: this.collectionName,
      databaseName: this.databaseName,
      data: document.map,
    );
  }

  /// Inserts one or more documents to the collection
  void insertMany(List<MongoDocument> documents) {
    FlutterMongoStitch._insertDocuments(
      collectionName: this.collectionName,
      databaseName: this.databaseName,
      list: documents.map((doc) => jsonEncode(doc.map)).toList(),
    );
  }

  /// Removes at most one document from the collection that matches the given
  /// filter. If no documents match, the collection is not modified.
  Future<int> deleteOne([filter]) async {
    // force sending an empty filter instead asserting
    if (filter == null) {
      filter = Map<String, dynamic>();
    }
    else{
      assert(filter is Map<String, dynamic> || filter is LogicalQueryOperator);

      if (filter is Map<String, dynamic>) {

        // convert 'QuerySelector' into map, too
        filter?.forEach((key, value) {
          if (value is QueryOperator) {
            filter[key] = value.values;
          }
        });
      }
      if (filter is LogicalQueryOperator){
        filter = filter.values;
      }
    }

    var result = await FlutterMongoStitch._deleteDocument(
      collectionName: this.collectionName,
      databaseName: this.databaseName,
      filter: BsonDocument(filter).toJson(),
    );

    return result;
  }


  /// Removes all documents from the collection that matches the given
  /// filter. If no documents match, the collection is not modified.
  Future<int> deleteMany([filter]) async {
    // force sending an empty filter instead asserting
    if (filter == null) {
      filter = Map<String, dynamic>();
    }
    else {
      assert(filter is Map<String, dynamic> || filter is LogicalQueryOperator);

      if (filter is Map<String, dynamic>) {

        // convert 'QuerySelector' into map, too
        filter?.forEach((key, value) {
          if (value is QueryOperator) {
            filter[key] = value.values;
          }
        });
      }
      if (filter is LogicalQueryOperator){
        filter = filter.values;
      }
    }


    var result = await FlutterMongoStitch._deleteDocuments(
      collectionName: this.collectionName,
      databaseName: this.databaseName,
      filter: BsonDocument(filter).toJson(),
    );

    return result;
  }


  ///Finds all documents in the collection according to the given filter
  Future<List<MongoDocument>> find([filter])async {

    if (filter != null) {
      assert(filter is Map<String, dynamic> || filter is LogicalQueryOperator);

      if (filter is Map<String, dynamic>) {
        // convert 'QuerySelector' into map, too
        filter?.forEach((key, value) {
          if (value is QueryOperator) {
            filter[key] = value.values;
          }
        });
      }
      if (filter is LogicalQueryOperator) {
        filter = filter.values;
      }
    }


    List<dynamic> resultJson = await FlutterMongoStitch._findDocuments(
      collectionName: this.collectionName,
      databaseName: this.databaseName,
      filter: BsonDocument(filter).toJson(),
    );

    var result = resultJson.map((string) {
      return MongoDocument.parse(string);
    }).toList();

    return result;
  }

  /// Finds a document in the collection according to the given filter
  Future<void> findOne([filter]) async {

    if (filter != null) {
      assert(filter is Map<String, dynamic> || filter is LogicalQueryOperator);

      if (filter is Map<String, dynamic>) {
        // convert 'QuerySelector' into map, too
        filter?.forEach((key, value) {
          if (value is QueryOperator) {
            filter[key] = value.values;
          }
        });
      }
      if (filter is LogicalQueryOperator) {
        filter = filter.values;
      }

    }

    String resultJson = await FlutterMongoStitch._findFirstDocument(
        collectionName: this.collectionName,
        databaseName: this.databaseName,
        filter: BsonDocument(filter).toJson(),
    );


    var result = MongoDocument.parse(resultJson);
    return result;
  }

  /// Counts the number of all documents in the collection.
  /// unless according to the given filter
  Future<int> count([filter]) async {
    if (filter!=null) {
      assert(filter is Map<String, dynamic> || filter is LogicalQueryOperator);

      if (filter is Map<String, dynamic>) {
        // convert 'QuerySelector' into map, too
        filter?.forEach((key, value) {
          if (value is QueryOperator) {
            filter[key] = value.values;
          }
        });
      }
      if (filter is LogicalQueryOperator) {
        filter = filter.values;
      }
    }

    int size = await FlutterMongoStitch._countDocuments(
      collectionName: this.collectionName,
      databaseName: this.databaseName,
      filter: BsonDocument(filter).toJson(),
    );

    return size;
  }

  /// Update a single document in the collection according to the
  /// specified arguments.
  Future<List> updateOne({@required filter, @required UpdateOperator update}) async {
    assert(filter is Map<String, dynamic> || filter is LogicalQueryOperator);

    if (filter is Map<String, dynamic>) {

      // convert 'QuerySelector' into map, too
      filter?.forEach((key, value) {
        if (value is QueryOperator) {
          filter[key] = value.values;
        }
      });
    }
    if (filter is LogicalQueryOperator){
      filter = filter.values;
    }


    var updateValues = update.values.map((key, value) {
      if (value is Map<String, dynamic>) {
        var valueNew = <String, dynamic>{};
        valueNew.addAll(value);

        valueNew.forEach((key2, value2) {
          if (value2 is ArrayModifier) {
            valueNew[key2] = value2.values;
          }

          else if (value2 is QueryOperator) {
            valueNew[key2] = value2.values;
          }
        });

        return MapEntry<String, dynamic>(key, valueNew);
      }
      return MapEntry<String, dynamic>(key, value);
    });


    List results = await FlutterMongoStitch._updateDocument(
      collectionName: this.collectionName,
      databaseName: this.databaseName,
      filter: BsonDocument(filter).toJson(),
      update: BsonDocument(updateValues).toJson(),
    );

    return results;
  }

  /// Update all documents in the collection according to the
  /// specified arguments.
  Future<List<int>> updateMany({@required filter, @required UpdateOperator update}) async {
    assert(filter is Map<String, dynamic> || filter is LogicalQueryOperator);

    if (filter is Map<String, dynamic>) {

      // convert 'QuerySelector' into map, too
      filter?.forEach((key, value) {
        if (value is QueryOperator) {
          filter[key] = value.values;
        }
      });
    }
    if (filter is LogicalQueryOperator){
      filter = filter.values;
    }


    List<int> results = await FlutterMongoStitch._updateDocuments(
      collectionName: this.collectionName,
      databaseName: this.databaseName,
      filter: BsonDocument(filter).toJson(),
      update: BsonDocument(update.values).toJson(),
    );

    return results;
  }

  /// Watches a collection. The resulting stream will be notified of all events
  /// on this collection that the active user is authorized to see based on the
  /// configured MongoDB rules.
  Stream watch() {
    var stream = FlutterMongoStitch._watchCollection(
      collectionName: this.collectionName,
      databaseName: this.databaseName,
    );

    return stream;
  }


  // TODO: need to be checked!
  /// Watches a collection. The provided BSON document will be used as a match
  /// expression filter on the change events coming from the stream.
  Stream watchWithFilter(Map<String, dynamic> filter) {
    // convert 'QuerySelector' into map, too
    filter.forEach((key, value) {
      if (value is QueryOperator) {
        filter[key] = value.values;
      }
    });

    var stream = FlutterMongoStitch._watchCollection(
      collectionName: this.collectionName,
      databaseName: this.databaseName,
      filter: BsonDocument(filter).toJson(),
    );

    return stream;

  }


}

/// MongoDatabase provides access to its 'MongoCollection'-s.
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

/// A StitchCredential provides a Stitch client the information needed to log
/// in or link a user with an identity.
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

/// MongoStitchAuth manages authentication for any Stitch based client.
class MongoStitchAuth {

  /// Logs in as a user with the given credentials associated with an
  /// authentication provider.
  Future<CoreStitchUser> loginWithCredential(StitchCredential credential) async {
    var result;

    if (credential is AnonymousCredential) {
      result = await FlutterMongoStitch._signInAnonymously();
    } else if (credential is UserPasswordCredential) {
      result = await FlutterMongoStitch._signInWithUsernamePassword(
        credential.username,
        credential.password,
      );
    } else {
      throw UnimplementedError();
    }

    return result;
  }

  Future<bool> logout() async {
    var result = await FlutterMongoStitch._logout();
    return result;
  }

  Future<bool> getUserId() async {
    var result = await FlutterMongoStitch._getUserId();
    return result;
  }

  Future<bool> registerWithEmail({@required String email,@required String password}) async {
    var result = await FlutterMongoStitch._registerWithEmail(email, password);
    return result;
  }
}

/// A user that belongs to a MongoDB Stitch application.
class CoreStitchUser{
  final String id;
  final String deviceId;


  CoreStitchUser({@required this.id, @required this.deviceId});
//  final String loggedInProviderType;
//  final String loggedInProviderName;
  //final StitchUserProfileImpl profile;
//  final bool isLoggedIn;
//  final DateTime lastAuthActivity;

  static fromMap(Map<String, dynamic> map){
    return CoreStitchUser(
      id: map["id"],
      deviceId: map["device_id"]
    );
  }
}

/// The MongoStitchClient is the entry point for working with data in MongoDB
/// remotely via Stitch.
class MongoStitchClient {
  final MongoStitchAuth auth = MongoStitchAuth();

  static Future initializeApp(String appID) async {
    await FlutterMongoStitch._connectToMongo(appID);
  }

  MongoDatabase getDatabase(String name) {
    return MongoDatabase(name);
  }
}

class FlutterMongoStitch {
  static const MethodChannel _channel =
      const MethodChannel('flutter_mongo_stitch');

  static StreamsChannel _streamsChannel = StreamsChannel('streams_channel_test');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }


  static Future _connectToMongo(String appId) async {
    await _channel.invokeMethod('connectMongo', {'app_id': appId});
  }

  static Future<CoreStitchUser> _signInWithUsernamePassword(
      String username, String password) async {
    final LinkedHashMap result = await _channel.invokeMethod('signInWithUsernamePassword',
        {'username': username, 'password': password});

    var map = <String, dynamic>{};
    result.forEach((key, value) {
      map[key] = value;
    });

    return CoreStitchUser.fromMap(map);
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

  static Future _countDocuments(
      {String collectionName, String databaseName, dynamic filter}) async {
    final size = await _channel.invokeMethod('countDocuments', {
      'database_name': databaseName,
      'collection_name': collectionName,
      'filter': filter
    });

    return size;
  }

  ///
  static Future _updateDocument(
      {String collectionName,
        String databaseName,
        String filter,
        String update}) async {
    final results = await _channel.invokeMethod('updateDocument', {
      'database_name': databaseName,
      'collection_name': collectionName,
      'filter': filter,
      'update': update
    });

    return results;
  }

  static Future _updateDocuments(
      {String collectionName,
       String databaseName,
       String filter,
       String update}) async {
    final results = await _channel.invokeMethod('updateDocuments', {
      'database_name': databaseName,
      'collection_name': collectionName,
      'filter': filter,
      'update': update
    });

    return results;
  }


  static Stream _watchCollection(
      {@required String collectionName, @required String databaseName, String filter,}) {

    // continuous stream of events from platform side
    return _streamsChannel.receiveBroadcastStream({
      "db": databaseName,
      "collection": collectionName,
      "filter": filter
    });
  }
}
