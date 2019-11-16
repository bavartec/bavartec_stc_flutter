//
//  FlutterNativePlugin.m
//  Runner
//
//  Created by wuxin on 2019/10/1.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//


#import "FlutterNativePlugin.h"
#import "mDNS.h"

@interface FlutterNativePlugin()
{
    
}

@property(strong,nonatomic)mDNS* mdns;

@end

@implementation FlutterNativePlugin

-(id)init
{
    if(self=[super init])
    {
        _mdns = [[mDNS alloc] init];
    }
    [_mdns startDiscovery];
    
    return self;
}
- (void)dealloc
{
    if (_mdns!=nil) {
        [_mdns stopDiscovery];
    }
}
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
    FlutterMethodChannel *channel = [FlutterMethodChannel methodChannelWithName:@"bavartec" binaryMessenger:[registrar messenger]];
    FlutterNativePlugin *instance = [[FlutterNativePlugin alloc]init];
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
    if ([call.method isEqualToString:@"discoverWifi"]) {
        if (strcmp(dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL), dispatch_queue_get_label(dispatch_get_main_queue())) == 0) {
            // do something in main thread
            NSLog(@"--main thread");
        } else {
            // do something in other thread
            NSLog(@"--other thread");
            
        }
        
        NSLog(@"discoverWifi called");
        //result(@"192.168.0.160");
        [_mdns discoverWifi:false result:result];
        //result([_mdns discoverWifi:false callback:"kkk"]);
    }else {
        result(FlutterMethodNotImplemented);
    }
}

+ (void)callbackToFlutterOnMainUIThread:(dispatch_block_t)dbt {
    dispatch_async(dispatch_get_main_queue(), dbt);
    NSLog(@"service name");
    //^{
        //Update UI in UI thread here
    //});
}
@end
