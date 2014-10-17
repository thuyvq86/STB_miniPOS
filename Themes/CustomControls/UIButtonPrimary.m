//
//  UIButtonPrimary.m
//  MiniPOS
//
//  Created by Nam Nguyen on 9/28/14.
//  Copyright (c) 2014 STB. All rights reserved.
//

#import "UIButtonPrimary.h"

@implementation UIButtonPrimary

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setup];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setup];
}

- (void)setup {
    id<ApplicationThemeDelegate> currentTheme = [ApplicationThemeManager sharedTheme];
    
    [self setBackgroundColor:[UIColor clearColor]];
    [self setupBackgroundImageForType:ButtonTypePrimary];
    
    [self setTitleColor:[currentTheme mainColor] forState:UIControlStateNormal];
    [self setTitleColor:[currentTheme mainColor] forState:UIControlStateHighlighted];
    
    [self.titleLabel setFont:[currentTheme mediumFontForContent]];
    [self.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [self setTitleEdgeInsets:UIEdgeInsetsMake(-1, 0, 0, 0)];
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    CGRect bounds = self.bounds;
    float distance = 5.0;
    
    bounds = CGRectMake(bounds.origin.x - distance,
                        bounds.origin.y - distance,
                        bounds.size.width + 2 * distance,
                        bounds.size.height + 2 * distance);
    
    return CGRectContainsPoint(bounds, point);
}

@end
