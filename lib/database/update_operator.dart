import 'package:extension/extension.dart';

class PopValue extends Enum<int> {
  const PopValue(int val) : super(val);

  static const PopValue LAST = const PopValue(1);
  static const PopValue FIRST = const PopValue(-1);
}
//import 'package:bson/bson.dart';

//UpdateSelector get where => UpdateSelector();
//
//get where => UpdateSelector();

class UpdateOperator {
  Map<String, dynamic> _map = <String, dynamic>{};

  Map<String, dynamic> get values => _map;

  void _addExpression(String name, value) {
    _map[name] = value;
  }

  // Fields

//  UpdateSelector.currentDate(Map<String, dynamic> value){
//    this.currentDate(value);
//  }

  UpdateOperator.inc(Map<String, num> values) {
    this.inc(values);
  }

  UpdateOperator.min(Map<String, dynamic> values) {
    this.min(values);
  }

  UpdateOperator.max(Map<String, dynamic> values) {
    this.max(values);
  }

  UpdateOperator.mul(Map<String, num> values) {
    this.mul(values);
  }

  UpdateOperator.rename(Map<String, String> values) {
    this.rename(values);
  }

  UpdateOperator.set(Map<String, dynamic> value) {
    this.set(value);
  }

  UpdateOperator.unset(List<String> fields) {
    this.unset(fields);
  }

  // Array
  UpdateOperator.pop(Map<String, PopValue> values) {
    this.pop(values);
  }

  UpdateOperator.pull(Map<String, dynamic> values) {
    this.pull(values);
  }

  UpdateOperator.push(Map<String, ArrayModifier> values) {
    this.push(values);
  }

  UpdateOperator.pullAll(Map<String, List<dynamic>> values) {
    this.pullAll(values);
  }

  ///

  void set(Map<String, dynamic> value) {
    _addExpression("\$set", value);
  }

  void rename(Map<String, String> values) {
    _addExpression("\$rename", values);
  }

  void unset(List<String> fields) {
    var map = {};
    fields.forEach((f) {
      map[f] = "";
    });
    _addExpression("\$unset", map);
  }

  void inc(Map<String, num> values) {
    _addExpression("\$inc", values);
  }

  void min(Map<String, dynamic> map) {
    // map's values can be only a num or a DateTime
    map.values.forEach((value) {
      assert(!(value is num || value is DateTime));
    });

    _addExpression("\$min", map);
  }

  void max(Map<String, dynamic> map) {
    // map's values can be only a num or a DateTime
    map.values.forEach((value) {
      assert((value is double || value is DateTime));
    });

    _addExpression("\$max", map);
  }

  void mul(Map<String, num> map) {
    _addExpression("\$mul", map);
  }

  void pop(Map<String, PopValue> map) {
    _addExpression("\$pop",
        map.map((key, value) => MapEntry<String, int>(key, value.value)));
  }

  void push(Map<String, ArrayModifier> map) {
    _addExpression("\$push", map);
  }

  void pull(Map<String, dynamic> map) {
    _addExpression("\$pull", map);
  }

  void pullAll(Map<String, List<dynamic>> map) {
    _addExpression("\$pullAll", map);
  }
}

/// ////////////////////////////////////////////////////////

class SortValue extends Enum<int> {
  const SortValue(int val) : super(val);

  static const SortValue ASC = const SortValue(1);
  static const SortValue DSC = const SortValue(-1);
}

class ArrayModifier {
  Map<String, dynamic> _map = <String, dynamic>{};

  Map<String, dynamic> get values => _map;

  void _addExpression(String name, value) {
    _map[name] = value;
  }

  ArrayModifier.each(List<dynamic> values) {
    this.each(values);
  }

  ArrayModifier.sort(Map<String, SortValue> values) {
    this.sort(values);
  }

  ArrayModifier.slice(int value) {
    this.slice(value);
  }

  ArrayModifier.position(int value) {
    this.position(value);
  }

  void each(List<dynamic> values) {
    _addExpression("\$each", values);
  }

  void sort(Map<String, SortValue> values) {
    _addExpression("\$sort", values);
  }

  void slice(int value) {
    _addExpression("\$slice", value);
  }

  void position(int position) {
    _addExpression("\$position", position);
  }
}
