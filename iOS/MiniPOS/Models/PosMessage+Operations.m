//
//  PosMessage+Operations.m
//  MiniPOS
//
//  Created by Nam Nguyen on 11/29/14.
//  Copyright (c) 2014 STB. All rights reserved.
//

#import "PosMessage+Operations.h"

@implementation PosMessage (Operations)

- (AFHTTPRequestOperation *)sendBillWithProfile:(ICMPProfile *)profile completionBlock:(void (^)(id responseObject, NSError *error))completionBlock noInternet:(void (^)(void))noInternet{
    
    STBAPIClient *apiClient = [STBAPIClient sharedClient];
    if (![apiClient isInternetReachable]){
        if (noInternet)
            noInternet();
        return nil;
    }
    
    //data
    NSString *base64EncodedSignature = [self base64EncodedSignature];
    NSDictionary *dataDict = @{
                               kParameterMerchantID: profile.merchantId,
                               kParameterTerminalID: self.terminalId,
                               kParameterSerialID: profile.serialId,
                               kParameterCustomerEmail: self.email ? self.email : @"",
                               kParameterCustomerSignature: base64EncodedSignature ? base64EncodedSignature : @"",
                               kParameterTransactionData: self.message
                               };
    
    NSString *jsonDataString = [STBAPIClient jsonStringFromDictionary:dataDict];
    
    //request body
    NSDictionary *parameters = @{
                                 kParameterData: jsonDataString ? jsonDataString : @"",
                                 kParameterMerchantID: @"MiniPOS",
                                 kParameterFunctionName: kFunctionNameBillReceiver,
                                 kParameterRefNumber: @"",
                                 kParameterSignature: @"",
                                 kParameterToken: @""
                                 };
    NSString *path = kApiPath;
    
    //send request
    return [apiClient POST:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //NSLog(@"%@", responseObject);
        NSString *responseCode = [responseObject objectForKey:kParameterRespCode];
        if ([responseCode isEqualToString:@"00"]){
            //success
            if (completionBlock) {
                completionBlock(responseObject, nil);
            }
        }
        else{
            if (completionBlock) {
                completionBlock(nil, [NSError errorWithDomain:responseCode code:[responseCode integerValue] userInfo:nil]);
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (completionBlock) {
            completionBlock(nil, error);
        }
    }];
}

@end
