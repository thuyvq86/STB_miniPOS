//
//  GateWayManager.m
//  InteractivePayment
//
//  Created by Hichem Boussetta on 07/12/11.
//  Copyright (c) 2011 Theoris. All rights reserved.
//

#import "GateWayManager.h"

@interface GateWayManager ()

@property (nonatomic, retain) ICNetwork * network;

//Callbacks triggered when becomeActive and ResignActive notification are received - This class listens for these in order to determine whether it should or shouldn't close the communication channel
-(void)appActive;
-(void)appResignActive;

@end


static GateWayManager * g_sharedGateWayManager = nil;

@implementation GateWayManager

@synthesize network;


+(GateWayManager *)sharedGateWayManager {
    if (g_sharedGateWayManager == nil) {
        g_sharedGateWayManager = [[GateWayManager alloc] init];
    }
    return g_sharedGateWayManager;
}

-(id)init {
    if ((self = [super init])) {
        self.network = [ICNetwork sharedChannel];
        self.network.delegate = self;
        
        // Subscribe for appActive notification
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appActive) name:UIApplicationDidBecomeActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appResignActive) name:UIApplicationWillResignActiveNotification object:nil];
    }
    return self;
}


-(oneway void)release {
    
}


#pragma mark Open/Close the communication channel when entering/leaving sleep mode

//Start the Gateway
-(void)start {
    NSLog(@"%s", __FUNCTION__);
    self.network = [ICNetwork sharedChannel];
    self.network.delegate = self;
}

//Stop the gateway
-(void)stop {
    NSLog(@"%s", __FUNCTION__);
    
    self.network = nil;
}

//Callback triggered when the application becomes active
-(void)appActive {
    NSLog(@"%s", __FUNCTION__);
    [self start];   //Start the gateway
}

//Callback triggered when the application resigns from active state
-(void)appResignActive {
    NSLog(@"%s", __FUNCTION__);
    
    //Check the cradle mode global parameter and decide whether to close the channel or not
    if ([[SettingsManager sharedSettingsManager] cradleMode] == NO) {
        [self stop];    
    } else {
        NSLog(@"%s Cradle Mode Enabled", __FUNCTION__);
    }
}

#pragma mark -


#pragma mark ICISMPDeviceDelegate

-(void)logEntry:(NSString *)message withSeverity:(int)severity {
    NSLog(@"[%@][%@]", [ICISMPDevice severityLevelString:severity], message);
}

#pragma mark -


#pragma mark ICNetworkDelegate

-(void)networkData:(NSData *)data incoming:(BOOL)isIncoming {
    NSLog(@"%s [%@][Length: %lu] %@", __FUNCTION__, ((isIncoming ? @"Network->iPhone" : @"iPhone->Network")), (unsigned long)[data length], [data hexDump]);
}

-(void)networkWillConnectToHost:(NSString *)host onPort:(NSUInteger)port {
    NSLog(@"%s [Host: %@, Port: %lu]", __FUNCTION__, host, (unsigned long)port);
}

-(void)networkDidConnectToHost:(NSString *)host onPort:(NSUInteger)port {
    NSLog(@"%s [Host: %@, Port: %lu]", __FUNCTION__, host, (unsigned long)port);
}

-(void)networkFailedToConnectToHost:(NSString *)host onPort:(NSUInteger)port {
    NSLog(@"%s [Host: %@, Port: %lu]", __FUNCTION__, host, (unsigned long)port);
}

-(void)networkDidDisconnectFromHost:(NSString *)host onPort:(NSUInteger)port {
    NSLog(@"%s [Host: %@, Port: %lu]", __FUNCTION__, host, (unsigned long)port);
}

-(void)networkDidReceiveErrorWithHost:(NSString *)host andPort:(NSUInteger)port {
    NSLog(@"%s [Host: %@, Port: %lu]", __FUNCTION__, host, (unsigned long)port);
}

#pragma mark -


@end
