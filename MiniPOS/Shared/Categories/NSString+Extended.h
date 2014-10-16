//
//  NSString+Extended.h
//  Anibis
//
//  Created by Nam Nguyen on 11/13/13.
//  Copyright (c) 2013 Xmedia AG. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Extended)

// Remove newlines and white space from string.
- (NSString *)stringByRemovingNewLinesAndWhitespace;

//Validation
- (BOOL)isInteger;
- (BOOL)isDouble;

// Encode/decode a string to embed in an URL.
- (NSString *)urlencode;
- (NSString *)urldecode;
//Add a parameter/query to URL string
- (NSString *)URLStringByAppendingParameter:(NSString *)parameter;
- (NSString *)URLStringByAppendingQuery:(NSString *)query;

// Strips HTML tags & comments, removes extra whitespace and decodes HTML character entities.
- (NSString *)stringByConvertingHTMLToPlainText;
- (NSString *)stringByDecodingHTMLEntities;
- (NSString *)stringByStrippingTags;

@end
