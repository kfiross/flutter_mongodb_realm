import 'package:bson/bson.dart';

import '../plugin.dart';
import 'realm_sync.dart';
import 'reflector.dart' hide MyReflector;
import '../bson_document.dart';

part 'annotations.dart';

class Realm{
  SyncConfiguration config;

  Realm._(this.config);

  static Realm getInstance(SyncConfiguration config){
    return Realm._(config);
  }

  Future<void> addOne(RealmObject object,{bool update = true}) async{
    await FlutterRealm.addOne(object, config.partition, update);
  }

  Future<void> add(List<RealmObject> objects, {bool update = true}) async{
    // todo: fix it with addAll
    for(var object in objects) {
      await FlutterRealm.addOne(object, config.partition, update);
    }
  }

  Future<bool> deleteOne<T extends RealmObject>() async{
    return FlutterRealm.delete(T.runtimeType, config.partition, false);
  }

  Future<bool> deleteAll<T extends RealmObject>() async{
    return FlutterRealm.delete(T.runtimeType, config.partition, true);
  }

  void refresh(){

  }


  /// Returns a typed RealmQuery, which can be used to query for specific
  /// objects of this type
  RealmQuery where<T extends RealmObject>(){
    return RealmQuery(T);
  }

  static void deleteRealm(SyncConfiguration configuration){

  }

  static Map toJson<T extends RealmObject>(T value) {
    var primaryKeys = 0;
    var result = {};

    var im = RealmClass.reflect(value);
    var classMirror = im.type;

    for (var ve in classMirror.declarations.entries) {
      var v = ve.value;
      var key = ve.key;

      for (var metadata in v.metadata) {
        if(metadata is _PrimaryKey){
          primaryKeys++;
          if(primaryKeys == 2){
            throw Exception();
          }
          var value = im.invokeGetter(key);
          if(value is ObjectId) {
            result['_id'] = value.toHexString();//toJsonOid();
          }
          if (value is String){
            result['_id'] = value;
          }
        }
        else if (metadata is MapTo) {
          var name = metadata.name;
          result[name] = im.invokeGetter(key);
        }

      }
    }

    if(primaryKeys == 0){
      throw Exception();
    }
    return result;
  }
}