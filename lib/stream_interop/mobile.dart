import 'package:streams_channel2/streams_channel2.dart';
class StreamInterop {
  static StreamsChannel _streamsChannel =
      StreamsChannel('streams_channel_test');

  static Stream getNativeStream(args) {
    return _streamsChannel.receiveBroadcastStream(args);
  }
}
