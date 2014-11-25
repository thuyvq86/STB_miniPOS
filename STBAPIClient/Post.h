//
//  Post.h
//  MiniPOS
//
//  Created by Nam Nguyen on 11/26/14.
//  Copyright (c) 2014 STB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STBAPIClient.h"

@interface Post : NSObject

@property (nonatomic, assign) NSUInteger postID;
@property (nonatomic, strong) NSString *text;

- (instancetype)initWithAttributes:(NSDictionary *)attributes;

+ (AFHTTPRequestOperation *)getProfileWithBlock:(void (^)(NSArray *profiles, NSError *error))block;
+ (AFHTTPRequestOperation *)sendBill:(id)bill withBlock:(void (^)(NSArray *profiles, NSError *error))block;

@end
