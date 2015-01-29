//
//  ConfigurationTest_018.m
//  iSMPTestSuite
//
//  Created by Hichem Boussetta on 06/04/11.
//  Copyright 2011 Ingenico. All rights reserved.
//

#import "ConfigurationTest_018.h"


@implementation ConfigurationTest_018
@synthesize serverState;


+(NSString *)title {
	return @"Server Connection State";
}


+(NSString *)subtitle {
	return @"Provide iSMP with Server Connection State";
}

+(NSString *)instructions {
	return @"Ensure the device is ready. Alter the server state switch to make the iSMP know whether the iPhone is connected to a remote host or not";
}

+(NSString *)category {
	return @"Device Configuration";
}


-(void)viewDidLoad {
	[super viewDidLoad];
	
	serverState = [self addSwitchWithTitle:@"Server Connection State"];
	[serverState addTarget:self action:@selector(valueChanged) forControlEvents:UIControlEventValueChanged];
}

-(void)updateConnectionStateHelper {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    [self beginTimeMeasure];
    BOOL retValue = [self.configurationChannel setServerConnectionState:serverState.on];
    float totalTime = [self endTimeMeasure];
    NSString * msg = nil;
    if (retValue == YES) {
        msg = @"Server State Updated";
    } else {
        msg = @"Server State Update Failed";
    }
    [self performSelectorOnMainThread:@selector(logMessage:) withObject:[NSString stringWithFormat:@"%@\nTotal Time: %f", msg, totalTime] waitUntilDone:NO];
    [serverState setEnabled:YES];
    [pool release];
}

-(void)valueChanged {
	[serverState setEnabled:NO];
    [self performSelectorInBackground:@selector(updateConnectionStateHelper) withObject:nil];
}

#pragma mark ICDeviceDelegate

-(void)updateServerConnectionState {
    [self valueChanged];
}

-(void)accessoryDidConnect:(ICISMPDevice *)sender {
    if (sender == self.configurationChannel) {
        [self updateServerConnectionState];
    }
    [super accessoryDidConnect:sender];
}

-(void)accessoryDidDisconnect:(ICISMPDevice *)sender {
    if (sender == self.configurationChannel) {
        [self.configurationChannel setServerConnectionState:NO];
    }
    [super accessoryDidDisconnect:sender];
}

#pragma mark -


@end
