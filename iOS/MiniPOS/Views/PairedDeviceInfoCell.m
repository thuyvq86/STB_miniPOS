//
//  PairedDeviceInfoCell.m
//  MiniPOS
//
//  Created by Nam Nguyen on 12/10/14.
//  Copyright (c) 2014 STB. All rights reserved.
//

#import "PairedDeviceInfoCell.h"
#import "BaseTableContentView.h"

@implementation PairedDeviceInfoCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
    
    [self theming];
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self theming];
    }
    
    return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self theming];
    }
    
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)theming{
    id<ApplicationThemeDelegate> theme = [ApplicationThemeManager sharedTheme];
    
    self.accessoryType = UITableViewCellAccessoryNone;
    self.selectionStyle = UITableViewCellSelectionStyleGray;
    
    self.textLabel.textColor = [UIColor whiteColor];
    self.textLabel.font = [theme fontForHeader];
    
    self.detailTextLabel.backgroundColor = [UIColor greenColor];
    self.detailTextLabel.text = @" ";
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

- (void)setPairedDevice:(ICMPProfile *)pairedDevice{
    _pairedDevice = pairedDevice;
    
    self.textLabel.text = [_pairedDevice displayableName];
    
    //Active | Not active
    UIColor *textColor = [UIColor whiteColor];
    if ([_pairedDevice.serialId isEqualToString:[ICISMPDevice serialNumber]])
        textColor = [UIColor greenColor];
    self.textLabel.textColor = textColor;
    
    [self setNeedsDisplay];
}

@end
