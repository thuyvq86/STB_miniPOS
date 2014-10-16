//
//  NSDictionary+Additions.h
//  AutoScout24
//
//  Created by Nam Nguyen on 5/23/14.
//  Copyright (c) 2014 AutoScout24. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (Additions)

/*
 * Initializes a new dictionary containing the keys and values from the
 * specified ICM (POS) Message.
 *
 * @param queryString The query parameters to parse
 *
 * @returns A new dictionary containing the specified query parameters.
 *
 **/
+ (NSDictionary *)dictionaryFromPosMessage:(NSString *)posMessage;

/*
 * Initializes a new dictionary containing the keys and values from the
 * specified query string.
 *
 * @param queryString The query parameters to parse
 *
 * @returns A new dictionary containing the specified query parameters.
 *
 **/
+ (NSDictionary *)dictionaryFromQueryString:(NSString *)queryString;

/*
 * Returns the dictionary as a query string.
 **/
- (NSString *)queryString;

@end
