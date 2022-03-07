// ignore_for_file: deprecated_member_use

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_mongodb_realm/bson_document.dart';
import 'package:flutter_mongodb_realm/flutter_mongo_realm.dart';
import 'package:sprintf/sprintf.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final client = MongoRealmClient();
  final app = RealmApp();
  var _students = <Student>[];

  MongoCollection? _collection;

  final _filterOptions = <String>[
    "firstName",
    "lastName",
    "year",
    // "grades",
  ];

  final _operatorsOptions = <String>[
    ">",
    ">=",
    "<",
    "<=",
    "==",
//    "between"
  ];

  String? _selectedFilter;
  String? _selectedOperator;
  var _selectedValueForFilterCtrler = TextEditingController();

  //
  final formKey = GlobalKey<FormState>();
  String? _newStudFirstName;
  String? _newStudLastName;
  int? _newStudYear;

  @override
  void initState() {
    super.initState();

//   client.callFunction("sum", args: [3, 4]).then((value) {
//     print(value);
//   });
  }

  @override
  void dispose() {
    _selectedValueForFilterCtrler.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();

    _collection ??= client.getDatabase("test").getCollection("students");
    try {
      await _fetchStudents();
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Home Screen"),
          actions: <Widget>[
            FlatButton(
              child: Icon(Icons.refresh, color: Colors.white),
              onPressed: _fetchStudents,
            ),
            FlatButton(
              child: Icon(Icons.exit_to_app, color: Colors.white),
              onPressed: () async {
                try {
                  if (!kIsWeb) {
                    final fbLogin = FacebookAuth.i;
                    final fbToken = await fbLogin.accessToken;

                    bool loggedAsFacebook = fbToken != null;
                    if (loggedAsFacebook) {
                      await fbLogin.logOut();
                    }
                  }
                } catch (e) {}

                await app.logout();
              },
            )
          ],
        ),
        body: Container(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: <Widget>[
              _filterRow(),
              SizedBox(height: 20),
              _header(),
              _studentsListStreamBuilder(),
              //_studentsList(),
            ],
          ),
        ),
        bottomSheet: Container(
          margin: const EdgeInsets.only(bottom: 4),
          child: Form(
            key: formKey,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    decoration: InputDecoration(labelText: 'First Name'),
                    autocorrect: false,
                    validator: (val) =>val!=null && val.isEmpty ? "can't be empty." : null,
                    onSaved: (val) => _newStudFirstName = val ?? "",
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    decoration: InputDecoration(labelText: 'Last Name'),
                    autocorrect: false,
                    validator: (val) => val!=null && val.isEmpty ? "can't be empty." : null,
                    onSaved: (val) => _newStudLastName = val ?? "",
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  flex: 1,
                  child: TextFormField(
                    decoration: InputDecoration(labelText: 'Year'),
                    autocorrect: false,
                    validator: (val) => val !=null && val.isEmpty ? "can't be empty." : null,
                    onSaved: (val) {
                      if(val !=null) {
                        _newStudYear = int.parse(val);
                      }
                    },
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: RaisedButton(
                      child: Text("Add"), onPressed: _insertNewStudent),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
              flex: 2,
              child: Text(
                "Name",
                style: TextStyle(fontWeight: FontWeight.bold),
              )),
          Expanded(
              flex: 1,
              child:
                  Text("Year", style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(
              flex: 1,
              child: Text("Grades Avg.",
                  style: TextStyle(fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  Widget _studentsListStreamBuilder(){
    return StreamBuilder(
      stream: _collection?.watch(),
      builder: (context, snapshot){
        if(snapshot.data == null){
          return const SizedBox.shrink();
        }
        // print(snapshot.data);
        // return const SizedBox.shrink();

        return FutureBuilder<List<MongoDocument>>(
          future: _collection?.find(),
          builder: (BuildContext _, AsyncSnapshot<List<MongoDocument>> snapshot2) {

            if(snapshot.data == null)
              return const SizedBox.shrink();

          _students.clear();
          var documents = snapshot2.data;
          documents?.forEach((document) {
            _students.add(Student.fromDocument(document));
          });

          return _studentsList();
        },);
      },
    );
    // final list = _students.map((s) {
    //   return StudentItem(s, () async{
    //     var docDeleted = await _collection?.deleteOne({
    //       "_id": s.id,
    //     });
    //     print("deleted docs: $docDeleted");
    //   });
    // }).toList();

    // if(list.isEmpty){
    //   return const SizedBox.shrink();
    // }
    //
    // return Expanded(child: ListView.builder(
    //   itemBuilder: (context, index) => list[index],
    //   itemCount: list.length,
    // ));
  }

  Widget _studentsList(){
    final list = _students.map((s) {
      return StudentItem(s, () async{
        var docDeleted = await _collection?.deleteOne({
          "_id": s.id,
        });
        print("deleted docs: $docDeleted");
      });
    }).toList();

    if(list.isEmpty){
      return const SizedBox.shrink();
    }

    return Expanded(child: ListView.builder(
      itemBuilder: (context, index) => list[index],
      itemCount: list.length,
    ));
  }

  _filterRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        DropdownButton<String>(
          value: _selectedFilter,
          items: _filterOptions
              .map((name) => DropdownMenuItem<String>(
                    value: name,
                    child: Text(name),
                  ))
              .toList(),
          onChanged: (value) {
            setState(() {
              _selectedFilter = value;
            });
          },
        ),
        SizedBox(width: 20),
        DropdownButton<String>(
          value: _selectedOperator,
          items: _operatorsOptions
              .map((name) => DropdownMenuItem<String>(
                    value: name,
                    child: Text(name),
                  ))
              .toList(),
          onChanged: (value) {
            setState(() {
              _selectedOperator = value;
            });
          },
        ),
        SizedBox(width: 20),
        Container(
          width: 100,
          child: TextField(
            controller: _selectedValueForFilterCtrler,
            maxLines: 1,
          ),
        ),
        SizedBox(width: 20),
        Expanded(
          flex: 1,
          child: ElevatedButton(
            child: Text("Filter"),
            onPressed: () async {

              var operator;
              var checkValue = _selectedValueForFilterCtrler.text;
              var value;
              String selectedFilter = _selectedFilter ?? "";

              if(_selectedFilter == "year"){
                value = int.parse(checkValue);
              }
              else{
                value = checkValue;
              }


              switch(_selectedOperator){
                case ">":
                  operator = QueryOperator.gt(value);
                  break;

                case ">=":
                  operator = QueryOperator.gte(value);
                  break;

                case "<":
                  operator = QueryOperator.lt(value);
                  break;

                case "<=":
                  operator = QueryOperator.lte(value);
                  break;

                case "==":
                  operator = value;
                  break;

                case "!=":
                  operator = QueryOperator.ne(checkValue);
                  break;
              }

              var docs = await _collection?.find(
                  filter: {
                    selectedFilter: operator
                  }
              );

              print("docs found = ${docs!.length}");
            },
          ),
        )
      ],
    );
  }

  /// Functions ///

  _fetchStudents() async {
    List? documents = await _collection?.find(

//      projection: {
//        "field": ProjectionValue.INCLUDE,
//      }
        );
    _students.clear();
    documents?.forEach((document) {
      _students.add(Student.fromDocument(document));
    });
    setState(() {});
  }

  _insertNewStudent() async {
    var form = formKey.currentState;

    if (form!.validate()) {
      form.save();

      var newStudent = Student(
        firstName: _newStudFirstName,
        lastName: _newStudLastName,
        year: _newStudYear,
      );

     var id = await _collection?.insertOne(newStudent.asDocument());
     print("inserted_id=$id");

      // var docsIds = await _collection?.insertMany([
      //   newStudent.asDocument(),
      //   newStudent.asDocument(),
      // ]);

      // for(var id in (docsIds ?? {}).values){
      //   print("inserted_id=$id");
      // }

      setState(() {
        form.reset();
      });
    }
  }
}

class StudentItem extends StatelessWidget {
  final Student student;
  final VoidCallback onPress;

  StudentItem(this.student, this.onPress);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: (){
          onPress.call();
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              flex: 2,
              child: Text(
                "${student.firstName} ${student.lastName}",
                style: TextStyle(fontSize: 20),
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(
                "${student.year}",
                style: TextStyle(fontSize: 18),
              ),
            ),
            Expanded(
                flex: 1,
                child: Text(
                  sprintf("%.2f", [student.gradesAvg]),
                  style: TextStyle(fontSize: 18),
                )),
          ],
        ),
      ),
    );
  }
}

class Student {
  final ObjectId? id;
  final String? firstName;
  final String? lastName;
  final int? year;
  final List<int>? grades;

  Student({this.lastName, this.firstName, this.grades, this.year, this.id});

  double get gradesAvg {
    var sum = 0;
    grades?.forEach((grade) {
      sum += grade;
    });
    return grades == null || grades!.isEmpty ? 0 : sum / grades!.length;
  }

  static fromDocument(MongoDocument document) {
    return Student(
        id: document.get('_id'),
        firstName: document.get("firstName") ?? "",
        lastName: document.get("lastName") ?? "",
        grades: (document.get("grades") == null
            ? <int>[]
            : (document.get("grades") as List)
                .map((e) => int.parse("$e"))
                .toList()),
        year: document.get("year") ?? 1);
  }

  MongoDocument asDocument() {
    return MongoDocument({
      "firstName": this.firstName,
      "lastName": this.lastName,
      "grades": this.grades ?? [],
      "year": this.year,
    });
  }
}
