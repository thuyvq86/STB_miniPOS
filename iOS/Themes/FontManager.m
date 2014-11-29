//
//  FontManager.m
//  MiniPOS
//
//  Created by Nam Nguyen on 9/28/14.
//  Copyright (c) 2014 STB. All rights reserved.
//

#import "FontManager.h"

@interface FontManager ()

@end

@implementation FontManager

static NSString *kLightFontName  = @"HelveticaNeue-Light";
static NSString *kMediumFontName = @"HelveticaNeue-Medium";
static NSString *kNormalFontName = @"HelveticaNeue";

#pragma mark - Singleton

+ (FontManager *)sharedFontManager {
    static FontManager *sharedFontManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedFontManager = [[FontManager alloc] init];
    });
    
    return sharedFontManager;
}

#pragma mark - init

- (id)init {
    self = [super init];
    if (self) {
        _smallLightFont    = [[self class] lightFontWithSize:12.0f];
        _regularLightFont  = [[self class] lightFontWithSize:14.0f];

        _regularMediumFont = [[self class] mediumFontWithSize:14.0f];
    }
    return self;
}

#pragma mark - Helpers

+ (UIFont *)lightFontWithSize:(CGFloat)fontSize{
    return [UIFont fontWithName:kLightFontName size:fontSize];
}

+ (UIFont *)normalFontWithSize:(CGFloat)fontSize{
//    return [UIFont fontWithName:kNormalFontName size:fontSize];
    return [UIFont systemFontOfSize:fontSize];
}

+ (UIFont *)mediumFontWithSize:(CGFloat)fontSize{
    return [UIFont fontWithName:kMediumFontName size:fontSize];
}

@end
