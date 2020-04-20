#import "FlutterMongoStitchPlugin.h"
#if __has_include(<flutter_mongo_stitch/flutter_mongo_stitch-Swift.h>)
#import <flutter_mongo_stitch/flutter_mongo_stitch-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "flutter_mongo_stitch-Swift.h"
#endif

@implementation FlutterMongoStitchPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterMongoStitchPlugin registerWithRegistrar:registrar];
}
@end
