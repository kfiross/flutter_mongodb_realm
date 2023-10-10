// ignore_for_file: deprecated_member_use

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
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

  ScrollController? _scrollController;

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController();
    // app.currentUser.then((user) {
    //   user!.linkCredentials(Credentials.emailPassword('k@k.com', '1234567'));
    // });

//   client.callFunction("sum", args: [3, 4]).then((value) {
//     print(value);
//   });
  }

  @override
  void dispose() {
    _selectedValueForFilterCtrler.dispose();
    _scrollController?.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();

    _collection ??= client.getDatabase("test").getCollection("students");
    // try {
    //   await _fetchStudents();
    // } catch (e) {
    //   print(e);
    // }
  }

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(seconds: 1)).then((value) {
      app.currentUser.then((user) {
        user!.accessToken.then((token) {
          print("accessToken = $token");
        });
      });
    });

    return SafeArea(
      top: false,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Home Screen"),
          actions: <Widget>[
            TextButton(
              child: Icon(Icons.refresh, color: Colors.white),
              onPressed: _fetchStudents,
            ),
            TextButton(
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
        body: Column(
          children: [
            Expanded(
              child: Container(
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
            ),
            Container(
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
                        validator: (val) => val != null && val.isEmpty ? "can't be empty." : null,
                        onSaved: (val) => _newStudFirstName = val ?? "",
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      flex: 3,
                      child: TextFormField(
                        decoration: InputDecoration(labelText: 'Last Name'),
                        autocorrect: false,
                        validator: (val) => val != null && val.isEmpty ? "can't be empty." : null,
                        onSaved: (val) => _newStudLastName = val ?? "",
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      flex: 1,
                      child: TextFormField(
                        decoration: InputDecoration(labelText: 'Year'),
                        autocorrect: false,
                        validator: (val) => val != null && val.isEmpty ? "can't be empty." : null,
                        onSaved: (val) {
                          if (val != null) {
                            _newStudYear = int.parse(val);
                          }
                        },
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(child: Text("Add"), onPressed: _insertNewStudent),
                    ),
                  ],
                ),
              ),
            ),
          ],
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
          Expanded(flex: 1, child: Text("Year", style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(
              flex: 1, child: Text("Grades Avg.", style: TextStyle(fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  Widget _studentsListStreamBuilder() {
    return StreamBuilder(
      stream: _collection?.watch(),
      builder: (context, snapshot) {
        // if (snapshot.data == null) {
        //   return const SizedBox.shrink();
        // }
        // print(snapshot.data);
        // return const SizedBox.shrink();

        return FutureBuilder<List<MongoDocument>>(
          future: _collection?.find(options: RemoteFindOptions(limit: 10, sort: {
            '_id': OrderValue.DESCENDING
          })),
          builder: (BuildContext _, AsyncSnapshot<List<MongoDocument>> snapshot2) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              if (snapshot2.connectionState != ConnectionState.done) {
                return _studentsList();
              }
            }
            if (snapshot2.data == null) return const SizedBox.shrink();

            _students.clear();

            var documents = snapshot2.data ?? [];
            for(var document in documents){
              _students.add(Student.fromDocument(document));
            }
            print(_students.length);

            return _studentsList();
          },
        );
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

  Widget _studentsList() {
    final list = _students.map((s) {
      return StudentItem(s, () async {
        var docDeleted = await _collection?.deleteOne({
          "_id": s.id,
        });
        print("deleted docs: $docDeleted");
      });
    }).toList();

    if (list.isEmpty) {
      return const SizedBox.shrink();
    }
    Future.microtask(() {
      _scrollDown();
    });

    return Expanded(
        child: ListView.builder(
      controller: _scrollController,
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

              if (_selectedFilter == "year") {
                value = int.parse(checkValue);
              } else {
                value = checkValue;
              }

              switch (_selectedOperator) {
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

              var docs = await _collection?.find(filter: {selectedFilter: operator});

              print("docs found = ${docs!.length}");
            },
          ),
        )
      ],
    );
  }

  /// Functions ///

  void _scrollDown() {
    _scrollController?.animateTo(_scrollController?.position.maxScrollExtent ?? 0, curve: Curves.bounceIn, duration: Duration(milliseconds: 10));
  }

  _fetchStudents() async {
    List? documents = await _collection?.find(

//      projection: {
//        "field": ProjectionValue.INCLUDE,
//      }
        );
    _students.clear();
    for (var document in documents ?? []) {
      _students.add(Student.fromDocument(document));
    }
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
        onTap: () {
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
            : (document.get("grades") as List).map((e) => int.parse("$e")).toList()),
        year: (document.get("year") ?? 1).toInt());
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
