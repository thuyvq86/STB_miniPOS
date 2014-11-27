//
//  Post.m
//  MiniPOS
//
//  Created by Nam Nguyen on 11/26/14.
//  Copyright (c) 2014 STB. All rights reserved.
//

#import "Post.h"

#import "STBAPIClient.h"

@implementation Post

- (instancetype)initWithAttributes:(NSDictionary *)attributes {
    self = [super init];
    if (self) {

    }
    return self;
}

#pragma mark - Get Profile

+ (AFHTTPRequestOperation *)getProfileWithBlock:(void (^)(NSArray *posts, NSError *error))block {
    NSString *dataString = [NSString stringWithFormat:@"{\"%@\": \"01\"}", kParameterSerialID];
    NSDictionary *parameters = @{kParameterData: dataString,
                                 kParameterMerchantID: @"MiniPOS",
                                 kParameterFunctionName: @"ICMPProfileGetter",
                                 kParameterRefNumber: @"",
                                 kParameterSignature: @"",
                                 kParameterToken: @""
                                 };
    NSString *path = @"api";
    
    return [[STBAPIClient sharedClient] POST:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", responseObject);
        if (block) {
            block([NSArray array], nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@ %@", error, operation.response);
        if (block) {
            block([NSArray array], nil);
        }
    }];
}

#pragma mark - Save Bill

+ (AFHTTPRequestOperation *)sendBill:(id)bill withBlock:(void (^)(NSArray *profiles, NSError *error))block {
    NSDictionary *dataDict = @{
                               kParameterMerchantID: @"000000080100308",
                               kParameterTerminalID: @"60002647",
                               kParameterSerialID: @"01",
                               kParameterCustomerEmail: @"lochh12839@sacombank.com",
                               kParameterCustomerSignature: @"ABCDEF",
                               kParameterTransactionData: @"F1^1|F2^472074XXXXXX0130|F4^000000010100|F12^145459|F38^183256|F39^00"
                               };
    
    NSDictionary *parameters = @{
                                 kParameterData: dataDict,
                                 kParameterMerchantID: @"MiniPOS",
                                 kParameterFunctionName: @"ICMPBillReceiver",
                                 kParameterRefNumber: @"",
                                 kParameterSignature: @"",
                                 kParameterToken: @""
                                 };
    NSString *path = @"api";
    
    return [[STBAPIClient sharedClient] POST:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", responseObject);
        if (block) {
            block([NSArray array], nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
        if (block) {
            block([NSArray array], nil);
        }
    }];
}


@end
