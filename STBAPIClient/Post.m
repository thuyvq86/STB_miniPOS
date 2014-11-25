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
    if (!self) {
        return nil;
    }
    
    self.postID = (NSUInteger)[[attributes valueForKeyPath:@"id"] integerValue];
    self.text = [attributes valueForKeyPath:@"text"];
    
    return self;
}

#pragma mark - Get Profile

+ (AFHTTPRequestOperation *)getProfileWithBlock:(void (^)(NSArray *posts, NSError *error))block {
    NSDictionary *parameters = @{@"SerialID": @"01"};
    
    return [[STBAPIClient sharedClient] POST:@"ICMPProfileGetter" parameters:parameters constructingBodyWithBlock:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
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

#pragma mark - Bill

+ (AFHTTPRequestOperation *)saveBillWithBlock:(void (^)(NSArray *profiles, NSError *error))block {
    NSDictionary *parameters = @{@"SerialID": @"01"};
    
    return [[STBAPIClient sharedClient] POST:@"ICMPProfileGetter" parameters:parameters constructingBodyWithBlock:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
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
