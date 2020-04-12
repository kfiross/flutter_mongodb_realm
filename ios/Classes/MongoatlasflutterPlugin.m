#import "MongoatlasflutterPlugin.h"
#if __has_include(<mongoatlasflutter/mongoatlasflutter-Swift.h>)
#import <mongoatlasflutter/mongoatlasflutter-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "mongoatlasflutter-Swift.h"
#endif

@implementation MongoatlasflutterPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftMongoatlasflutterPlugin registerWithRegistrar:registrar];
}
@end
