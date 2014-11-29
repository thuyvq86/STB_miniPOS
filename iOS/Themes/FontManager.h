//
//  FontManager.h
//  MiniPOS
//
//  Created by Nam Nguyen on 9/28/14.
//  Copyright (c) 2014 STB. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FontManager : NSObject

+ (FontManager *)sharedFontManager;

#pragma mark - Light font

@property (strong, nonatomic, readonly) UIFont* smallLightFont;     // 12
@property (strong, nonatomic, readonly) UIFont* regularLightFont;   // 14

#pragma mark - Medium font

@property (strong, nonatomic, readonly) UIFont* regularMediumFont;  // 14

#pragma mark - Helpers

+ (UIFont *)lightFontWithSize:(CGFloat)fontSize;
+ (UIFont *)normalFontWithSize:(CGFloat)fontSize;
+ (UIFont *)mediumFontWithSize:(CGFloat)fontSize;

@end
