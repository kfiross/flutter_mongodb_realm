class LogicalQueryOperator {
  Map<String, dynamic> _map = <String, dynamic>{};

  Map<String, dynamic> get values => _map;

  static LogicalQueryOperator or(List<Map<String, dynamic>> values) {
    LogicalQueryOperator op = LogicalQueryOperator();

    // convert QuerySelector to map, too
    values.forEach((element) {
      element.forEach((key, value) {
        if (value is QueryOperator) {
          element[key] = value.values;
        }
      });
    });
    op._map["\$or"] = values;

    return op;
  }

  static LogicalQueryOperator and(List<Map<String, dynamic>> values) {
    LogicalQueryOperator op = LogicalQueryOperator();

    // convert QuerySelector to map, too
    values.forEach((element) {
      element.forEach((key, value) {
        if (value is QueryOperator) {
          element[key] = value.values;
        }
      });
    });
    op._map["\$and"] = values;

    return op;
  }
}

class QueryOperator {
  Map<String, dynamic> _map = <String, dynamic>{};

  // Comparison
  QueryOperator.gt(value) {
    this.gt(value);
  }

  QueryOperator.gte(value) {
    this.gte(value);
  }

  QueryOperator.in$(List values) {
    this.in$(values);
  }

  QueryOperator.lt(value) {
    this.lt(value);
  }

  QueryOperator.lte(value) {
    this.lte(value);
  }

  QueryOperator.ne(value) {
    this.ne(value);
  }

  QueryOperator.nin(List values) {
    this.nin(values);
  }

  // Logical

  static LogicalQueryOperator and(List<Map<String, dynamic>> values) {
    return LogicalQueryOperator.and(values);
  }

//
//  QueryOperation.not(List values){
//    this.not(values);
//  }
//
//  QueryOperation.nor(List values){
//    this.nor(values);
//  }
//
  static LogicalQueryOperator or(List<Map<String, dynamic>> values) {
    return LogicalQueryOperator.or(values);
  }

  // Element
  QueryOperator.exists() {
    this.exists();
  }

  QueryOperator.notExists() {
    this.notExists();
  }

//  QuerySelector.type(){
//    this.type();
//  }

  // Evaluation
  QueryOperator.mod(int value) {
    this.mod(value);
  }

  // Geospatial

  // Array
  QueryOperator.all(List values) {
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

  Map<String, dynamic> get values => _map;

  //Where get where => QuerySelector();

//  String eq(String fieldName, value) {
//    _addExpression(fieldName, value);
//    return this;
//  }

//  String id(ObjectId value) {
//    _addExpression('_id', value);
//    return ;
//  }

  void _addExpression(String name, value) {
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
