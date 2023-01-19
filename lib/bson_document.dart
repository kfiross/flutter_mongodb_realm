import 'dart:convert';
import 'package:bson/bson.dart' show ObjectId;

/// Extensions for ObjectId
extension ObjectIdExtentions on ObjectId? {
  /// Correct supported json format
  toJsonOid() => {"\$oid": "${this!.toHexString()}"};
}

// TODO: maybe using 'BsonObject' instead 'dynamic'
class BsonDocument {
  final Map<String, dynamic>? _map;

  Map<String, dynamic>? get map => _map;

  /// Creates a document instance initialized with the given map.
  /// or an empty Document instance if not provided.
  const BsonDocument([this._map]);

  String toJson() {
    if (_map == null) {
      return jsonEncode({});
    }

    var __map = <String, dynamic>{};
    for (var entry in _map!.entries) {
      if (entry.value is ObjectId)
        __map[entry.key] = (entry.value as ObjectId).toJsonOid();
      else if (entry.value is Map) {
        for (var entry2 in (entry.value as Map).entries) {
          __map[entry.key] = {};
          if (entry2.value is ObjectId) {
            __map[entry.key][entry2.key] =
                (entry2.value as ObjectId).toJsonOid();
          } else if (entry2.value is Map) {
            __map[entry.key][entry2.key] = {};
            for (var entry3 in (entry2.value as Map).entries) {
              if (entry3.value is ObjectId) {
                __map[entry.key][entry2.key][entry3.key] =
                    (entry3.value as ObjectId).toJsonOid();
              }
              if (entry3.value is List) {
                final list = (entry3.value as List);
                __map[entry.key][entry2.key][entry3.key] =
                    List.filled(list.length, Object());
                for (int index = 0; index < list.length; index++) {
                  if (list[index] is ObjectId) {
                    __map[entry.key][entry2.key][entry3.key][index] =
                        (list[index].value as ObjectId?)!.toJsonOid();
                  } else {
                    __map[entry.key][entry2.key][entry3.key][index] =
                        list[index];
                  }
                }
              } else {
                __map[entry.key][entry2.key][entry3.key] = entry3.value;
              }
            }
          } else {
            __map[entry.key][entry2.key] = entry2.value;
          }
        }
      } else {
        __map[entry.key] = entry.value;
      }
    }

    return jsonEncode(__map);
  }
}
