//
//  AppUtils.h
//  MiniPOS
//
//  Created by Nam Nguyen on 10/12/14.
//  Copyright (c) 2014 STB. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppUtils : NSObject

+ (BOOL)hasConnectivity;

// String
+ (BOOL)isEmptyText:(NSString *)text;

// Array
+ (BOOL)isValidArray:(id)array;

//NSFileManager
+ (void)deleteFileAtPath:(NSString*)storedPath;
+ (NSString *)pathForPublicFile:(NSString *)file;

//App & device infos
+ (NSString *)appName;
+ (NSString *)appVersion;
+ (NSString *)appBuildNumber;
+ (NSString *)appBundleIdentifier;
+ (NSArray *)bundleURLTypes;
+ (NSString *)appURLScheme;
+ (NSString *)deviceModel;
+ (NSString *)systemVersion;
+ (CGFloat)screenScale;

@end
