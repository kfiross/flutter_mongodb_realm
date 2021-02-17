import 'package:reflectable/reflectable.dart';

/// Annotate with this class will enable reflection.
class MyReflector extends Reflectable {
  const MyReflector()
      : super(invokingCapability, typingCapability, reflectedTypeCapability, metadataCapability); // Request the capability to invoke methods.
}

/// shorthand usage
const RealmClass = const MyReflector();