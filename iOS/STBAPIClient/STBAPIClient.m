//
//  STBAPIClient.m
//  MiniPOS
//
//  Created by Nam Nguyen on 11/26/14.
//  Copyright (c) 2014 STB. All rights reserved.
//

#import "STBAPIClient.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "XMDatabaseManager.h"

#define kUserDataDatabaseName      @"userdata"

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
        
        //DB
        [[XMDatabaseManager sharedDatabaseManager] setupWithMasterDatabaseName:nil userDatabaseName:kUserDataDatabaseName textResourcesDatabaseName:nil];
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

#pragma mark - Check update app

- (AFHTTPRequestOperation *)getAppVersionWithCompletionBlock:(void (^)(id JSON, NSError *error))completionBlock{
    
    //request body
    NSDictionary *parameters = @{
                                 kParameterData: @"",
                                 kParameterMerchantID: @"MiniPOS",
                                 kParameterFunctionName: kFunctionNameVersionGetter,
                                 kParameterRefNumber: @"",
                                 kParameterSignature: @"",
                                 kParameterToken: @""
                                 };
    NSString *path = kApiPath;
    
    //send request
    return [self POST:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", responseObject);
        NSString *responseCode = [responseObject objectForKey:kParameterRespCode];
        if ([responseCode isEqualToString:@"00"]){
            NSString *base64Encoded = [responseObject objectForKey:@"Data"];
            NSDictionary *JSON = [STBAPIClient JSONDictionaryFromBase64EncodedString:base64Encoded];
            
            //success
            if (completionBlock) {
                completionBlock(JSON, nil);
            }
        }
        else{
            if (completionBlock) {
                NSError *error = nil;
                if (responseCode)
                    error = [NSError errorWithDomain:responseCode code:[responseCode integerValue] userInfo:nil];
                completionBlock(nil, error);
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (completionBlock) {
            completionBlock(nil, error);
        }
    }];
}

@end
