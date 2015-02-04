//
//  PairedDevice.h
//  MiniPOS
//
//  Created by Nam Nguyen on 12/22/14.
//  Copyright (c) 2014 STB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMBaseEntity.h"

@interface ICMPProfile : XMBaseEntity <XMBaseEntityProtocol>

@property (nonatomic, strong) NSString *serialId;
@property (nonatomic, strong) NSString *merchantId;
@property (nonatomic, strong) NSString *merchantName;
@property (nonatomic, strong) NSString *phoneSerialId;
@property (nonatomic, strong) NSString *terminalId;
@property (nonatomic, strong) NSDate *lastModifiedDate;

- (NSString *)descriptionOfProfile;
- (NSString *)displayableName;

- (id)initWithICISMPDevice;
- (BOOL)updateFromDictionary:(NSDictionary *)dict;
- (BOOL)resetProfile;

+ (id)getBySerialNumber:(NSString *)serialNumber;
+ (NSInteger)getCount;

#pragma mark - Delete

+ (BOOL)deleteDuplicatedData;

@end
