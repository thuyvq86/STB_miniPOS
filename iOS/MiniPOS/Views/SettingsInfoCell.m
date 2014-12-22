//
//  SettingsInfoCellTableViewCell.m
//  MiniPOS
//
//  Created by Nam Nguyen on 12/10/14.
//  Copyright (c) 2014 STB. All rights reserved.
//

#import "SettingsInfoCell.h"
#import "BaseTableContentView.h"

@implementation SettingsInfoCell

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self theming];
    }
    
    return self;
}

- (void)awakeFromNib {
    // Initialization code
    [self theming];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)theming{
    id<ApplicationThemeDelegate> theme = [ApplicationThemeManager sharedTheme];
    
    self.textLabel.textColor = [UIColor whiteColor];
    self.textLabel.font = [theme fontForHeader];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    if ([self.layer respondsToSelector:@selector(setDrawsAsynchronously:)])
        [self.layer setDrawsAsynchronously:YES];
    
    id<ApplicationThemeDelegate> theme = [ApplicationThemeManager sharedTheme];
    UIImage *lineImage = [theme separatorLine];
    
    CGFloat width    = CGRectGetWidth(rect) - 2*kLeftPadding;
    NSInteger offset = CGRectGetHeight(rect) - 1.0f;
    
    //draw bottom line
    [lineImage drawInRect:CGRectMake(kLeftPadding, offset , width, 1.0f)];
}

@end
