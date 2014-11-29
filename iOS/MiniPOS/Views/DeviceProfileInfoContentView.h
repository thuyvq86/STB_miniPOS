//
//  DeviceProfileInfoContentView.h
//  MiniPOS
//
//  Created by Nam Nguyen on 11/29/14.
//  Copyright (c) 2014 STB. All rights reserved.
//

#import "BaseTableContentView.h"

@interface DeviceProfileInfoContentView : BaseTableContentView

@property (nonatomic, strong) ICMPProfile *profile;

+ (CGFloat)heightForProfile:(ICMPProfile*)aProfile parentWidth:(CGFloat)parentWidth;

@end
