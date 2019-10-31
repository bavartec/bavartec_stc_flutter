//
//  FlutterNativePlugin.h
//  Runner
//
//  Created by wuxin on 2019/10/1.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

#ifndef FlutterNativePlugin_h
#define FlutterNativePlugin_h

#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>

NS_ASSUME_NONNULL_BEGIN

@interface FlutterNativePlugin : NSObject <FlutterPlugin>

+ (void)callbackToFlutterOnMainUIThread:(dispatch_block_t)dbt;

@end

NS_ASSUME_NONNULL_END

#endif /* FlutterNativePlugin_h */
