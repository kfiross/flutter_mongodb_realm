import 'dart:collection';

import 'dart:convert';

import 'package:bson/bson.dart';

/// A representation of a document as a Map
class MongoDocument {
  final Map<String, Object?> _map = LinkedHashMap<String, Object>();

  Map<String, Object?> get map => _map;

  /// Create a Document instance initialized with the given key/value pair.
  MongoDocument.single(String key, dynamic value) {
    _map[key] = value;
  }

  /// Creates a Document instance initialized with the given map.
  /// or an empty Document instance if not provided.
  MongoDocument(Map<String, Object?>? map) {
    if (map != null) {
      //_map.addAll(map);
      //_map.addEntries(map.entries);
      for (String key in map.keys) {
        _map[key] = map[key];
      }
    }
  }

  get(String key) {
    return _map[key];
  }

  static fixMapMismatchedTypes(Map map) {
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
            result =
                DateTime.fromMillisecondsSinceEpoch(map2[0].value, isUtc: true);
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
  static MongoDocument parse(data) {
    Map<String, dynamic> map = json.decode(data);

    map.forEach((key, value) {
      if (value is LinkedHashMap || value is Map) {
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
