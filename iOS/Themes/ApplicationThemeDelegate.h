//
//  ApplicationThemeDelegate.h
//  MiniPOS
//
//  Created by Nam Nguyen on 9/28/14.
//  Copyright (c) 2014 STB. All rights reserved.
//

#import <Foundation/Foundation.h>

//CGRect set positions
#define CGRectSetPos( r, x, y )     CGRectMake( x, y, r.size.width, r.size.height )
#define CGRectSetPosX( r, x)        CGRectMake( x, r.origin.y, r.size.width, r.size.height )
#define CGRectSetPosY( r, y )       CGRectMake( r.origin.x, y, r.size.width, r.size.height )
//CGRect set sizes
#define CGRectSetSize( r, w, h )    CGRectMake( r.origin.x, r.origin.y, w, h )
#define CGRectSetWidth( r, w)       CGRectMake( r.origin.x, r.origin.y, w, r.size.height )
#define CGRectSetHeight( r, h )     CGRectMake( r.origin.x, r.origin.y, r.size.width, h )
//CGSize set sizes
#define CGSizeSetWidth( s, w )      CGSizeMake(w, s.height)
#define CGSizeSetHeight( s, h )     CGSizeMake(s.width, h)

//activity indicator
#define kSpinnerSize    CGSizeMake(20, 20)

typedef enum {
    ButtonTypePrimary,
    ButtonTypeSecondary,
    ButtonTypeTertiary,
    ButtonTypeQuaternary
} ButtonType;

typedef enum {
    MenuIconNone,
    MenuIconSearch,
    MenuIconFavorites
} MenuIconType;

typedef enum {
    TableViewCellSingle,
    TableViewCellTop,
    TableViewCellMiddle,
    TableViewCellBottom
} TableViewCellType;

typedef enum {
    AlignmentTypeLeft,
    AlignmentTypeRight,
    AlignmentTypeCenter
} AlignmentType;

typedef enum {
    FunctionButtonDelete,
    FunctionButtonReset,
    FunctionButtonRefresh
} FunctionButtonType;

@protocol ApplicationThemeDelegate <NSObject>

#pragma mark - General setup

- (UIColor *)mainColor;
- (UIColor *)highlightColor;
- (UIColor *)secondaryColor;
- (UIColor *)placeHolderColor;
- (UIColor *)colorForLink;
- (UIColor *)highlightedColorForLink;
- (UIColor *)colorForLinkSecondary;
- (UIColor *)highlightedColorForLinkSecondary;

- (UIFont *)smallFontForTitle;
- (UIFont *)mediumFontForTitle;
- (UIFont *)bigFontForTitle;
- (UIFont *)mediumBoldFontForTitle;
- (UIFont *)bigBoldFontForTitle;

- (UIFont *)fontForHeader;
- (UIFont *)boldFontForHeader;
- (UIFont *)mediumBoldFontForHeader;

- (UIFont *)smallFontForContent;
- (UIFont *)regularFontForContent;
- (UIFont *)mediumFontForContent;
- (UIFont *)middleFontForContent;
- (UIFont *)bigFontForContent;
- (UIFont *)hugeFontForContent;

- (UIFont *)smallBoldFontForContent;
- (UIFont *)regularBoldFontForContent;
- (UIFont *)mediumBoldFontForContent;
- (UIFont *)middleBoldFontForContent;
- (UIFont *)hugeBoldFontForContent;

- (UIFont *)italicFontForContent;
- (UIFont *)smallItalicFontForContent;

- (UIImage *)imageForCheckboxForState:(UIControlState)state;

#pragma mark - Buttons

- (UIEdgeInsets)uiButtonDefaultTitleInsets;

- (UIImage *)uiButtonBackgroundImageForState:(UIControlState)state type:(ButtonType)buttonType;

#pragma mark - Table Views

- (UIColor *)colorForTableViewSeparator;

#pragma mark - Lines

- (UIImage *)separatorLine;

@end
