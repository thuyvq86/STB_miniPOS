//
//  UILabel+MixFont.m
//  Refs: http://stackoverflow.com/questions/3586871/bold-non-bold-text-in-a-single-uilabel
//
//  Created by Nam Nguyen on 6/26/14.
//  Copyright (c) 2014 AutoScout24. All rights reserved.
//

#import "UILabel+MixFont.h"

@implementation UILabel (MixFont)

- (void)boldRange:(NSRange)range {
    [self mixFontForRange:range font:[UIFont boldSystemFontOfSize:self.font.pointSize]];
}

- (void)boldSubstring:(NSString *)substring {
    NSRange range = [self.text rangeOfString:substring];
    [self boldRange:range];
}

- (void)mixFontForSubstring:(NSString *)substring font:(UIFont *)font{
    NSRange range = [self.text rangeOfString:substring];
    [self mixFontForRange:range font:font];
}

// iOS6 and above : Use NSAttributedStrings
- (void)mixFontForRange:(NSRange)range font:(UIFont *)font{
    if (![self respondsToSelector:@selector(setAttributedText:)])
        return;
    
    // Create the attributed string (text + attributes)
    NSMutableAttributedString *attributedText = nil;
    if (!self.attributedText)
        attributedText = [[NSMutableAttributedString alloc] initWithString:self.text];
    else
        attributedText = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];
    
//    [attributedText beginEditing];
    [attributedText setAttributes:@{NSFontAttributeName:font} range:range];
//    [attributedText endEditing];
    
    // Set it in our UILabel and we are done!
    [self setAttributedText:attributedText];
}

@end
