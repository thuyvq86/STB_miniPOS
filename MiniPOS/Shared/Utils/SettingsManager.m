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

static NSString *const INTERFACE_TYPE_KEY        = @"pcl_interface_type";
static NSString *const IOS_TCP_PCL_PORT_KEY      = @"ios_tcp_pcl_port";
static NSString *const TERMINAL_TCP_PCL_PORT_KEY = @"terminal_tcp_pcl_port";
static NSString *const TERMINAL_IP_KEY           = @"terminal_ip";

static SettingsManager * g_sharedSettingsManager = nil;

@interface SettingsManager ()

- (void)_checkDefaults;

@end

@implementation SettingsManager

@synthesize pclInterfaceType;
@synthesize iOSTcpPclPort;
@synthesize terminalPclTcpPort;
@synthesize terminalIP;


+ (SettingsManager *)sharedSettingsManager {
    if (g_sharedSettingsManager == nil) {
        g_sharedSettingsManager = [[SettingsManager alloc] init];
    }
    return g_sharedSettingsManager;
}


- (id)init {
    if ((self = [super init])) {
        [self loadSettings];
    }
    return self;
}

- (oneway void)release {
    
}

- (void)loadSettings {
    DLog();
    
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
    self.pclInterfaceType       = [userDefaults integerForKey:INTERFACE_TYPE_KEY];
    self.iOSTcpPclPort          = [userDefaults integerForKey:IOS_TCP_PCL_PORT_KEY];
    self.terminalPclTcpPort     = [userDefaults integerForKey:TERMINAL_TCP_PCL_PORT_KEY];
    self.terminalIP             = [userDefaults stringForKey:TERMINAL_IP_KEY];
    
    //Check Defaults
    [self _checkDefaults];
}

- (void)_checkDefaults {
    DLog();
    
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

- (void)saveSettings {
    DLog();
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    //Save the user defaults
    [userDefaults setInteger:self.pclInterfaceType forKey:INTERFACE_TYPE_KEY];
    [userDefaults setInteger:self.iOSTcpPclPort forKey:IOS_TCP_PCL_PORT_KEY];
    [userDefaults setInteger:self.terminalPclTcpPort forKey:TERMINAL_TCP_PCL_PORT_KEY];
    [userDefaults setObject:self.terminalIP forKey:TERMINAL_IP_KEY];
    
    [userDefaults synchronize];
}


@end
