#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "DiscoveryRunningHandler.h"
#import "FlutterMdnsPlugin.h"
#import "ServiceDiscoveredHandler.h"
#import "ServiceLostHandler.h"
#import "ServiceResolvedHandler.h"

FOUNDATION_EXPORT double flutter_mdns_pluginVersionNumber;
FOUNDATION_EXPORT const unsigned char flutter_mdns_pluginVersionString[];

