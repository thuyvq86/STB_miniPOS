//
//  NSString+Size.h
//  AutoScout24
//
//  Created by Nam Nguyen on 6/10/14.
//  Copyright (c) 2014 AutoScout24. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SYSTEM_VERSION_LESS_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

@interface NSString (Size)

//String Sizes
- (CGFloat)heightForWidth:(CGFloat)width andFont:(UIFont *)font;
- (CGFloat)widthForHeight:(CGFloat)height andFont:(UIFont *)font;

//
- (NSMutableParagraphStyle *)customParagraphStyleWithFont:(UIFont *)font;

@end
