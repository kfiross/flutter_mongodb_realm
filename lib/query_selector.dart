
import 'dart:convert';

//import 'package:bson/bson.dart';

//QuerySelector get where => QuerySelector();
//
//get where => QuerySelector();

class QuerySelector {
  Map<String, dynamic> _map = <String, dynamic>{};

  // Comparison
  QuerySelector.gt(value){
    this.gt(value);
  }

  QuerySelector.gte(value){
    this.gte(value);
  }

  QuerySelector.in$(List values){
    this.in$(values);
  }

  QuerySelector.lt(value){
    this.lt(value);
  }

  QuerySelector.lte(value){
    this.lte(value);
  }


  QuerySelector.ne(value){
    this.ne(value);
  }

  QuerySelector.nin(List values){
    this.nin(values);
  }


  // Logical

//  QuerySelector.and(List values){
//    this.and(values);
//  }
//
//  QuerySelector.not(List values){
//    this.not(values);
//  }
//
//  QuerySelector.nor(List values){
//    this.nor(values);
//  }
//
//  QuerySelector.or(List values){
//    this.or(values);
//  }


  // Element
  QuerySelector.exists(){
    this.exists();
  }

  QuerySelector.notExists(){
    this.notExists();
  }

//  QuerySelector.type(){
//    this.type();
//  }

  // Evaluation
  QuerySelector.mod(int value){
    this.mod(value);
  }

  // Geospatial


  // Array
  QuerySelector.all(List values){
    this.all(values);
  }

//  QuerySelector.elemMatch(List values){
//    this.elemMatch(values);
//  }

//  QuerySelector.size(List values){
//    this.size(values);
//  }


  // Bitwise


  // Comments






  Map<String, dynamic>  get values => _map;




  //Where get where => QuerySelector();

//  String eq(String fieldName, value) {
//    _addExpression(fieldName, value);
//    return this;
//  }

//  String id(ObjectId value) {
//    _addExpression('_id', value);
//    return ;
//  }

  void _addExpression(String name, value){
    _map[name] = value;
  }

  void ne(value) {
    _addExpression("\$ne", value);


  }

  void gt(value) {
    _addExpression("\$gt", value);

  }

 void lt(value) {
    _addExpression("\$lt", value);


  }

 void gte(value) {
    _addExpression("\$gte", value);


  }

 void lte(value) {
    _addExpression("\$lte", value);


  }

 void all(List values) {
    _addExpression("\$all", values);


  }

 void nin(List values) {
    _addExpression("\$nin", values);


  }

 void in$(List values) {
    _addExpression("\$in", values);
  }

 void exists() {
    _addExpression("\$exists", true);

  }

 void notExists() {
    _addExpression("\$exists", false);
  }

 void mod(int value) {
    _addExpression("\$mod", [value, 0]);
  }
}
//
//class QuerySelector {
////  { "<Field Name>": { "<Comparison Operator>": <Comparison Value> } }
//
//  static final RegExp objectIdRegexp = RegExp(".ObjectId...([0-9a-f]{24})....");
//  Map<String, dynamic> map = {};
//  bool _isQuerySet = false;
//  Map<String, dynamic> get _query {
//    if (!_isQuerySet) {
//      map['\$query'] = <String, dynamic>{};
//      _isQuerySet = true;
//    }
//    return map['\$query'] as Map<String, dynamic>;
//  }
//
//
//  int paramSkip = 0;
//  int paramLimit = 0;
//  Map<String, dynamic> paramFields;
//
//  String toString() => "SelectorBuilder($map)";
//
//  _addExpression(String fieldName, value) {
//    Map<String, dynamic> exprMap = {};
//    exprMap[fieldName] = value;
//    if (_query.isEmpty) {
//      _query[fieldName] = value;
//    } else {
//      _addExpressionMap(exprMap);
//    }
//  }
//
//  _addExpressionMap(Map<String, dynamic> expr) {
//    if (_query.containsKey('\$and')) {
//      List expressions = _query['\$and'] as List;
//      expressions.add(expr);
//    } else {
//      var expressions = [_query];
//      expressions.add(expr);
//      map['\$query'] = {'\$and': expressions};
//    }
//  }
//
//  QuerySelector eq(String fieldName, value) {
//    _addExpression(fieldName, value);
//    return this;
//  }
//
//  QuerySelector id(ObjectId value) {
//    _addExpression('_id', value);
//    return this;
//  }
//
//  QuerySelector ne(String fieldName, value) {
//    _addExpression(fieldName, {"\$ne": value});
//    return this;
//  }
//
//  QuerySelector gt(String fieldName, value) {
//    _addExpression(fieldName, {"\$gt": value});
//    return this;
//  }
//
//  QuerySelector lt(String fieldName, value) {
//    _addExpression(fieldName, {"\$lt": value});
//    return this;
//  }
//
//  QuerySelector gte(String fieldName, value) {
//    _addExpression(fieldName, {"\$gte": value});
//    return this;
//  }
//
//  QuerySelector lte(String fieldName, value) {
//    _addExpression(fieldName, {"\$lte": value});
//    return this;
//  }
//
//  QuerySelector all(String fieldName, List values) {
//    _addExpression(fieldName, {"\$all": values});
//    return this;
//  }
//
//  QuerySelector nin(String fieldName, List values) {
//    _addExpression(fieldName, {"\$nin": values});
//    return this;
//  }
//
//  QuerySelector oneFrom(String fieldName, List values) {
//    _addExpression(fieldName, {"\$in": values});
//    return this;
//  }
//
//  QuerySelector exists(String fieldName) {
//    _addExpression(fieldName, {"\$exists": true});
//    return this;
//  }
//
//  QuerySelector notExists(String fieldName) {
//    _addExpression(fieldName, {"\$exists": false});
//    return this;
//  }
//
//  QuerySelector mod(String fieldName, int value) {
//    _addExpression(fieldName, {
//      "\$mod": [value, 0]
//    });
//    return this;
//  }
//}