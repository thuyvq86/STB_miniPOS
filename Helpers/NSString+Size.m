//
//  NSString+Size.m
//  AutoScout24
//
//  Created by Nam Nguyen on 6/10/14.
//  Copyright (c) 2014 AutoScout24. All rights reserved.
//

#import "NSString+Size.h"

@implementation NSString (Size)

- (CGFloat)heightForWidth:(CGFloat)width andFont:(UIFont *)font {
    if (!self || self.length == 0)
        return 0;
    
    CGSize stringSize = CGSizeZero;
    CGSize tempSize = CGSizeMake(width, MAXFLOAT);
    
    NSString *trimmedText = [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (SYSTEM_VERSION_LESS_THAN(@"7.0")) {
        // code here for iOS 5.0,6.0 and so on
        stringSize = [trimmedText sizeWithFont:font
                             constrainedToSize:tempSize
                                 lineBreakMode:NSLineBreakByWordWrapping];
    }
    else {
        // code here for iOS 7.0
        NSMutableParagraphStyle *textStyle = [self customParagraphStyleWithFont:font];
        NSDictionary *fontAttributes = @{NSFontAttributeName: font,
                                         NSParagraphStyleAttributeName: textStyle};
        NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:trimmedText attributes:fontAttributes];
        CGRect rect = [attributedText boundingRectWithSize:tempSize
                                                   options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin
                                                   context:nil];
        [attributedText release];
        
        stringSize = rect.size;
    }
    
    return ceilf(stringSize.height);
}

- (CGFloat)widthForHeight:(CGFloat)height andFont:(UIFont *)font {
    if (!self || self.length == 0)
        return 0;
    
    CGSize stringSize = CGSizeZero;
    CGSize tempSize = CGSizeMake(MAXFLOAT, height);
    
    NSString *trimmedText = [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (SYSTEM_VERSION_LESS_THAN(@"7.0")) {
        // code here for iOS 5.0,6.0 and so on
        stringSize = [trimmedText sizeWithFont:font
                             constrainedToSize:tempSize
                                 lineBreakMode:NSLineBreakByWordWrapping];
    }
    else {
        // code here for iOS 7.0
        NSMutableParagraphStyle *textStyle = [self customParagraphStyleWithFont:font];
        NSDictionary *fontAttributes = @{NSFontAttributeName: font,
                                         NSParagraphStyleAttributeName: textStyle};
        NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:trimmedText attributes:fontAttributes];
        CGRect rect = [attributedText boundingRectWithSize:tempSize
                                                   options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin
                                                   context:nil];
        [attributedText release];
        
        stringSize = rect.size;
    }
    
    return ceilf(stringSize.width);
}

- (NSMutableParagraphStyle *)customParagraphStyleWithFont:(UIFont *)font {
    NSMutableParagraphStyle *textStyle = nil;
    
    textStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    textStyle.alignment = NSTextAlignmentLeft;
    textStyle.paragraphSpacing = 0;
    textStyle.paragraphSpacingBefore = 0;
    
    return [textStyle autorelease];
}

@end
