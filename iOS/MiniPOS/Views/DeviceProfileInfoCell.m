//
//  DeviceProfileInfoCell.m
//  MiniPOS
//
//  Created by Nam Nguyen on 11/29/14.
//  Copyright (c) 2014 STB. All rights reserved.
//

#import "DeviceProfileInfoCell.h"
#import "DeviceProfileInfoContentView.h"


@interface DeviceProfileInfoCell()

@property (nonatomic, strong) DeviceProfileInfoContentView *deviceProfileInfoContentView;

@end

@implementation DeviceProfileInfoCell

@synthesize profile = _profile;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        CGRect frame = CGRectMake(0, CGRectGetMinY(self.contentView.frame), CGRectGetWidth(self.contentView.frame), CGRectGetHeight(self.contentView.frame));
        self.deviceProfileInfoContentView = [[DeviceProfileInfoContentView alloc] initWithFrame:frame];
        [self.contentView addSubview:_deviceProfileInfoContentView];
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

+ (CGFloat)heightForProfile:(ICMPProfile*)aProfile parentWidth:(CGFloat)parentWidth{
    CGFloat width = parentWidth;
    return [DeviceProfileInfoContentView heightForProfile:aProfile parentWidth:width];
}

- (void)setProfile:(ICMPProfile *)profile{
    _profile = profile;
    [_deviceProfileInfoContentView setProfile:_profile];
}

@end
