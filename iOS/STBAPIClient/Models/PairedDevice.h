//
//  PairedDevice.h
//  MiniPOS
//
//  Created by Nam Nguyen on 12/22/14.
//  Copyright (c) 2014 STB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMBaseEntity.h"

@interface PairedDevice : XMBaseEntity <XMBaseEntityProtocol>

@property (nonatomic, strong) NSString *serialNumber;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *desc;
@property (nonatomic, strong) NSDate *lastModifiedDate;


+ (id)getBySerialNumber:(NSString *)serialNumber;
+ (NSInteger)getCount;

@end
