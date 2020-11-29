import 'dart:html';

class StreamInterop {
  static Stream getNativeStream(args) {
    return document.on[args];
  }
}
