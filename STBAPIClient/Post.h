//
//  Post.h
//  MiniPOS
//
//  Created by Nam Nguyen on 11/26/14.
//  Copyright (c) 2014 STB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STBAPIClient.h"

#define kParameterData              @"Data"
#define kParameterMerchantID        @"MerchantID"
#define kParameterTerminalID        @"TerminalID"
#define kParameterSerialID          @"SerialID"
#define kParameterFunctionName      @"FunctionName"
#define kParameterRefNumber         @"RefNumber"
#define kParameterRespCode          @"RespCode"
#define kParameterSignature         @"Signature"
#define kParameterToken             @"Token"
#define kParameterCustomerEmail     @"CustomerEmail"
#define kParameterCustomerSignature @"CustomerSignature"
#define kParameterTransactionData   @"TransactionData"

@interface Post : NSObject

@property (nonatomic, strong) id data;
@property (nonatomic, strong) NSString *merchantID;
@property (nonatomic, strong) NSString *functionName;
@property (nonatomic, strong) NSString *refNumber;
@property (nonatomic, strong) NSString *respCode;
@property (nonatomic, strong) id signature;
@property (nonatomic, strong) NSString *token;

- (instancetype)initWithAttributes:(NSDictionary *)attributes;

+ (AFHTTPRequestOperation *)getProfileWithBlock:(void (^)(NSArray *profiles, NSError *error))block;
+ (AFHTTPRequestOperation *)sendBill:(id)bill withBlock:(void (^)(NSArray *profiles, NSError *error))block;

@end
