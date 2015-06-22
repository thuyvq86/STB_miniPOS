//
//  STBAPIClient.h
//  MiniPOS
//
//  Created by Nam Nguyen on 11/26/14.
//  Copyright (c) 2014 STB. All rights reserved.
//

#import "AFHTTPRequestOperationManager.h"

/** Server **/
#define kSTBAPIBaseURLPrimary @"https://113.164.14.65:9444/"
#define kApiPath @"iapi"

/** Functions **/
#define kFunctionNameBillReceiver  @"ICMPBillReceiver"
#define kFunctionNameProfileGetter @"ICMPProfileGetter"
#define kFunctionNameVersionGetter @"ICMPVersionGetter"

/** Parameters **/
#define kParameterData                  @"Data"
#define kParameterMerchantID            @"MerchantID"
#define kParameterTerminalID            @"TerminalID"
#define kParameterSerialID              @"SerialID"
#define kParameterFunctionName          @"FunctionName"
#define kParameterRefNumber             @"RefNumber"
#define kParameterRespCode              @"ResponseCode"         // Nicolas: RespCode --> ResponseCode
#define kParameterSignature             @"Signature"
#define kParameterToken                 @"Token"
#define kParameterCustomerEmail         @"CustomerEmail"
#define kParameterCustomerSignature     @"CustomerSignature"
#define kParameterTransactionData       @"TransactionData"
#define kParameterCustomerDescription   @"CustomerDescription"  // Nicolas: require field from host

@interface STBAPIClient : AFHTTPRequestOperationManager

+ (instancetype)sharedClient;

#pragma mark - Reachability

- (bool)isInternetReachable;

#pragma mark - Helpers

+ (NSString *)jsonStringFromDictionary:(NSDictionary *)dataDict;
+ (NSDictionary *)JSONDictionaryFromBase64EncodedString:(NSString *)base64Encoded;

- (AFHTTPRequestOperation *)getAppVersionWithCompletionBlock:(void (^)(id JSON, NSError *error))completionBlock;

@end
