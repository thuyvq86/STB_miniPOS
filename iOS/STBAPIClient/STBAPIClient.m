//
//  STBAPIClient.m
//  MiniPOS
//
//  Created by Nam Nguyen on 11/26/14.
//  Copyright (c) 2014 STB. All rights reserved.
//

#import "STBAPIClient.h"
#import "AFNetworkActivityIndicatorManager.h"

@implementation STBAPIClient

+ (instancetype)sharedClient {
    static STBAPIClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[STBAPIClient alloc] initWithBaseURL:[NSURL URLWithString:kSTBAPIBaseURLPrimary]];
        
        AFJSONRequestSerializer *requestSerializer = [AFJSONRequestSerializer serializerWithWritingOptions:NSJSONWritingPrettyPrinted];
        [_sharedClient setRequestSerializer:requestSerializer];
        
        AFJSONResponseSerializer *responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
        [_sharedClient setResponseSerializer:responseSerializer];
        
        AFSecurityPolicy *securityPolicy = [[AFSecurityPolicy alloc] init];
        [securityPolicy setAllowInvalidCertificates:YES];
        _sharedClient.securityPolicy = securityPolicy;
        
        //show network activity indicator
        [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
        
    });
    
    return _sharedClient;
}

#pragma mark - Reachability

- (bool)isInternetReachable {
    return [AFNetworkReachabilityManager sharedManager].isReachable;
}

#pragma mark - Helpers

+ (NSString *)jsonStringFromDictionary:(NSDictionary *)dataDict{
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dataDict
                                                       options:0
                                                         error:&error];
    if (error){
        DLog(@"%@", error);
        return nil;
    }
    
    NSString *jsonDataString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    return jsonDataString;
}

+ (NSDictionary *)JSONDictionaryFromBase64EncodedString:(NSString *)base64Encoded{
    if (!base64Encoded || base64Encoded.length == 0)
        return nil;
    
    // NSData from the Base64 encoded str
    NSData *nsdataFromBase64String = [[NSData alloc] initWithBase64EncodedString:base64Encoded options:0];
    
    NSError *error = nil;
    NSDictionary *JSON = nil;
    if (nsdataFromBase64String){
        JSON = [NSJSONSerialization JSONObjectWithData: nsdataFromBase64String
                                               options: NSJSONReadingMutableContainers
                                                 error: &error];
        if (error)
            DLog(@"%@", error);
    }
    
    return JSON;
}

@end
