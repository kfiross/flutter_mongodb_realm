
import '../find_iterable.dart';
import '../mongo_collection.dart';

extension MongoCollectionX on MongoCollection{
  FindIterable findIterable(){
    return FindIterable(this);
  }
}