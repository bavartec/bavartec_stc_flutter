//
//  Generated file. Do not edit.
//

#import "GeneratedPluginRegistrant.h"
#import <connectivity/ConnectivityPlugin.h>
#import <shared_preferences/SharedPreferencesPlugin.h>
#import <smartconfig/SmartconfigPlugin.h>

@implementation GeneratedPluginRegistrant

+ (void)registerWithRegistry:(NSObject<FlutterPluginRegistry>*)registry {
  [FLTConnectivityPlugin registerWithRegistrar:[registry registrarForPlugin:@"FLTConnectivityPlugin"]];
  [FLTSharedPreferencesPlugin registerWithRegistrar:[registry registrarForPlugin:@"FLTSharedPreferencesPlugin"]];
  [SmartconfigPlugin registerWithRegistrar:[registry registrarForPlugin:@"SmartconfigPlugin"]];
}

@end
