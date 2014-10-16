//
//  NSDictionary+Additions.m
//  AutoScout24
//
//  Created by Nam Nguyen on 5/23/14.
//  Copyright (c) 2014 AutoScout24. All rights reserved.
//

#import "NSDictionary+Additions.h"

@implementation NSDictionary (Additions)

/*
 * Initializes a new dictionary containing the keys and values from the
 * specified ICM (POS) Message.
 *
 * @param queryString The query parameters to parse
 *
 * @returns A new dictionary containing the specified query parameters.
 *
 **/
+ (NSDictionary *)dictionaryFromPosMessage:(NSString *)message{
    if ([[NSNull null] isEqual:message] || !message || message.length == 0)
        return nil;
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    NSArray *keyValuesArray = [message componentsSeparatedByString:@"|"];
    for(NSString *keyValueString in keyValuesArray) {
        NSArray *keyValueArray = [keyValueString componentsSeparatedByString:@"^"];
        if(keyValueArray && keyValueArray.count == 2 && [keyValueArray objectAtIndex:1] && ![[keyValueArray objectAtIndex:1] isEqualToString:@""])
            [parameters setValue:[keyValueArray objectAtIndex:1] forKey:[keyValueArray objectAtIndex:0]];
    }
    
    return parameters;
}

+ (NSDictionary *)dictionaryFromQueryString:(NSString *)query{
    if (!query || query.length == 0)
        return nil;
    
    if (query.length > 0 && [query rangeOfString:@"?"].location != NSNotFound)
        query = [[query componentsSeparatedByString:@"?"] objectAtIndex:1];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    NSArray *keyValuesArray = [query componentsSeparatedByString:@"&"];
    for(NSString *keyValueString in keyValuesArray) {
        NSArray *keyValueArray = [keyValueString componentsSeparatedByString:@"="];
        if(keyValueArray && keyValueArray.count == 2 && [keyValueArray objectAtIndex:1] && ![[keyValueArray objectAtIndex:1] isEqualToString:@""])
            [parameters setValue:[keyValueArray objectAtIndex:1] forKey:[keyValueArray objectAtIndex:0]];
    }
    
    return parameters;
}

- (NSString *)queryString{
    NSArray *allKeys = [self allKeys];
    if (!allKeys || [allKeys count] == 0 )
        return nil;
    
    NSMutableString *query = [NSMutableString string];
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if (query.length == 0)
            [query appendFormat:@"?"];
        else
            [query appendFormat:@"&"];
        
        if (nil != key && nil != obj)
            [query appendFormat:@"%@=%@", key, obj];
    }];
    
    return query;
}

@end
