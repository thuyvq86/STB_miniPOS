//
//  NSUserDefaults+Utils.h
//  AutoScout24
//
//  Created by Nam Nguyen on 9/5/14.
//  Copyright (c) 2014 AutoScout24. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSUserDefaults (Utils)

#pragma mark - An Object

+ (BOOL)boolForKey:(NSString*)key;
+ (void)saveBool:(BOOL)bValue forKey:(NSString *)key;

+ (id)objectForKey:(NSString *)key;
+ (void)saveObject:(NSObject *)object forKey:(NSString *)key;

+ (void)removeObjectForKey:(NSString *)key;

#pragma mark - Array

+ (NSMutableArray*)loadArray:(NSString*)key;
+ (void)saveArray:(NSMutableArray*)array forKey:(NSString*)key;

@end
