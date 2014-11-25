//
//  STBAPIClient.h
//  MiniPOS
//
//  Created by Nam Nguyen on 11/26/14.
//  Copyright (c) 2014 STB. All rights reserved.
//

#import "AFHTTPRequestOperationManager.h"

@interface STBAPIClient : AFHTTPRequestOperationManager

+ (instancetype)sharedClient;

@end
