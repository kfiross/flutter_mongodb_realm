import 'package:flutter/material.dart';
import 'package:flutter_mongo_stitch/flutter_mongo_stitch.dart';
import 'package:flutter_mongo_stitch_example/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MongoStitchClient.initializeApp("APP_ID");
  runApp(MyApp());

}

class MyApp extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginScreen(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green
      ),
    );
  }

}