//
//  STBAPIClient.m
//  MiniPOS
//
//  Created by Nam Nguyen on 11/26/14.
//  Copyright (c) 2014 STB. All rights reserved.
//

#import "STBAPIClient.h"

static NSString * const STBAPIBaseURLString = @"https://113.164.14.65:9444/api/";

@implementation STBAPIClient

+ (instancetype)sharedClient {
    static STBAPIClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[STBAPIClient alloc] initWithBaseURL:[NSURL URLWithString:STBAPIBaseURLString]];
        
        AFJSONRequestSerializer *requestSerializer = [AFJSONRequestSerializer serializerWithWritingOptions:NSJSONWritingPrettyPrinted];
        [_sharedClient setRequestSerializer:requestSerializer];
        
        AFJSONResponseSerializer *responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
        [_sharedClient setResponseSerializer:responseSerializer];
        
        AFSecurityPolicy *securityPolicy = [[AFSecurityPolicy alloc] init];
        [securityPolicy setAllowInvalidCertificates:YES];
        _sharedClient.securityPolicy = securityPolicy;
    });
    
    return _sharedClient;
}

@end
