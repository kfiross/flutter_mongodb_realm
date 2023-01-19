class PipelineStage {
  Map<String, dynamic> _map = <String, dynamic>{};

  PipelineStage.addFields(Map<String, dynamic> fields) {
    _addExpression("\$addFields", fields);
  }

  PipelineStage.match(Map<String, dynamic> query) {
    _addExpression("\$match", query);
  }

  PipelineStage.group(String groupByField,
      {required Map<String, dynamic> accumulators}) {
    var map = <String, dynamic>{
      "_id": "\$$groupByField",
    };
    map.addAll(accumulators);

    _addExpression("\$group", map);
  }

  PipelineStage.skip(int size) {
    _addExpression("\$skip", num);
  }

  PipelineStage.sample(int size) {
    _addExpression("\$sample", {"size": size});
  }

  PipelineStage.limit(int size) {
    _addExpression("\$skip", num);
  }

  // especial for free-writing stage
  PipelineStage.raw(Map<String, dynamic> map) {
    _map.addAll(map);
  }

  Map<String, dynamic> get values => _map;

  void _addExpression(String name, value) {
    _map[name] = value;
  }

  void addFields(Map<String, dynamic> fields) {}

  void match(Map<String, dynamic> query) {}

  void group(String groupByField, Map<String, dynamic> accumulators) {}

  void skip(int num) {}

  void sample(int num) {}
}

class AggregateOperator {
  static Map<String, dynamic> sum(String field) {
    return {"\$sum": "\$$field"};
  }

  static Map<String, dynamic> add(List<String> fields) {
    return {"\$add": fields.map((f) => "\$$f").toList()};
  }
}
