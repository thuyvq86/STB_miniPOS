//
//  DeviceProfileInfoContentView.m
//  MiniPOS
//
//  Created by Nam Nguyen on 11/29/14.
//  Copyright (c) 2014 STB. All rights reserved.
//

#import "DeviceProfileInfoContentView.h"

@interface DeviceProfileInfoContentView()

@end

@implementation DeviceProfileInfoContentView

@synthesize profile = _profile;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.backgroundColor = [UIColor clearColor];
        self.opaque = YES;
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    if ([self.layer respondsToSelector:@selector(setDrawsAsynchronously:)])
        [self.layer setDrawsAsynchronously:YES];
    
    id<ApplicationThemeDelegate> theme = [ApplicationThemeManager sharedTheme];
    UIFont *normalFont = [theme fontForHeader]; //normal
    UIImage *lineImage = [theme separatorLine];
    
    CGFloat width    = CGRectGetWidth(rect) - 2*kLeftPadding;
    NSInteger offset = kTopPadding;
    
    NSString *text = [[self class] connectedAccessoryString:self.profile];
    
    //set text color
    [[UIColor whiteColor] set];
    
    //draw text
    CGFloat height = [text heightForWidth:width andFont:normalFont];
    [text drawInRect:CGRectMake(kLeftPadding, offset, width, height) withFont:normalFont lineBreakMode:NSLineBreakByWordWrapping];
    offset += height + kTopPadding;
    
    //draw bottom line
    [lineImage drawInRect:CGRectMake(kLeftPadding, offset, width, 1)];
}

+ (CGFloat)heightForProfile:(ICMPProfile *)aProfile parentWidth:(CGFloat)parentWidth{
    id<ApplicationThemeDelegate> theme = [ApplicationThemeManager sharedTheme];
    UIFont *normalFont = [theme fontForHeader]; //normal
    UIImage *lineImage = [theme separatorLine];
    
    NSString *text = [self connectedAccessoryString:aProfile];
    
    NSInteger height = 0;
    CGFloat width = parentWidth - 2*kLeftPadding;
    
    height += kTopPadding;
    height += [text heightForWidth:width andFont:normalFont];
    height += kTopPadding;
    height += ceil(lineImage.size.height); //separator line
    
    return height;
}

+ (NSString *)connectedAccessoryString:(ICMPProfile *)aProfile{
#if TARGET_IPHONE_SIMULATOR
    return [NSString stringWithFormat:@"iCMP-%@", aProfile.serialId];
#endif
    
    EAAccessory *connectedAccessory = aProfile.accessory;
    if (!connectedAccessory)
        return nil;
    
    NSArray *protocolStrings = [connectedAccessory protocolStrings];
    NSString *msg = [NSString stringWithFormat:
                     @"connected: %d\nconnectionID: %d\nname: %@\nmanufacturer: %@\nmodelNumber: %@\nserialId: %@\nfirmwareReveision: %@\nhardwareRevision: %@\nprotocolStrings: %@",
                     
                     connectedAccessory.connected,
                     connectedAccessory.connectionID,
                     connectedAccessory.name,
                     connectedAccessory.manufacturer,
                     connectedAccessory.modelNumber,
                     connectedAccessory.serialNumber,
                     connectedAccessory.firmwareRevision,
                     connectedAccessory.hardwareRevision,
                     [protocolStrings componentsJoinedByString:@"\n"]
                     ];
    
    return msg;
}

- (void)setProfile:(ICMPProfile *)profile{
    if (_profile != profile) {
        _profile = profile;
        
        [self setNeedsDisplay];
    }
}

@end
