//
//  NSString+DrawText.h
//  AutoScout24
//
//  Created by Nam Nguyen on 6/10/14.
//  Copyright (c) 2014 AutoScout24. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (DrawText)

- (void)drawInRect:(CGRect)frame andFont:(UIFont *)font color:(UIColor *)color;

@end
