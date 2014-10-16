//
//  NSString+DrawText.m
//  AutoScout24
//
//  Created by Nam Nguyen on 6/10/14.
//  Copyright (c) 2014 AutoScout24. All rights reserved.
//

#import "NSString+DrawText.h"
#import "NSString+Size.h"
#import <objc/message.h>

@implementation NSString (DrawText)

- (void)drawInRect:(CGRect)frame andFont:(UIFont *)font color:(UIColor *)color {
    if (SYSTEM_VERSION_LESS_THAN(@"7.0")) {
        // code here for iOS 5.0,6.0 and so on
        [color set];
        [self drawInRect:frame withFont:font lineBreakMode:NSLineBreakByTruncatingTail alignment:NSTextAlignmentLeft];
    }
    else {
        // code here for iOS 7.0
        NSMutableParagraphStyle *textStyle = [self customParagraphStyleWithFont:font];
        NSStringDrawingOptions drawingOption = NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin;
        NSDictionary *fontAttributes = @{NSFontAttributeName:font,
                                         NSForegroundColorAttributeName: color,
                                         NSParagraphStyleAttributeName: textStyle};
        
        objc_msgSend(self, @selector(drawWithRect:options:attributes:context:), frame, drawingOption, fontAttributes, nil);
    }
}

\
@end
