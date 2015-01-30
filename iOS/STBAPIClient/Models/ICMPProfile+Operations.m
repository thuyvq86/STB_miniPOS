//
//  ICMPProfile+Operations.m
//  MiniPOS
//
//  Created by Nam Nguyen on 11/29/14.
//  Copyright (c) 2014 STB. All rights reserved.
//

#import "ICMPProfile+Operations.h"

@implementation ICMPProfile (Operations)

- (AFHTTPRequestOperation *)getProfileWithCompletionBlock:(void (^)(id JSON, NSError *error))completionBlock noInternet:(void (^)(void))noInternet
{
    STBAPIClient *apiClient = [STBAPIClient sharedClient];
    if (![apiClient isInternetReachable]){
        if (noInternet)
            noInternet();
        return nil;
    }
    
    NSDictionary *dataDict = @{kParameterSerialID: self.serialId};
    NSString *jsonDataString = [STBAPIClient jsonStringFromDictionary:dataDict];
    
    NSDictionary *parameters = @{kParameterData: jsonDataString ? jsonDataString : @"",
                                 kParameterMerchantID: @"MiniPOS",
                                 kParameterFunctionName: kFunctionNameProfileGetter,
                                 kParameterRefNumber: @"",
                                 kParameterSignature: @"",
                                 kParameterToken: @""
                                 };
    NSString *path = kApiPath;
    
    return [apiClient POST:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //DLog(@"%@", responseObject);
        NSString *responseCode = [responseObject objectForKey:kParameterRespCode];
        if ([responseCode isEqualToString:@"00"]){
            NSString *base64Encoded = [responseObject objectForKey:@"Data"];
            NSDictionary *JSON = [STBAPIClient JSONDictionaryFromBase64EncodedString:base64Encoded];
            DLog(@"%@", JSON);
            
            if (JSON && [JSON allKeys].count > 0){
                [self updateFromDictionary:JSON];
            }

            //success
            if (completionBlock) {
                completionBlock(JSON, nil);
            }
        }
        else{
            if (completionBlock) {
                completionBlock(nil, [NSError errorWithDomain:responseCode code:[responseCode integerValue] userInfo:nil]);
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DLog(@"%@ %@", error, operation.response);
        if (completionBlock) {
            completionBlock(nil, error);
        }
    }];
}

@end
