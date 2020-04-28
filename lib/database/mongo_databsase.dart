import 'mongo_collection.dart';

/// MongoDatabase provides access to its [MongoCollection]s.
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
