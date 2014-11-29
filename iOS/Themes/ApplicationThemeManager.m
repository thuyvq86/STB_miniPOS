//
//  ApplicationThemeManager.m
//  MiniPOS
//
//  Created by Nam Nguyen on 9/28/14.
//  Copyright (c) 2014 STB. All rights reserved.
//

#import "ApplicationThemeManager.h"
#import "ApplicationTheme.h"

@implementation ApplicationThemeManager

+ (id <ApplicationThemeDelegate>)sharedTheme{
    static id <ApplicationThemeDelegate> sharedTheme = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // Create and return the theme:
        sharedTheme = [[ApplicationTheme alloc] init];
    });
    
    return sharedTheme;
}

+ (void)themeForNavigationBar:(UINavigationBar *)navigationBar{
    id<ApplicationThemeDelegate> currentTheme = [ApplicationThemeManager sharedTheme];
    
    UIFont *titleFont        = INTERFACE_IS_IPHONE ? [currentTheme mediumBoldFontForTitle] : [currentTheme bigFontForTitle];
    UIColor *textColor       = IOS7_OR_GREATER ? [currentTheme mainColor] : [currentTheme secondaryColor];
    
    NSDictionary *textAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                    textColor, UITextAttributeTextColor,
                                    [NSValue valueWithUIOffset:UIOffsetMake(0, 1)], UITextAttributeTextShadowOffset,
                                    titleFont, UITextAttributeFont,
                                    nil];
    
    [navigationBar setBarStyle:IOS7_OR_GREATER ? UIBarStyleDefault : UIBarStyleBlackOpaque];
    [navigationBar setTitleTextAttributes:textAttributes];
}


@end
