//
//  NSUserDefaults+Utils.m
//  AutoScout24
//
//  Created by Nam Nguyen on 9/5/14.
//  Copyright (c) 2014 AutoScout24. All rights reserved.
//

#import "NSUserDefaults+Utils.h"

@implementation NSUserDefaults (Utils)

#pragma mark - An Object

+ (BOOL)boolForKey:(NSString*)key{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    BOOL object = [userDefaults boolForKey:key];
    
    return object;
}

+ (void)saveBool:(BOOL)bValue forKey:(NSString *)key{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:bValue forKey:key];
    
    [userDefaults synchronize];
}

+ (id)objectForKey:(NSString*)key{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    id object = [userDefaults objectForKey:key];
    
    if ([[NSNull null] isEqual:object])
        object = nil;
    
    return object;
}

+ (void)saveObject:(NSObject *)object forKey:(NSString*)key
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (!object || [[NSNull null] isEqual:object])
        [userDefaults removeObjectForKey:key];
    else
        [userDefaults setObject:object forKey:key];
    
    [userDefaults synchronize];
}

+ (void)removeObjectForKey:(NSString *)key{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:key];
    [userDefaults synchronize];
}

#pragma mark - Array

+ (NSMutableArray*)loadArray:(NSString*)key {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSData *data = [defaults objectForKey:key];
	if (data.length > 0) {
		return [NSKeyedUnarchiver unarchiveObjectWithData:data];
	} else {
		return [NSMutableArray array];
	}
}

+ (void)saveArray:(NSMutableArray*)array forKey:(NSString*)key {
	NSData *data = [NSKeyedArchiver archivedDataWithRootObject:array];
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:data forKey:key];
    [defaults synchronize];
}

@end
