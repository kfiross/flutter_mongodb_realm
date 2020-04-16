import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mongoatlasflutter/mongoatlasflutter.dart';

void main() {
  const MethodChannel channel = MethodChannel('mongoatlasflutter');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

//  test('getPlatformVersion', () async {
//    //expect(await Mongoatlasflutter.platformVersion, '42');
//  });
}
