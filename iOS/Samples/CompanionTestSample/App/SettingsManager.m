//
//  SettingsManager.m
//  CardTest
//
//  Created by Hichem Boussetta on 15/11/11.
//  Copyright (c) 2011 Ingenico. All rights reserved.
//

#import "SettingsManager.h"

#define DEFAULT_IOS_TCP_PCL_PORT            5186
#define DEFAULT_TERMINAL_TCP_PCL_PORT       5188
#define DEFAULT_TERMINAL_IP                 @"1.1.1.2"

static SettingsManager * g_sharedSettingsManager = nil;


@interface SettingsManager ()

-(void)_checkDefaults;

@end


@implementation SettingsManager

@synthesize pclInterfaceType;
@synthesize iOSTcpPclPort;
@synthesize terminalPclTcpPort;
@synthesize terminalIP;


+(SettingsManager *)sharedSettingsManager {
    if (g_sharedSettingsManager == nil) {
        g_sharedSettingsManager = [[SettingsManager alloc] init];
    }
    return g_sharedSettingsManager;
}


-(id)init {
    if ((self = [super init])) {
        [self loadSettings];
    }
    return self;
}

-(oneway void)release {
    
}

-(void)loadSettings {
    NSLog(@"%s", __FUNCTION__);
    
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    
    //Dump User Defaults
    NSDictionary *bundleInfo = [[NSBundle mainBundle] infoDictionary];
    NSString *bundleId = [bundleInfo objectForKey: @"CFBundleIdentifier"];
    
    NSUserDefaults *appUserDefaults = [[NSUserDefaults alloc] init];
    NSLog(@"Start dumping userDefaults for %@", bundleId);
    NSLog(@"userDefaults dump: %@", [appUserDefaults persistentDomainForName: bundleId]);
    NSLog(@"Finished dumping userDefaults for %@", bundleId);
    [appUserDefaults release];
    
    //Load the user defaults
    self.pclInterfaceType       = [userDefaults integerForKey:@"pcl_interface_type"];
    self.iOSTcpPclPort          = [userDefaults integerForKey:@"ios_tcp_pcl_port"];
    self.terminalPclTcpPort     = [userDefaults integerForKey:@"terminal_tcp_pcl_port"];
    self.terminalIP             = [userDefaults stringForKey:@"terminal_ip"];
    
    //Check Defaults
    [self _checkDefaults];
}

-(void)_checkDefaults {
    NSLog(@"%s", __FUNCTION__);
    
    if (self.iOSTcpPclPort <= 0) {
        self.iOSTcpPclPort = DEFAULT_IOS_TCP_PCL_PORT;
    }
    
    if (self.terminalPclTcpPort <= 0) {
        self.terminalPclTcpPort = DEFAULT_TERMINAL_TCP_PCL_PORT;
    }
    
    if ((self.terminalIP == nil) || ([[self.terminalIP stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""])) {
        self.terminalIP = DEFAULT_TERMINAL_IP;
    }
}

-(void)saveSettings {
    NSLog(@"%s", __FUNCTION__);
    
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    
    //Save the user defaults
    [userDefaults setInteger:self.pclInterfaceType forKey:@"pcl_interface_type"];
    [userDefaults setInteger:self.iOSTcpPclPort forKey:@"ios_tcp_pcl_port"];
    [userDefaults setInteger:self.terminalPclTcpPort forKey:@"terminal_tcp_pcl_port"];
    [userDefaults setObject:self.terminalIP forKey:@"terminal_ip"];
}


@end
