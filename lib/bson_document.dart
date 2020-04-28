import 'dart:convert';

// TODO: maybe using 'BsonObject' instead 'dynamic'
class BsonDocument {
  final Map<String, dynamic> _map;

  Map<String, dynamic> get map => _map;

  /// Creates a document instance initialized with the given map.
  /// or an empty Document instance if not provided.
  const BsonDocument([this._map]);

  String toJson() => jsonEncode(_map ?? Map<String, dynamic>());
}
