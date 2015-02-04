//
//  AppUtils.m
//  MiniPOS
//
//  Created by Nam Nguyen on 10/12/14.
//  Copyright (c) 2014 STB. All rights reserved.
//

#import "AppUtils.h"

#import <sys/socket.h>
#import <netinet/in.h>
#import <SystemConfiguration/SystemConfiguration.h>

@implementation AppUtils

/*
 Connectivity testing code pulled from Apple's Reachability Example: http://developer.apple.com/library/ios/#samplecode/Reachability
 */
+ (BOOL)hasConnectivity {
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr*)&zeroAddress);
    if(reachability != NULL) {
        //NetworkStatus retVal = NotReachable;
        SCNetworkReachabilityFlags flags;
        if (SCNetworkReachabilityGetFlags(reachability, &flags)) {
            if ((flags & kSCNetworkReachabilityFlagsReachable) == 0)
            {
                // if target host is not reachable
                return NO;
            }
            
            if ((flags & kSCNetworkReachabilityFlagsConnectionRequired) == 0)
            {
                // if target host is reachable and no connection is required
                //  then we'll assume (for now) that your on Wi-Fi
                return YES;
            }
            
            
            if ((((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0) ||
                 (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0))
            {
                // ... and the connection is on-demand (or on-traffic) if the
                //     calling application is using the CFSocketStream or higher APIs
                
                if ((flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0)
                {
                    // ... and no [user] intervention is needed
                    return YES;
                }
            }
            
            if ((flags & kSCNetworkReachabilityFlagsIsWWAN) == kSCNetworkReachabilityFlagsIsWWAN)
            {
                // ... but WWAN connections are OK if the calling application
                //     is using the CFNetwork (CFSocketStream?) APIs.
                return YES;
            }
        }
    }
    
    return NO;
}

#pragma mark - String helpers

+ (BOOL)isEmptyText:(NSString *)text {
    text = [text stringByRemovingNewLinesAndWhitespace];
    if (!text)
        return YES;
    
    return NO;
}

#pragma mark - Array

+ (BOOL)isValidArray:(id)array {
    if (array && ![[NSNull null] isEqual:array] && [array count] > 0){
        return YES;
    }
    return NO;
}

#pragma mark - NSFileManager

+ (void)deleteFileAtPath:(NSString*)storedPath {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:storedPath]) {
        return;
    }
    
    NSError *error = nil;
    if (![fileManager removeItemAtPath:storedPath error:&error]) {
        DLog(@"Error deleting file %@: %@", storedPath, [error localizedDescription]);
    }else{
        DLog(@"Deleted file: %@", storedPath);
    }
}

+ (NSString *)pathForPublicFile:(NSString *)file
{
	return [[self publicDataPath] stringByAppendingPathComponent:file];
}

+ (NSString *)publicDataPath
{
    @synchronized ([NSFileManager class])
    {
        static NSString *path = nil;
        if (!path)
        {
            //user documents folder
            path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
            
            //retain path
            path = [[NSString alloc] initWithString:path];
        }
        return path;
    }
}

#pragma mark - App & device infos

+ (NSString *)appName {
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString*)kCFBundleNameKey];
}

+ (NSString *)appVersion {
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
}

+ (NSString *)appBuildNumber {
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
}

+ (NSString *)appBundleIdentifier{
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleIdentifierKey];
}

+ (NSArray *)bundleURLTypes{
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleURLTypes"];
}

// find out the scheme in the plist file.
+ (NSString *)appURLScheme{
    NSString *appBundleIdentifier = [self appBundleIdentifier];
    NSArray *bundleURLTypes = [self bundleURLTypes];
    
    if (![self isValidArray:bundleURLTypes])
        return nil;
    
    NSString *appURLString = nil;
    
    for (NSDictionary *dict in bundleURLTypes) {
        NSString *bundleURLName = [dict valueForKey:@"CFBundleURLName"];
        if ([bundleURLName isEqualToString:appBundleIdentifier]) {
            NSArray *bundleURLSchemes = [dict objectForKey:@"CFBundleURLSchemes"];
            if ([self isValidArray:bundleURLSchemes]){
                appURLString = [bundleURLSchemes objectAtIndex:0];
                break;
            }
        }
    }
    
    if (![self isEmptyText:appURLString])
        appURLString = [appURLString stringByAppendingString:@"://"];
    
    return appURLString;
}

+ (NSString *)deviceModel{
    return [[UIDevice currentDevice] model];
}

+ (NSString *)systemVersion{ //ios version
    return [[UIDevice currentDevice] systemVersion];
}

+ (CGFloat)screenScale{
    return [[UIScreen mainScreen] respondsToSelector:@selector(scale)] ? [[UIScreen mainScreen] scale] : 1.0f; //scale
}

@end
