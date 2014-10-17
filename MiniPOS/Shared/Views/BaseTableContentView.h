//
//  BaseView.h
//  AutoScout24
//
//  Created by Nam Nguyen on 12/31/13.
//  Copyright (c) 2013 AutoScout24. All rights reserved.
//

#import <UIKit/UIKit.h>



#pragma mark - Consts

#define kLeftPadding   9.0f
#define kLinePadding   10.0f
#define kTopPadding    12.0f
#define kBottomPadding 12.0f

#define kLabelHeight   20.0f
#define kTitleHeight   25.0f

#define kWidthOfDetailContentViewForPhone SCREEN_WIDTH - 2*kLeftPadding + 1.0f

//keys
static NSString *const kTitle               = @"TitleKey";//header
static NSString *const kDescription         = @"DescriptionKey";
static NSString *const kFooter              = @"FooterKey";
static NSString *const kDataArray           = @"DataArrayKey";
static NSString *const kEmail               = @"EmailKey";

static NSString *const kEmailPlaceHolder    = @"EmailPlaceHolderKey";
static NSString *const kPasswordPlaceHolder = @"PasswordPlaceHolderKey";

static NSString *const kDirectLink          = @"DirectLinkKey";
static NSString *const kTrackingURL         = @"TrackingURLKey";

static NSString *const kTitleButton         = @"TitleButtonKey";
static NSString *const kIsPrimaryButton     = @"IsPrimaryButtonKey";

static NSString *const kHasBottomLine       = @"HasBottomLineKey";
static NSString *const kIsRegisterUser      = @"IsRegisterUserKey";
static NSString *const kHasInfoIcon         = @"HasInfoIconKey";

#pragma mark - View

@interface BaseTableContentView : UIView

// Theming
+ (UIFont *)headerFont;
+ (UIFont *)contentFont;
+ (UIFont *)boldFont;
+ (UIFont *)noticeFont;
+ (UIFont *)fontForCellValueInSearch;
+ (UIFont *)detailHeaderFont;
+ (UIFont *)detailContentFont;

// For iOS 7 Style
+ (UIFont *)regularMediumFont;
+ (UIFont *)regularLightFont;
+ (UIFont *)smallLightFont;

// Controls
- (UITextField *)textFieldWithPlaceholder:(NSString *)placeholder delegate:(id)delegate action:(SEL)action;

// Primary button || Secondary button
- (UIButtonBase *)buttonWithType:(ButtonType)buttonType title:(NSString *)title action:(SEL)action;

// Size of texts
+ (CGFloat)heightForDetailText:(NSString *)text width:(CGFloat)width font:(UIFont *)usedFont;

@end
