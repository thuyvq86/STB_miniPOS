//
//  UIButtonBase.m
//  MiniPOS
//
//  Created by Nam Nguyen on 9/28/14.
//  Copyright (c) 2014 STB. All rights reserved.
//

#import "UIButtonBase.h"

@implementation UIButtonBase

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)fitButton{
    CGFloat newWidth = [self.titleLabel.text widthForHeight:self.frame.size.height andFont:self.titleLabel.font];
    newWidth += self.titleEdgeInsets.left + self.titleEdgeInsets.right;
    
    CGRect newFrame = CGRectMake(self.frame.origin.x, self.frame.origin.y, newWidth, self.frame.size.height);
    self.frame = newFrame;
}

- (void)fitButton:(AlignmentType)alignmentType {
    CGSize oldSize = self.frame.size;
    CGSize newSize = [self sizeThatFits:self.titleLabel.frame.size];
    CGFloat widthDiff = newSize.width - oldSize.width;
    CGFloat newX = 0;
    
    switch (alignmentType) {
        case AlignmentTypeLeft:
            self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width + widthDiff, self.frame.size.height);
            break;
            
        case AlignmentTypeCenter:
            newX = (self.frame.size.width - newSize.width)/2;
            self.frame = CGRectMake(self.frame.origin.x + newX, self.frame.origin.y, newSize.width, self.frame.size.height);
            break;
            
        case AlignmentTypeRight:
            newX = self.frame.origin.x - widthDiff;
            self.frame = CGRectMake(newX, self.frame.origin.y, self.frame.size.width + widthDiff, self.frame.size.height);
            break;
    }
}

- (CGSize)sizeThatFits:(CGSize)size {
    // ad insets
    id<ApplicationThemeDelegate> currentTheme = [ApplicationThemeManager sharedTheme];
    UIEdgeInsets edgeInsets = [currentTheme uiButtonDefaultTitleInsets];
    
    CGFloat newWidth = [self.titleLabel.text widthForHeight:self.frame.size.height andFont:self.titleLabel.font];
    newWidth += edgeInsets.left + edgeInsets.right;
    
    return CGSizeMake(newWidth, self.frame.size.height);
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    CGRect bounds = self.bounds;
    //Calculate offsets from buttons bounds
    
    float distance = 8.0;
    bounds = CGRectMake(bounds.origin.x - distance,
                        bounds.origin.y - distance,
                        bounds.size.width + 2 * distance,
                        bounds.size.height + 2 * distance);
    return CGRectContainsPoint(bounds, point);
}

#pragma mark - Setup

- (void)setTitleColorForType:(ButtonType)buttonType{
    id<ApplicationThemeDelegate> currentTheme = [ApplicationThemeManager sharedTheme];
    
    [self setTitleColor:[currentTheme mainColor] forState:UIControlStateNormal];
    [self setTitleColor:[currentTheme mainColor] forState:UIControlStateHighlighted];
}

- (void)setupBackgroundImageForType:(ButtonType)buttonType{
    id<ApplicationThemeDelegate> currentTheme = [ApplicationThemeManager sharedTheme];
    
    UIImage *backgroundImageNormal = [currentTheme uiButtonBackgroundImageForState:UIControlStateNormal type:buttonType];
    UIImage *backgroundImageTouch  = [currentTheme uiButtonBackgroundImageForState:UIControlStateHighlighted type:buttonType];
    
    [self setBackgroundImage:backgroundImageNormal forState:UIControlStateNormal];
    [self setBackgroundImage:backgroundImageTouch forState:UIControlStateHighlighted];
}

- (void)setBackgroundImageNormal:(UIImage *)backgroundImageNormal backgroundImageTouch:(UIImage *)backgroundImageTouch{
    [self setBackgroundImage:backgroundImageNormal forState:UIControlStateNormal];
    [self setBackgroundImage:backgroundImageTouch forState:UIControlStateHighlighted];
}

@end
