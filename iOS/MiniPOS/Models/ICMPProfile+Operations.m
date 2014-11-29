//
//  ICMPProfile+Operations.m
//  MiniPOS
//
//  Created by Nam Nguyen on 11/29/14.
//  Copyright (c) 2014 STB. All rights reserved.
//

#import "ICMPProfile+Operations.h"

@implementation ICMPProfile (Operations)

- (AFHTTPRequestOperation *)getProfileWithCompletionBlock:(void (^)(id responseObject, NSError *error))block
{
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
    
    return [[STBAPIClient sharedClient] POST:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", responseObject);
        NSString *responseCode = [responseObject objectForKey:kParameterRespCode];
        if ([responseCode isEqualToString:@"00"]){
            NSString *base64Encoded = [responseObject objectForKey:@"Data"];
            NSDictionary *JSON = [STBAPIClient JSONDictionaryFromBase64EncodedString:base64Encoded];
            if (JSON && [JSON allKeys].count > 0)
                [self updateFromDictionary:JSON];

            //success
            if (block) {
                block(responseObject, nil);
            }
        }
        else{
            if (block) {
                block(nil, [NSError errorWithDomain:responseCode code:[responseCode integerValue] userInfo:nil]);
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@ %@", error, operation.response);
        if (block) {
            block(nil, error);
        }
    }];
}

@end
