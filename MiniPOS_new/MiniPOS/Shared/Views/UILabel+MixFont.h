//
//  UILabel+MixFont.h
//  AutoScout24
//
//  Created by Nam Nguyen on 6/26/14.
//  Copyright (c) 2014 AutoScout24. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (MixFont)

//bold text with the default font
- (void)boldSubstring:(NSString *)substring;
- (void)boldRange:(NSRange)range;

//update text with the customized font
- (void)mixFontForSubstring:(NSString *)substring font:(UIFont *)font;
- (void)mixFontForRange:(NSRange)range font:(UIFont *)font;

@end
