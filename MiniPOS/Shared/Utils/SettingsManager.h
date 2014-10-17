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
@property (nonatomic, assign) NSInteger               pclInterfaceType;
@property (nonatomic, assign) NSInteger               iOSTcpPclPort;
@property (nonatomic, assign) NSInteger               terminalPclTcpPort;
@property (nonatomic, retain) NSString              * terminalIP;


+ (SettingsManager *)sharedSettingsManager;

- (void)saveSettings;
- (void)loadSettings;

@end
