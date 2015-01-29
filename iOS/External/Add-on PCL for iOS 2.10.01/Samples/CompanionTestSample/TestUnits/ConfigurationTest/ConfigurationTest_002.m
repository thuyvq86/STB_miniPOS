//
//  ConfigurationTest_002.m
//  iSMPTestSuite
//
//  Created by Hichem Boussetta on 29/12/10.
//  Copyright 2010 Ingenico. All rights reserved.
//

#import "ConfigurationTest_002.h"


@implementation ConfigurationTest_002

@synthesize network;

-(void)viewDidLoad {
	[super viewDidLoad];
	
	buttonUpdate = [self addButtonWithTitle:@"Update" andAction:@selector(update)];
    
    self.network = [ICNetwork sharedChannel];
    self.network.delegate = self;
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    self.network = nil;
}

+(NSString *)title {
	return @"Remote Update using old solution";
}


+(NSString *)subtitle {
	return @"Remote update the device";
}

+(NSString *)instructions {
	return @"Touch down the Update button and make sure the iSMP approves the request and reboots to start the remote update process";
}

+(NSString *)category {
	return @"Device Update";
}

-(void)updateHelper {
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	[self beginTimeMeasure];
	BOOL retValue = [self.configurationChannel startRemoteDownload];
	double totalTime = [self endTimeMeasure];
	NSString * msg = @"Update Request Approved";
	if (retValue == NO) {
		msg = @"Update Request Failed";
	}
	[self performSelectorOnMainThread:@selector(logMessage:) withObject:[NSString stringWithFormat:@"%@\nTotal Time: %f", msg, totalTime] waitUntilDone:NO];
	[buttonUpdate setEnabled:YES];
	[pool release];
}

-(void)update {
	[buttonUpdate setEnabled:NO];
	[self performSelectorInBackground:@selector(updateHelper) withObject:nil];
}


#pragma mark ICNetworkDelegate

-(void)networkData:(NSData *)data incoming:(BOOL)isIncoming {
	NSString * log = [NSString stringWithFormat:@"[Data: %@, Length: %lu]\r\n\t", (isIncoming==YES?@"Network -> iPhone":@"iPhone -> Network"), (unsigned long)[data length]];
    
    [self performSelectorOnMainThread:@selector(logMessage:) withObject:[NSString stringWithFormat:@"[Data: %@, Length: %lu]", (isIncoming==YES?@"Network -> iPhone":@"iPhone -> Network"), (unsigned long)[data length]] waitUntilDone:NO];
    
    NSLog(@"%@", log);
}

-(void)networkWillConnectToHost:(NSString *)host onPort:(NSUInteger)port {
    [self performSelectorOnMainThread:@selector(logMessage:) withObject:[NSString stringWithFormat:@"Trying to connect to %@:%lu", host, (unsigned long)port] waitUntilDone:NO];
}

-(void)networkDidConnectToHost:(NSString *)host onPort:(NSUInteger)port {
    [self performSelectorOnMainThread:@selector(logMessage:) withObject:[NSString stringWithFormat:@"Connected to %@:%lu", host, (unsigned long)port] waitUntilDone:NO];
}

-(void)networkFailedToConnectToHost:(NSString *)host onPort:(NSUInteger)port {
    [self performSelectorOnMainThread:@selector(logMessage:) withObject:[NSString stringWithFormat:@"Failed to connect to %@:%lu", host, (unsigned long)port] waitUntilDone:NO];
}

-(void)networkDidDisconnectFromHost:(NSString *)host onPort:(NSUInteger)port {
    [self performSelectorOnMainThread:@selector(logMessage:) withObject:[NSString stringWithFormat:@"Disconnected from %@:%lu", host, (unsigned long)port] waitUntilDone:NO];
}

-(void)networkDidReceiveErrorWithHost:(NSString *)host andPort:(NSUInteger)port {
    [self performSelectorOnMainThread:@selector(logMessage:) withObject:[NSString stringWithFormat:@"Received Error for %@:%lu", host, (unsigned long)port] waitUntilDone:NO];
}

#pragma mark -


@end
