//
//  SettingsManager.h
//  CardTest
//
//  Created by Hichem Boussetta on 15/11/11.
//  Copyright (c) 2011 Ingenico. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    SERIAL = 0,
    TCP
} PclInterfaceTypes;

@interface SettingsManager : NSObject

//Exported properties
@property (nonatomic) NSInteger pclInterfaceType;
@property (nonatomic) NSInteger iOSTcpPclPort;
@property (nonatomic) NSInteger terminalPclTcpPort;
@property (nonatomic, strong) NSString* terminalIP;

+ (SettingsManager *)sharedSettingsManager;

- (void)saveSettings;
- (void)loadSettings;

@end
