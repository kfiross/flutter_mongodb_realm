import 'package:flutter/services.dart';
import 'package:flutter_mongo_stitch/flutter_mongo_stitch.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_mongo_stitch/plugin.dart';


import 'database_test.dart' as db_tests;
import 'authentication_test.dart' as auth_tests;

void main() {
  const MethodChannel channel = MethodChannel('flutter_mongo_stitch');
  var mockedClient = MongoStitchClient();

  TestWidgetsFlutterBinding.ensureInitialized();
//
//  setUp(() {
//
//    channel.setMockMethodCallHandler((MethodCall methodCall) async {
//      return '42';
//    });
//  });
//
//  tearDown(() {
//    channel.setMockMethodCallHandler(null);
//  });
//
//  test('insertDoucment', () async {
//    expect(await mockedClient.insertDoucment(), true);
//  });

  test('all_test' , (){
    db_tests.main();
    auth_tests.main();
  });

}
