// import 'package:streams_channel/streams_channel.dart';

import 'package:flutter_mongodb_realm/external_libs/streams_channel.dart';

class StreamInterop {
  static StreamsChannel _streamsChannel =
      StreamsChannel('streams_channel_test');

  static Stream getNativeStream(args) {
    return _streamsChannel.receiveBroadcastStream(args);
  }
}
