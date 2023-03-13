import 'package:streams_channel3/streams_channel3.dart';

class StreamInterop {
  static StreamsChannel _streamsChannel =
      StreamsChannel('streams_channel_test');

  static Stream getNativeStream(args) {
    return _streamsChannel.receiveBroadcastStream(args);
  }
}
