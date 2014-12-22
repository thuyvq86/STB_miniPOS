//
//  ICMPProfile.h
//  MiniPOS
//
//  Created by Nam Nguyen on 11/29/14.
//  Copyright (c) 2014 STB. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ICMPProfile : NSObject

@property (nonatomic, strong, readonly) EAAccessory *accessory;
@property (nonatomic, strong, readonly) ICISMPDevice *ismpDevice;
@property (nonatomic, strong) NSString *serialId;
@property (nonatomic, strong) NSString *merchantId;
@property (nonatomic, strong) NSString *merchantName;
@property (nonatomic, strong) NSString *phoneSerialId;
@property (nonatomic, strong) NSString *terminalId;

- (id)initWithAccessory:(EAAccessory *)aAccessory;
- (id)initWithDevice:(ICISMPDevice *)aICISMPDevice;

- (void)updateFromDictionary:(NSDictionary *)dict;

@end
