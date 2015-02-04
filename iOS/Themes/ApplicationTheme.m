//
//  ApplicationTheme.m
//  MiniPOS
//
//  Created by Nam Nguyen on 9/28/14.
//  Copyright (c) 2014 STB. All rights reserved.
//

#import "ApplicationTheme.h"

@implementation ApplicationTheme

- (id)init {
    if(self = [super init]) {
    }
    return self;
}

#pragma mark - General setup

- (UIColor *)mainColor{
    return [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
}

- (UIColor *)highlightColor{
    return [UIColor colorWithRed:255.0/255.0 green:117.0/255.0 blue:0.0/255.0 alpha:1.0];
}

#pragma mark - Common setup

- (UIColor *)secondaryColor {
    return [UIColor whiteColor];
}

- (UIColor *)placeHolderColor {
    return [UIColor colorWithRed:102.0/255.0 green:102.0/255.0 blue:102.0/255.0 alpha:1.0];
}

- (UIColor *)colorForLink {
    return [UIColor colorWithRed:0 green:102.0/255.0 blue:204.0/255.0 alpha:1.0];
}

- (UIColor *)highlightedColorForLink {
    return [UIColor colorWithRed:20.0/255.0 green:89.0/255.0 blue:158.0/255.0 alpha:1.0];
}

- (UIColor *)colorForLinkSecondary{
    return [UIColor colorWithRed:1.0/255.0 green:122.0/255.0 blue:255.0/255.0 alpha:1.0];
}

- (UIColor *)highlightedColorForLinkSecondary{
    return [UIColor colorWithRed:1.0/255.0 green:122.0/255.0 blue:255.0/255.0 alpha:1.0];
}

- (UIFont *)smallFontForTitle {
    return [UIFont systemFontOfSize:16.0f];
}

- (UIFont *)mediumFontForTitle {
    return [UIFont systemFontOfSize:17.0f];
}

- (UIFont *)bigFontForTitle {
    return [UIFont systemFontOfSize:21.0f];
}

- (UIFont *)mediumBoldFontForTitle {
    return [UIFont boldSystemFontOfSize:19.0f];
}

- (UIFont *)bigBoldFontForTitle {
    return [UIFont boldSystemFontOfSize:21.0f];
}

- (UIFont *)fontForHeader{
    return [UIFont systemFontOfSize:17.0f];
}

- (UIFont *)boldFontForHeader{
    return [UIFont boldSystemFontOfSize:17.0f];
}

- (UIFont *)mediumBoldFontForHeader{
    return [UIFont boldSystemFontOfSize:14.0f];
}

- (UIFont *)smallFontForContent {
    return [UIFont systemFontOfSize:12.0f];
}

- (UIFont *)regularFontForContent {
    return [UIFont systemFontOfSize:13.0f];
}

- (UIFont *)mediumFontForContent{
    return [UIFont systemFontOfSize:14.0f];
}

- (UIFont *)middleFontForContent{
    return [UIFont systemFontOfSize:15.0];
}

- (UIFont *)bigFontForContent {
    return [UIFont systemFontOfSize:16.0f];
}

- (UIFont *)hugeFontForContent {
    return [UIFont systemFontOfSize:27.0f];
}

- (UIFont *)smallBoldFontForContent {
    return [UIFont boldSystemFontOfSize:12.0f];
}

- (UIFont *)regularBoldFontForContent {
    return [UIFont boldSystemFontOfSize:13.0f];
}

- (UIFont *)mediumBoldFontForContent{
    return [UIFont boldSystemFontOfSize:13.5f];
}

- (UIFont *)middleBoldFontForContent {
    return [UIFont boldSystemFontOfSize:16.5f];
}

- (UIFont *)hugeBoldFontForContent {
    return [UIFont boldSystemFontOfSize:33.0f];
}

- (UIFont *)italicFontForContent {
    return [UIFont italicSystemFontOfSize:15.0f];
}

- (UIFont *)smallItalicFontForContent {
    return [UIFont italicSystemFontOfSize:12.0f];
}

- (UIImage *)imageForCheckboxForState:(UIControlState)state {
    NSString *imageName = @"UIButtonCheckbox";
    if (state == UIControlStateSelected)
        imageName = [imageName stringByAppendingString:@"Touch"];
    
    return [UIImage imageNamed:imageName];
}

#pragma mark - Buttons

- (UIEdgeInsets)uiButtonDefaultTitleInsets{
    return UIEdgeInsetsMake(0, 10.0f, 0, 10.0f);
}

- (UIImage *)uiButtonBackgroundImageForState:(UIControlState)state type:(ButtonType)buttonType{
    NSString *imageName = @"UIButton";
    switch (buttonType) {
        case ButtonTypePrimary:
            imageName = [imageName stringByAppendingString:@"Primary"];
            break;
            
        case ButtonTypeSecondary:
            imageName = [imageName stringByAppendingString:@"Secondary"];
            break;
            
        case ButtonTypeTertiary:
            imageName = [imageName stringByAppendingString:@"Tertiary"];
            break;
            
        case ButtonTypeQuaternary:
            imageName = [imageName stringByAppendingString:@"Quaternary"];
            break;
            
        default:
            break;
    }
    
    if (state == UIControlStateHighlighted)
        imageName = [imageName stringByAppendingString:@"Touch"];
    
    return [[UIImage imageNamed:imageName] stretchableImageWithLeftCapWidth:6 topCapHeight:0];
}

#pragma mark - Table Views

- (UIColor *)colorForTableViewSeparator{
    return [UIColor colorWithRed:234.0/255.0 green:234.0/255.0 blue:212.0/234.0 alpha:1.0];
}

#pragma mark - Lines

- (UIImage *)separatorLine{
    return [UIImage imageNamed:@"SeparatorLine"];
}

@end
