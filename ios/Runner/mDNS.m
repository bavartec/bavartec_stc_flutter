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
    BOOL isFinding;
}
@property(strong,nonatomic)FlutterResult fRt;
//客户端主要使用的是iOS SDK里的NSNetServiceBrowser
@property(strong,nonatomic)NSNetServiceBrowser*serviceBrowser;

//NSNetService在客户端用于解析
@property(strong,nonatomic)NSNetService*netservice;

@property(strong,nonatomic)NSMutableArray*serviceArray;

@property(strong,nonatomic) NSTimer* timer;
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
        _serviceArray = [NSMutableArray array];
        isFinding = FALSE;
    }
    
    return self;
}

-(void)discoverWifi:(Boolean)cache result:(FlutterResult)result{
    if (isFinding == TRUE) {
//        [FlutterNativePlugin callbackToFlutterOnMainUIThread:^{
//            self->_fRt(NULL);
//        }];
        return;
    }
    
    isFinding = TRUE;
    _fRt = result;
    [self startDiscovery];
    [_serviceArray removeAllObjects];
}

//查找服务
//接着使用NSNetServiceBrowser实例的searchForServicesOfType方法查找服务，方法中可以指定需要查找的服务类型和查找的域
-(void)startDiscovery{
    NSLog(@"startDiscovery");
//    [FlutterNativePlugin callbackToFlutterOnMainUIThread:^{
//        self->_fRt(@"startDiscovery");
//    }];
    
//    dispatch_queue_t concurrentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
////
//    //dispatch_queue_t concurrentQueue = dispatch_get_main_queue();
//    dispatch_async(concurrentQueue, ^{
//        NSRunLoop *mainRunLoop = [NSRunLoop currentRunLoop];
//        //NSNetServiceBrowser* browser = [[NSNetServiceBrowser alloc] init];
//        //self->_serviceBrowser = [[NSNetServiceBrowser alloc] init];
//        [self->_serviceBrowser stop];
//        [self->_serviceBrowser stop];
//        [self->_serviceBrowser stop];
//        self->_serviceBrowser.delegate = self;
//        [self->_serviceBrowser scheduleInRunLoop:mainRunLoop forMode:NSRunLoopCommonModes];
//        [self->_serviceBrowser searchForServicesOfType:@"_http._tcp." inDomain:@"local."];
//        [mainRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:50]]; });
//
    
    
    [_serviceBrowser stop];
    [_serviceBrowser searchForServicesOfType:@"_http._tcp."inDomain:@"local."];
    _timer = [NSTimer scheduledTimerWithTimeInterval:10.0f
                                     target:self
                                   selector:@selector(startDiscoveryTimeOut:)
                                   userInfo:@"browse"
                                    repeats:NO];
}
- (void) startDiscoveryTimeOut:(NSTimer *)timer {
    // user info is the passed in service name
    [_serviceBrowser stop];
    [FlutterNativePlugin callbackToFlutterOnMainUIThread:^{
        self->_fRt(NULL);
    }];
    
    //取消定时器
    [self cancelTimer];
    isFinding = FALSE;
}
-(void) cancelTimer{
    //取消定时器
    [_timer invalidate];
    _timer = nil;
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

    BOOL isYES = [SERVICE_NAME isEqualToString:service.name];
    if (isYES) {
        NSLog(@"to stop browser...");
        [_serviceBrowser stop];
        [_serviceArray addObject:service];
        _netservice = service;
        _netservice.delegate = self;
        //设置解析超时时间
        [_netservice resolveWithTimeout:5.0];
        return;
    }
    
    if (moreComing == NO) {
        NSLog(@"to stop browser...");
        //取消定时器
        [self cancelTimer];
        
        [_serviceBrowser stop];
        [FlutterNativePlugin callbackToFlutterOnMainUIThread:^{
            self->_fRt(NULL);
        }];
        isFinding = FALSE;
    }
    
}
////服务被移除
//- (void)netServiceBrowser:(NSNetServiceBrowser *)browser didRemoveService:(NSNetService *)service moreComing:(BOOL)moreComing {
//    NSLog(@"%@", service.name);
//    NSLog(@"%@", service.type);
//    NSLog(@"didRemoveService");
//}
//- (void)netServiceBrowser:(NSNetServiceBrowser *)browser didNotSearch:(NSDictionary<NSString *, NSNumber *> *)errorDict {
//    NSLog(@"didNotSearch");
//}
////下面两个方法是关于domain域变化的监听。
//- (void)netServiceBrowser:(NSNetServiceBrowser *)browser didFindDomain:(NSString *)domainString moreComing:(BOOL)moreComing {
//    NSLog(@"didFindDomain");
//}
//- (void)netServiceBrowser:(NSNetServiceBrowser *)browser didRemoveDomain:(NSString *)domainString moreComing:(BOOL)moreComing {
//    NSLog(@"didRemoveDomain");
//}


//---------------------------
//--  NSNetService  Start  --
//---------------------------
//注：客户端可以通过NSNetService解析服务，解析成功后，可以获得通讯的数据细节，如：IP地址、端口等信息。
//即将解析服务，
- (void)netServiceWillResolve:(NSNetService *)sender {
    NSLog(@"will resolve service:[%@]", sender.name);
//    [FlutterNativePlugin callbackToFlutterOnMainUIThread:^{
//        self->_fRt(@"netServiceWillResolve");
//    }];
}
//解析服务成功
- (void)netServiceDidResolveAddress:(NSNetService *)sender {
    
    NSLog(@"service did resolved:[%@]", sender.name);
    NSData *address = [sender.addresses firstObject];
    struct sockaddr_in *socketAddress = (struct sockaddr_in *) [address bytes];
    NSString* ip = [NSString stringWithFormat:@"%s",inet_ntoa(socketAddress->sin_addr)];
    NSInteger port = sender.port;
    NSString* serviceName = [sender name];
    
    NSLog(@"server info: ip:%s, serviceName:%@, port:%d",inet_ntoa(socketAddress->sin_addr),serviceName, (int)sender.port);
    
    if ([sender.name isEqualToString:SERVICE_NAME]) {
        [self formatURL:ip port:port];
        [_serviceBrowser stop];
        //取消定时器
        [self cancelTimer];
        
        isFinding = FALSE;
    }
}

- (void) formatURL:(NSString*)ip port:(NSInteger)port {
    //return "http://$host:$port"
    NSString* url = [NSString stringWithFormat:@"http://%@:%d", ip, (int)port];
    [FlutterNativePlugin callbackToFlutterOnMainUIThread:^{
        self->_fRt(url);
    }];
    
}
//解析服务失败，解析出错
- (void)netService:(NSNetService *)sender didNotResolve:(NSDictionary *)errorDict {
    
    NSLog(@"didNotResolve: %@",errorDict);
//    [FlutterNativePlugin callbackToFlutterOnMainUIThread:^{
//        self->_fRt(@"didNotResolve");
//    }];
}



@end
