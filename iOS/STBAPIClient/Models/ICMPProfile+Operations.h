//
//  ICMPProfile+Operations.h
//  MiniPOS
//
//  Created by Nam Nguyen on 11/29/14.
//  Copyright (c) 2014 STB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ICMPProfile.h"
#import "STBAPIClient.h"

@interface ICMPProfile (Operations)

- (AFHTTPRequestOperation *)getProfileWithCompletionBlock:(void (^)(id responseObject, NSError *error))completionBlock noInternet:(void (^)(void))noInternet;

@end
