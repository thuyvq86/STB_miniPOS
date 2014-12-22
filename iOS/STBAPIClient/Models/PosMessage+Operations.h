//
//  PosMessage+Operations.h
//  MiniPOS
//
//  Created by Nam Nguyen on 11/29/14.
//  Copyright (c) 2014 STB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PosMessage.h"
#import "STBAPIClient.h"
#import "ICMPProfile.h"

@interface PosMessage (Operations)

- (AFHTTPRequestOperation *)sendBillWithProfile:(ICMPProfile *)profile completionBlock:(void (^)(id responseObject, NSError *error))completionBlock noInternet:(void (^)(void))noInternet;

@end
