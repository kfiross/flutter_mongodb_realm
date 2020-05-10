import 'dart:convert';

import 'package:extension/enum.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_mongo_stitch/database/pipeline_stage.dart';

import '../bson_document.dart';
import '../plugin.dart';
import 'mongo_document.dart';
import 'query_operator.dart';
import 'update_operator.dart';

class ProjectionValue extends Enum<int> {
  const ProjectionValue._(int val) : super(val);

  static const ProjectionValue INCLUDE = const ProjectionValue._(1);
  static const ProjectionValue EXCLUDE = const ProjectionValue._(0);
}

class OrderValue extends Enum<int> {
  const OrderValue._(int val) : super(val);

  static const OrderValue ASCENDING = const OrderValue._(1);
  static const OrderValue DESCENDING = const OrderValue._(-1);
}

/// MongoCollection provides read and write access to documents.
class MongoCollection {
  final String collectionName;
  final String databaseName;

  /// The namespace of this collection, i.e. the database and collection names together.
  String get namespace  => "$collectionName.$databaseName";

  MongoCollection({@required this.collectionName, @required this.databaseName});

  /// Inserts the provided document to the collection
  Future insertOne(MongoDocument document) async {
    await FlutterMongoStitch.insertDocument(
      collectionName: this.collectionName,
      databaseName: this.databaseName,
      data: document.map,
    );
  }

  /// Inserts one or more documents to the collection
  Future insertMany(List<MongoDocument> documents) async {
    await FlutterMongoStitch.insertDocuments(
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
    } else {
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

    var result = await FlutterMongoStitch.deleteDocument(
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
    } else {
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

    var result = await FlutterMongoStitch.deleteDocuments(
      collectionName: this.collectionName,
      databaseName: this.databaseName,
      filter: BsonDocument(filter).toJson(),
    );

    return result;
  }

  ///Finds all documents in the collection according to the given filter
  Future<List<MongoDocument>> find({filter, RemoteFindOptions options}) async {

    var filterCopy = <String, dynamic>{};
    if (filter != null) {
      assert(filter is Map<String, dynamic> || filter is LogicalQueryOperator);

      if (filter is Map<String, dynamic>) {

        // convert 'QuerySelector' into map, too
        filter?.forEach((key, value) {
          if (value is QueryOperator) {
            filterCopy[key] = value.values;
          }
          else
            filterCopy[key] = value;
        });
      }
      if (filter is LogicalQueryOperator) {
        filterCopy = filter.values;
      }
    }

    var sortMap = options.sort?.map((k, v) => MapEntry(k, v.value));
    var projectionMap = options.projection?.map((k, v) => MapEntry(k, v.value));


    List<dynamic> resultJson = await FlutterMongoStitch.findDocuments(
      collectionName: this.collectionName,
      databaseName: this.databaseName,
      filter: BsonDocument(filterCopy).toJson(),
      projection: projectionMap==null? null : jsonEncode(projectionMap),
      limit: options.limit,
      sort: sortMap==null ? null : jsonEncode(sortMap),
    );

    var result = resultJson.map((string) {
      return MongoDocument.parse(string);
    }).toList();

    return result;
  }

  /// Finds a document in the collection according to the given filter
  Future<MongoDocument> findOne({filter, Map<String, ProjectionValue> projection}) async {
    var filterCopy = <String, dynamic>{};
    if (filter != null) {
      assert(filter is Map<String, dynamic> || filter is LogicalQueryOperator);

      if (filter is Map<String, dynamic>) {

        // convert 'QuerySelector' into map, too
        filter?.forEach((key, value) {
          if (value is QueryOperator) {
            filterCopy[key] = value.values;
          }
          else
            filterCopy[key] = value;
        });
      }
      if (filter is LogicalQueryOperator) {
        filterCopy = filter.values;
      }
    }

    var projectionMap = projection?.map((k, v) => MapEntry(k, v.value));

    String resultJson = await FlutterMongoStitch.findFirstDocument(
      collectionName: this.collectionName,
      databaseName: this.databaseName,
      filter: BsonDocument(filterCopy).toJson(),
        projection: projectionMap==null? null : jsonEncode(projectionMap),
    );

    var result = MongoDocument.parse(resultJson);
    return result;
  }

  /// Counts the number of all documents in the collection.
  /// unless according to the given filter
  Future<int> count([filter]) async {
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

    int size = await FlutterMongoStitch.countDocuments(
      collectionName: this.collectionName,
      databaseName: this.databaseName,
      filter: BsonDocument(filter).toJson(),
    );

    return size;
  }

  /// Update a single document in the collection according to the
  /// specified arguments.
  Future<List> updateOne(
      {@required filter, @required UpdateOperator update}) async {
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

    var updateValues = update.values.map((key, value) {
      if (value is Map<String, dynamic>) {
        var valueNew = <String, dynamic>{};
        valueNew.addAll(value);

        valueNew.forEach((key2, value2) {
          if (value2 is ArrayModifier) {
            valueNew[key2] = value2.values;
          } else if (value2 is QueryOperator) {
            valueNew[key2] = value2.values;
          }
        });

        return MapEntry<String, dynamic>(key, valueNew);
      }
      return MapEntry<String, dynamic>(key, value);
    });

    List results = await FlutterMongoStitch.updateDocument(
      collectionName: this.collectionName,
      databaseName: this.databaseName,
      filter: BsonDocument(filter).toJson(),
      update: BsonDocument(updateValues).toJson(),
    );

    return results;
  }

  /// Update all documents in the collection according to the
  /// specified arguments.
  Future<List<int>> updateMany(
      {@required filter, @required UpdateOperator update}) async {
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

    List<int> results = await FlutterMongoStitch.updateDocuments(
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
    var stream = FlutterMongoStitch.watchCollection(
      collectionName: this.collectionName,
      databaseName: this.databaseName,
    );

    return stream;
  }

  /// Watches a collection. The provided BSON document will be used as a match
  /// expression filter on the change events coming from the stream.
  Stream watchWithFilter(Map<String, dynamic> filter) {
    // convert 'QuerySelector' into map, too
    filter.forEach((key, value) {
      if (value is QueryOperator) {
        filter[key] = value.values;
      }
    });

    var stream = FlutterMongoStitch.watchCollection(
      collectionName: this.collectionName,
      databaseName: this.databaseName,
      filter: BsonDocument(filter).toJson(),
    );

    return stream;
  }


  ///
  Future<List<MongoDocument>> aggregate(List<PipelineStage> pipeline) async{
    List<dynamic> resultJson = await FlutterMongoStitch.aggregate(
      collectionName: this.collectionName,
      databaseName: this.databaseName,
      pipeline: pipeline.map((doc) => jsonEncode(doc.values)).toList(),
    );

    var result = resultJson.map((string) {
      return MongoDocument.parse(string);
    }).toList();

    return result;
  }
}

class RemoteFindOptions{
  final int limit;
  final Map<String, ProjectionValue> projection;
  final Map<String, OrderValue> sort;

  RemoteFindOptions({this.limit, this.projection, this.sort});
}