//
//  mDNS.m
//  Runner
//
//  Created by wuxin on 2019/10/1.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

#import "mDNS.h"
#import <Foundation/Foundation.h>
#import "FlutterNativePlugin.h"
#import <arpa/inet.h>

static NSString * const TAG = @"NSD";
static NSString * const SERVICE_TYPE = @"_http._tcp";
static NSString * const SERVICE_NAME = @"smart-thermo-control";

@interface mDNS ()
{
    BOOL isRunning;
}
//FlutterResult list
@property(strong,nonatomic)NSMutableArray* fRtArray;

//客户端主要使用的是iOS SDK里的NSNetServiceBrowser
@property(strong,nonatomic)NSNetServiceBrowser* serviceBrowser;

//NSNetService在客户端用于解析
@property(strong,nonatomic)NSNetService* netservice;

//service key-value pair, key:servicename, value:http://ip:port
@property(strong,nonatomic)NSMutableDictionary* serviceCache;

@end

@implementation mDNS

-(id)init
{
    if(self=[super init])
    {
        //初始化NSNetServiceBrowser
        _serviceBrowser= [[NSNetServiceBrowser alloc]init];
        //指定代理
        _serviceBrowser.delegate = self;
        _serviceCache = [NSMutableDictionary dictionary];
        _fRtArray = [NSMutableArray array];
        isRunning = NO;
    }
    
    return self;
}

-(void)discoverWifi:(Boolean)cache result:(FlutterResult)result{
    
    NSString* url = [_serviceCache objectForKey:SERVICE_NAME];
    if (url == nil) {
        [FlutterNativePlugin callbackToFlutterOnMainUIThread:^{
            result(NULL);
        }];
    }else{
        [FlutterNativePlugin callbackToFlutterOnMainUIThread:^{
            result(url);
        }];
    }

    [self startDiscovery];
}

//查找服务
//接着使用NSNetServiceBrowser实例的searchForServicesOfType方法查找服务，方法中可以指定需要查找的服务类型和查找的域
-(void)startDiscovery{
    NSLog(@"startDiscovery");
    if (isRunning == YES) {
        return;
    }
    
    isRunning = YES;

    [_serviceBrowser stop];
    [_serviceBrowser searchForServicesOfType:@"_http._tcp."inDomain:@"local."];
}
-(void)stopDiscovery{
    NSLog(@"stopDiscovery");
    if (isRunning == NO) {
        return;
    }
    
    isRunning = NO;
    [_serviceBrowser stop];
}
#pragma mark - NSNetServiceBrowserDelegate
//------------------------------------------
//--  NSNetServiceBrowserDelegate  Start  --
//------------------------------------------
//即将开始扫描
- (void)netServiceBrowserWillSearch:(NSNetServiceBrowser *)browser {
    NSLog(@"begin search.");
}
//停止扫描
- (void)netServiceBrowserDidStopSearch:(NSNetServiceBrowser *)browser{
    NSLog(@"search stopped.");
}
//发现服务，moreComing 用来判断还有没有服务过来。
- (void)netServiceBrowser:(NSNetServiceBrowser *)browser didFindService:(NSNetService *)service moreComing:(BOOL)moreComing {
    
    NSLog(@"find service: [%@][%@]", service.name, service.type);

    BOOL isFind = [SERVICE_NAME isEqualToString:service.name];
    if (isFind) {
        NSLog(@"to stop browser...");
        //[_serviceBrowser stop];
        //[_serviceArray addObject:service];
        _netservice = service;
        _netservice.delegate = self;
        //设置解析超时时间
        [_netservice resolveWithTimeout:5.0];
        return;
    }
    
//    if (moreComing == NO) {
//        NSLog(@"to stop browser...");
//
//        [_serviceBrowser stop];
//        isRunning = NO;
//    }
}
////服务被移除
- (void)netServiceBrowser:(NSNetServiceBrowser *)browser didRemoveService:(NSNetService *)service moreComing:(BOOL)moreComing {
    NSLog(@"%@", service.name);
    NSLog(@"%@", service.type);
    NSLog(@"didRemoveService");
    BOOL isFind = [SERVICE_NAME isEqualToString:service.name];
    if (isFind) {
        _netservice = nil;
        [_serviceCache removeObjectForKey:SERVICE_NAME];
    }
}
- (void)netServiceBrowser:(NSNetServiceBrowser *)browser didNotSearch:(NSDictionary<NSString *, NSNumber *> *)errorDict {
    NSLog(@"didNotSearch");
}
//下面两个方法是关于domain域变化的监听。
- (void)netServiceBrowser:(NSNetServiceBrowser *)browser didFindDomain:(NSString *)domainString moreComing:(BOOL)moreComing {
    NSLog(@"didFindDomain");
}
- (void)netServiceBrowser:(NSNetServiceBrowser *)browser didRemoveDomain:(NSString *)domainString moreComing:(BOOL)moreComing {
    NSLog(@"didRemoveDomain");
}


//---------------------------
//--  NSNetService  Start  --
//---------------------------
//注：客户端可以通过NSNetService解析服务，解析成功后，可以获得通讯的数据细节，如：IP地址、端口等信息。
//即将解析服务，
- (void)netServiceWillResolve:(NSNetService *)sender {
    NSLog(@"will resolve service:[%@]", sender.name);
}
//解析服务成功
- (void)netServiceDidResolveAddress:(NSNetService *)sender {
    
    NSLog(@"service did resolved:[%@]", sender.name);
    NSData *address = [sender.addresses firstObject];
    if (address == nil) {
        return;
    }
    struct sockaddr_in *socketAddress = (struct sockaddr_in *) [address bytes];
    if (socketAddress == nil) {
        return;
    }
    NSString* ip = [NSString stringWithFormat:@"%s",inet_ntoa(socketAddress->sin_addr)];
    NSInteger port = sender.port;
    NSString* serviceName = [sender name];
    
    NSLog(@"server info: ip:%s, serviceName:%@, port:%d",inet_ntoa(socketAddress->sin_addr),serviceName, (int)sender.port);
    
    if ([sender.name isEqualToString:SERVICE_NAME]) {
        NSString* sUrl = [NSString stringWithFormat:@"http://%@:%d", ip, (int)port];
        
        [_serviceCache setObject:sUrl forKey:SERVICE_NAME];
    }
}

//解析服务失败，解析出错
- (void)netService:(NSNetService *)sender didNotResolve:(NSDictionary *)errorDict {
    NSLog(@"didNotResolve: %@",errorDict);
}



@end
