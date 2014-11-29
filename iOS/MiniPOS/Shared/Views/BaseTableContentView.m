//
//  BaseView.m
//  AutoScout24
//
//  Created by Nam Nguyen on 12/31/13.
//  Copyright (c) 2013 AutoScout24. All rights reserved.
//

#import "BaseTableContentView.h"

@implementation BaseTableContentView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

#pragma mark - Theming

+ (UIFont *)headerFont{
    id<ApplicationThemeDelegate> theme = [ApplicationThemeManager sharedTheme];
    return (INTERFACE_IS_IPAD) ? [theme fontForHeader] : [theme mediumBoldFontForHeader];
}

+ (UIFont *)contentFont{
    id<ApplicationThemeDelegate> theme = [ApplicationThemeManager sharedTheme];
    return (INTERFACE_IS_IPAD) ? [theme mediumFontForContent] : [theme smallFontForContent];
}

+ (UIFont *)boldFont{
    id<ApplicationThemeDelegate> theme = [ApplicationThemeManager sharedTheme];
    return (INTERFACE_IS_IPAD) ? [theme mediumBoldFontForContent] : [theme smallBoldFontForContent];
}

+ (UIFont *)noticeFont{
    id<ApplicationThemeDelegate> theme = [ApplicationThemeManager sharedTheme];
    return (INTERFACE_IS_IPAD) ? [theme boldFontForHeader] : [theme mediumBoldFontForHeader];
}

+ (UIFont *)fontForCellValueInSearch{
    id<ApplicationThemeDelegate> theme = [ApplicationThemeManager sharedTheme];
    return (INTERFACE_IS_IPAD) ? [theme bigFontForContent] : [theme mediumFontForContent];
}

+ (UIFont *)detailHeaderFont{
    id<ApplicationThemeDelegate> theme = [ApplicationThemeManager sharedTheme];
    return (INTERFACE_IS_IPAD) ? [theme boldFontForHeader] : [theme mediumBoldFontForHeader];
}

+ (UIFont *)detailContentFont{
    id<ApplicationThemeDelegate> theme = [ApplicationThemeManager sharedTheme];
    return (INTERFACE_IS_IPAD) ? [theme middleFontForContent] : [theme smallFontForContent];
}

+ (UIFont *)regularMediumFont{
    return [FontManager sharedFontManager].regularMediumFont;
}

+ (UIFont *)regularLightFont{
    return [FontManager sharedFontManager].regularLightFont;
}

+ (UIFont *)smallLightFont{
    return [FontManager sharedFontManager].smallLightFont;
}

#pragma mark - controls

- (UITextField *)textFieldWithPlaceholder:(NSString *)placeholder delegate:(id)delegate action:(SEL)action{
    id<ApplicationThemeDelegate> theme = [ApplicationThemeManager sharedTheme];
    
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectZero];
    textField.font = [[self class] contentFont];
    textField.textColor = [theme mainColor];
    textField.backgroundColor = [UIColor clearColor];
    textField.borderStyle = UITextBorderStyleNone;
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    textField.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    textField.autocorrectionType = UITextAutocorrectionTypeNo;
    textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    textField.returnKeyType = UIReturnKeyDone;
    
    if (![AppUtils isEmptyText:placeholder])
        textField.placeholder = placeholder;
    
    if (delegate)
        [textField setDelegate:delegate];
    
    if (action)
        [textField addTarget:self action:action forControlEvents:UIControlEventEditingChanged];
    
    return textField;
}

- (UIButtonBase *)buttonWithType:(ButtonType)buttonType title:(NSString *)title action:(SEL)action{
    UIButtonBase *buttonBase = nil;
    CGRect frameBtn = CGRectMake(kLeftPadding, 0, kButtonWidth, kButtonHeight);
    
    if (buttonType == ButtonTypePrimary)
        buttonBase = [[UIButtonPrimary alloc] initWithFrame:frameBtn];
    else
        buttonBase = [[UIButtonSecondary alloc] initWithFrame:frameBtn];
    [buttonBase setTitle:title forState:UIControlStateNormal];
    [buttonBase setTitle:title forState:UIControlStateHighlighted];
    [buttonBase addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    
    return buttonBase;
}

#pragma mark - size of texts

+ (CGFloat)heightForDetailText:(NSString *)text width:(CGFloat)width font:(UIFont *)usedFont{
    if ([AppUtils isEmptyText:text])
        return 0;
    
    CGFloat heightOfText = [text heightForWidth:width andFont:usedFont];
    
    CGFloat height = heightOfText < kLabelHeight ? kLabelHeight : heightOfText;
    if (height > kLabelHeight)
        height += kLinePadding/2; //content padding
    
    return height;
}

@end
