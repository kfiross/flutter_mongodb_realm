import 'reflector.dart';

@RealmClass
abstract class RealmObject{

}

@RealmClass
class RealmList<T> {
  final List<T> items;

  RealmList([this.items = const []]);
}