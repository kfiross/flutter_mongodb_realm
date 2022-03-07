import 'package:flutter/material.dart';
import 'package:flutter_mongodb_realm/flutter_mongo_realm.dart';

/// /////////////////////////////////////////////////////
import 'dart:async';

import 'package:flutter/services.dart';

import 'config_reader.dart';
import 'home_screen.dart';
import 'login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ConfigReader.initialize();

  await RealmApp.init(ConfigReader.appID);
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final MongoRealmClient client = MongoRealmClient();
  final RealmApp app = RealmApp();

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    // initialized MongoRealm App

    try {} on PlatformException catch (e) {
      print("Error! ${e.message}");
    } on Exception {}
  }

  Future<void> countData() async {
    var collection = client.getDatabase("test").getCollection("my_collection");

    try {
      var size = await collection.count();
      print("size=$size");
    } on PlatformException catch (e) {
      print("Error! ${e.message}");
    }
  }

  Future<void> insertData() async {
    var collection = client.getDatabase("test").getCollection("my_collection");

    try {
//      var document = MongoDocument({
//        "time": DateTime.now().millisecondsSinceEpoch,
//        "name": "hadar",
//        "age": 27,
//        "dogs": [
//          "shocko",
//          "nuna"
//        ]
//      });
//
//      collection.insertOne(document);

      collection.insertMany([
        MongoDocument({
          "time": DateTime.now().millisecondsSinceEpoch,
          "username": "moshe",
          "grades": [90, 98],
        }),
        MongoDocument({
          "time": DateTime.now().millisecondsSinceEpoch,
          "username": "adiel",
          "age": [77, 55, 91],
        }),
      ]);
    } on PlatformException {
      debugPrint("Error!!!");
    }
  }

  Future<void> fetchData() async {
    // sample_mflix.comments
    // test.my_collection
    var collection = client.getDatabase("test").getCollection("my_collection");

    try {
//      var document = MongoDocument.fromMap({
//        "time": DateTime.now().millisecondsSinceEpoch,
//        "user_id": "abcdefg",
//        "price": 31.78432
//      });

//      var size = await collection.count({
//        // "name": "kfir"
//        "name": "Taylor Scott",
//      });
//      print(size);

//      var docs = await collection.find(
//          filter: {
//            "year": QueryOperator.gt(2010)..lte(2014),
//            // "year":{"$gt":2010,"$lte":2014}
//      });
//      print(docs.length);

//      var doc = await collection.findOne({
//        //"name": "kfir",
//        "name": "Taylor Scott",
//      });
//      int ssaa = 232;

      /// with projection/limit
      var docs = await collection.find(
        filter: {
          "name": "naama",
        },
//        options: RemoteFindOptions(
//            projection: {
//              "title": ProjectionValue.INCLUDE,
//              "rated": ProjectionValue.INCLUDE,
//              "year": ProjectionValue.INCLUDE,
//            },
//            limit: 70,
//            sort: {
//              "year": OrderValue.DESCENDING,
//            }),
      );
//      print(doc.get("_id"));
//      print(docs.length);

      docs.forEach((doc) {
        print(doc.get("_id"));
      });

//      /// with projection
//      var doc = await collection.findOne(
////        filter: {
////          "year": 2014,
////        },
////        projection: {
////          "title": ProjectionValue.INCLUDE,
////          "rated": ProjectionValue.INCLUDE,
////          "year": ProjectionValue.INCLUDE,
////        },
//      );
//      print(doc.map);
    } on PlatformException catch (e) {
      debugPrint("Error: $e");
    }
  }

  Future<void> deleteData() async {
    // sample_mflix.comments
    // test.my_collection
    var collection =
        client.getDatabase("sample_mflix").getCollection("comments");

    try {
//      var document = MongoDocument.fromMap({
//        "time": DateTime.now().millisecondsSinceEpoch,
//        "user_id": "abcdefg",
//        "price": 31.78432
//      });

//      var docs = await collection.find(filter: {"name": "Olly"});
//      print(docs.length);
//
//      var deletedDocs = await collection.deleteOne({"name": "Olly"});
//      print(deletedDocs);

      var deletedDocs = await collection.deleteMany({"name": "Olly"});
      print(deletedDocs);

//      var size = await collection.count();
//      print(size);
    } on PlatformException catch (e) {
      debugPrint("Error! ${e.message}");
    }
  }

  Future<void> updateData() async {
    var collection = client.getDatabase("test").getCollection("my_collection");

    try {
      var results = await collection.updateMany(
        filter: {
          "name": "adiel",
        },
//
//          update: UpdateSelector.set({
//            "quantity": 670,
//          })

//        update: UpdateOperator.rename({
//          "count": "quantity",
//        }),

//          update: UpdateSelector.unset(["age"]),

        update: UpdateOperator.inc({
          "age": -2,
          "quantity": 30,
        }),

//          update: UpdateSelector.max({
//            "quantity": 50.5,
//            "name": "x",
//          }),

//          update: UpdateSelector.mul({
//            "quantity": 2,
//          }),

//          update: UpdateSelector.mul({
//            "quantity": 2,
//          }),

//        update: UpdateSelector.pop({
//          "grades": PopValue.LAST, //PopValue.FIRST,
//        }),

//        update: UpdateSelector.push({
//          "grades": ArrayModifier.each([22, 88 ,91])
//
////          "grades": ArrayModifier.each([88, 90 ,22])
////            ..sort({"score": SortValue.ASC})
////            ..slice(3)
////            ..position(0)
//
//        }),

//          update: UpdateSelector.pullAll({
//              "grades": [22, 4]
//          })

//          update: UpdateSelector.pull({
//              /// all grades <= 77 in array 'grades'
//              "grades": QuerySelector.lte(77),
//
//              /// all values matched 'orange or kiwis' in array 'fruits'
////              "fruits": ["orange", "kiwis"]
//          })
      );
      print(results);

//      var results = await collection.updateMany(
//          filter:{
//            "name": "adiel",
//          },
//          update: UpdateSelector.set({
//            "quantity": 87,
//          })
//      );
//      print(results);

    } on PlatformException catch (e) {
      debugPrint("Error: $e");
    } on Exception {
      debugPrint("unkown error");
    }
  }

