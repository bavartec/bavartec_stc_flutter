//
//  AppDelegate.h
//  SatelliteFinder
//
//  Created by wuxin on 17/5/17.
//  Copyright © 2017年 wuxin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Flutter/Flutter.h"

#ifdef DEBUG
# define CLog(fmt, ...) NSLog((@"[文件名:%s]\n" "[函数名:%s]\n" "[行号:%d] \n" fmt), __FILE__, __FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
# define CLog(...);
#endif


@interface AppDelegate : FlutterAppDelegate
{
    
}

@end

