//
//  ICMPProfile.m
//  MiniPOS
//
//  Created by Nam Nguyen on 11/29/14.
//  Copyright (c) 2014 STB. All rights reserved.
//

#import "ICMPProfile.h"

@implementation ICMPProfile

@synthesize accessory = _accessory;
@synthesize ismpDevice = _ismpDevice;
@synthesize serialId;
@synthesize merchantId;
@synthesize merchantName;
@synthesize phoneSerialId;
@synthesize terminalId;

- (id)initWithAccessory:(EAAccessory *)aAccessory{
    self = [super init];
    if (self) {
        _accessory = aAccessory;
#if !(TARGET_IPHONE_SIMULATOR)
        self.serialId = _accessory.serialNumber;
#endif
    }
    
    return self;
}

- (id)initWithDevice:(ICISMPDevice *)aICISMPDevice{
    self = [super init];
    if (self) {
        _ismpDevice = aICISMPDevice;
#if !(TARGET_IPHONE_SIMULATOR)
        self.serialId = [ICISMPDevice serialNumber];
#endif
    }
    
    return self;
}

- (void)updateFromDictionary:(NSDictionary *)dict{
    self.merchantId = [[dict objectForKey:@"MerchantID"] stringByRemovingNewLinesAndWhitespace];
    self.merchantName = [[dict objectForKey:@"MerchantName"] stringByRemovingNewLinesAndWhitespace];
    self.phoneSerialId = [[dict objectForKey:@"PhoneSerialID"] stringByRemovingNewLinesAndWhitespace];
    self.terminalId = [[dict objectForKey:@"TerminalID"] stringByRemovingNewLinesAndWhitespace];
//    self.serialId = [[dict objectForKey:@"SerialID"] stringByRemovingNewLinesAndWhitespace];
}

@end
