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
#define kApiPath @"api"

/** Functions **/
#define kFunctionNameBillReceiver @"ICMPBillReceiver"
#define kFunctionNameProfileGetter @"ICMPProfileGetter"

/** Parameters **/
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

@interface STBAPIClient : AFHTTPRequestOperationManager

+ (instancetype)sharedClient;

#pragma mark - Helpers

+ (NSString *)jsonStringFromDictionary:(NSDictionary *)dataDict;
+ (NSDictionary *)JSONDictionaryFromBase64EncodedString:(NSString *)base64Encoded;

@end
