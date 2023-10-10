import 'mongo_collection.dart';
import 'mongo_document.dart';

class MongoIterable {
  final MongoCollection collection;

  MongoIterable(this.collection);
}

class FindIterable extends MongoIterable {

  RemoteFindOptions _options = RemoteFindOptions();
  Map<String, dynamic>? _filter;

  FindIterable(MongoCollection collection) : super(collection);

  RemoteFindOptions get options => _options;

  FindIterable filter(Map<String, dynamic> filter){
    this._filter = filter;
    return this;
  }

  FindIterable limit(int limit){
    this._options = this._options.copyWith(limit: limit);
    return this;
  }

  FindIterable projection(Map<String, ProjectionValue> projection){
    this._options = this._options.copyWith(projection: projection);
    return this;
  }

  FindIterable sort(Map<String, OrderValue>? sort){
    this._options = this._options.copyWith(sort: sort);
    return this;
  }

  Future<List<MongoDocument>> find() async {
    return collection.find(filter: _filter, options: _options);
  }
}