//  // Platform messages are asynchronous, so we initialize in an async method.
//  Future<void> initPlatformState() async {
//    String platformVersion;
//    // Platform messages may fail, so we use a try/catch PlatformException.
//    try {
//      platformVersion = await FlutterMongoRealm.platformVersion;
//    } on PlatformException {
//      platformVersion = 'Failed to get platform version.';
//    }
//
//    // If the widget was removed from the tree while the asynchronous platform
//    // message was in flight, we want to discard the reply rather than calling
//    // setState to update our non-existent appearance.
//    if (!mounted) return;
//
//    setState(() {
//      _platformVersion = platformVersion;
//    });

  void watchData() {
    var myCollection =
        client.getDatabase("test").getCollection("my_collection");

    try {
//      final stream = myCollection.watch(ids: ["22", "8"], asObjectIds: false);
//      final stream2 = myCollection.watch(ids: ["5ee8a50ffaba833f1c6c6a7c"]);
//      final stream3 =  myCollection.watchWithFilter({"age": 25}); /// WORKS!

      final streamSimple = myCollection.watch();

      /// WORKS!

      streamSimple.listen((event) {
        print(event);
        var fullDocument = MongoDocument.parse(event);
        print("a document with '${fullDocument.map["_id"]}' is changed");

//        }
        // do something
      });
    } on PlatformException catch (e) {
      debugPrint("Error! ${e.message}");
    }
  }

//  }

  Future<void> aggregateCollection() async {
    var collection = client.getDatabase("test").getCollection(
          //"scores"
          "orders",
        );

    try {
      /// addFields
//      List<PipelineStage> pipeline = [
//        PipelineStage.addFields({
//          "totalHomework": AggregateOperator.sum("homework"),
//          "totalQuiz": AggregateOperator.sum("quiz"),
//        }),
//        PipelineStage.addFields({
//          "totalScore": AggregateOperator.add(
//              ["totalHomework", "totalQuiz", "extraCredit"]),
//        }),
//      ];

      /// match, group, skip
//      List<PipelineStage> pipeline = [
//        PipelineStage.skip(2),
//        PipelineStage.match({"status": "A"}),
//        PipelineStage.group(
//          "cust_id",
//          accumulators: {"total": AggregateOperator.sum("amount")},
//        ),
//
//      ];

      List<PipelineStage> pipeline = [
        PipelineStage.sample(2),
      ];

//      List<PipelineStage> pipeline = [
//        PipelineStage.raw({
//          ""
//        }),
//      ];

      var list = await collection.aggregate(pipeline);
      print(list.length);
    } on PlatformException catch (e) {
      debugPrint("Error! ${e.message}");
    }

    // return Future.value([]);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: _authBuilder(context),
//      home: dummyHomeWidget(),
    );
  }

  dummyHomeWidget() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Text('Running on: \n'),
            RaisedButton(
              child: Text("Reset Password"),
              onPressed: () async {
                try {
                  var currUser = await app.currentUser;
                  final success = await app.sendResetPasswordEmail(
                      currUser?.profile?.email); //"kfir25812@gmail.com");
                  print(success);
                } on PlatformException catch (e) {
                  print(e.message ?? 'Unkown error');
                }
              },
            )
          ],
        ),
      ),
    );
  }

  StreamBuilder _authBuilder(BuildContext context) {
    Stream stream = app.authListener();
    return StreamBuilder(
      stream: stream,
      builder: (context, AsyncSnapshot snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            // show loading indicator
            return Scaffold(body: Center(child: CircularProgressIndicator()));

          case ConnectionState.active:
            // log error to console
            if (snapshot.error != null) {
              print("error");
              return Container(
                alignment: Alignment.center,
                child: Text(
                  snapshot.error.toString(),
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontFamily: "ariel",
                  ),
                ),
              );
            }

            // redirect to the proper page
            return snapshot.hasData ? HomeScreen() : LoginScreen();

          default:
            return Container();
        }
      },
    );
  }
}
