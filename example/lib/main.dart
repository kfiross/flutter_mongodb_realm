import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:mongoatlasflutter/mongoatlasflutter.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';

  MongoAtlasClient client = MongoAtlasClient();

  @override
  void initState() {
    super.initState();

    // initiliize MongoStitch App
    client.initializeApp("mystitchapp-fjpmn").then((_) {
      // after app initlized, show some data
      // insertData();
//       fetchData();
      deleteData();

    });
  }

  Future<void> insertData() async {
    var collection = client.getDatabase("test").getCollection("my_collection");

    try {
      var document = MongoDocument({
        "time": DateTime.now().millisecondsSinceEpoch,
        "user_id": "abcdefg67",
        "age": 25,
        "price": 31.72
      });

    } on PlatformException {
      debugPrint("Error!!!");
    }
  }

  Future<void> fetchData() async {
    // sample_mflix.comments
    // test.my_collection
    var collection = client.getDatabase("sample_mflix").getCollection("comments");

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


//      var docs = await collection.find({
//        // "name": "kfir",
//        "name": "Taylor Scott",
//      });
//      print(docs.length);

        var doc = await collection.findOne({
        //"name": "kfir",
          "name": "Taylor Scott",
        });
        int ssaa = 232;


    } on PlatformException catch(e) {
      debugPrint("Error: $e");
    }
  }

  Future<void> deleteData() async {
    // sample_mflix.comments
    // test.my_collection
    var collection = client.getDatabase("sample_mflix").getCollection("comments");

    try {
//      var document = MongoDocument.fromMap({
//        "time": DateTime.now().millisecondsSinceEpoch,
//        "user_id": "abcdefg",
//        "price": 31.78432
//      });


//      var docs = await collection.find();
//      print(docs.length);

//      var deletedDocs = await collection.deleteOne({"name": "Gilly"});
//      print(deletedDocs);


      var deletedDocs = await collection.deleteMany({"name": "Andrea Le"});
      print(deletedDocs);



//      var size = await collection.count();
//      print(size);
    } on PlatformException catch(e) {
      debugPrint("Error! ${e.message}");
    }
  }

//  // Platform messages are asynchronous, so we initialize in an async method.
//  Future<void> initPlatformState() async {
//    String platformVersion;
//    // Platform messages may fail, so we use a try/catch PlatformException.
//    try {
//      platformVersion = await Mongoatlasflutter.platformVersion;
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
//  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Text('Running on: \n'),
        ),
      ),
    );
  }
}
