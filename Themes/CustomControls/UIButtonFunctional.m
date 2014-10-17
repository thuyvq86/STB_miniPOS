//
//  UIButtonFunctional.m
//  MiniPOS
//
//  Created by Nam Nguyen on 10/4/14.
//  Copyright (c) 2014 STB. All rights reserved.
//

#import "UIButtonFunctional.h"

@implementation UIButtonFunctional

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setup];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setup];
}

- (void)setup
{
    id<ApplicationThemeDelegate> currentTheme = [ApplicationThemeManager sharedTheme];
    
    [self setBackgroundColor:[UIColor clearColor]];
    [self.titleLabel setFont:[currentTheme mediumFontForContent]];
    
    // Text color
//    [self setTitleColor:[currentTheme functionalButtonTitleColorForState:UIControlStateNormal] forState:UIControlStateNormal];
//    [self setTitleColor:[currentTheme functionalButtonTitleColorForState:UIControlStateNormal] forState:UIControlStateHighlighted];
//    [self setTitleColor:[currentTheme functionalButtonTitleColorForState:UIControlStateHighlighted] forState:UIControlStateDisabled];
}

- (void)setupBackgroundImageForType:(FunctionButtonType)buttonType
{
    id<ApplicationThemeDelegate> currentTheme = [ApplicationThemeManager sharedTheme];
    
    UIImage *backgroundImageNormal = nil;//[currentTheme uiButtonBackgroundImageForState:UIControlStateNormal type:buttonType];
    UIImage *backgroundImageTouch  = nil;//[currentTheme uiButtonBackgroundImageForState:UIControlStateHighlighted type:buttonType];
    
    [self setBackgroundImageNormal:backgroundImageNormal backgroundImageTouch:backgroundImageTouch];
}

- (void)fitButton {
    CGSize newSize = [self sizeThatFits:self.titleLabel.frame.size];
    float newWidth = newSize.width + self.titleEdgeInsets.left + self.titleEdgeInsets.right;
    
    CGRect newFrame = CGRectMake(self.frame.origin.x, self.frame.origin.y, newWidth, self.frame.size.height);
    
    self.frame = newFrame;
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGFloat width = [self.titleLabel.text widthForHeight:self.frame.size.height andFont:self.titleLabel.font];
    return CGSizeMake(width, self.frame.size.height);
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    CGRect bounds = self.bounds;
    //Calculate offsets from buttons bounds
    
    float distance = 5.0f;
    
    bounds = CGRectMake(bounds.origin.x - distance,
                        bounds.origin.y - distance,
                        bounds.size.width + 2 * distance,
                        bounds.size.height + 2 * distance);
    
    return CGRectContainsPoint(bounds, point);
}

@end
