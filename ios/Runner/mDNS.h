//
//  mDNS.h
//  Runner
//
//  Created by wuxin on 2019/10/1.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

#ifndef mDNS_h
#define mDNS_h

#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>

@interface mDNS : NSObject <NSNetServiceDelegate, NSNetServiceBrowserDelegate>

-(void)discoverWifi:(Boolean)cache result:(FlutterResult)result;

@end

#endif /* mDNS_h */
