//
//  BasicPPPTest.m
//  iSMPTestSuite
//
//  Created by Ingenico on 28/05/13.
//  Copyright (c) 2013 Ingenico. All rights reserved.
//

#import "BasicPPPTest.h"

@implementation BasicPPPTest


+(NSString *)prefixLetter {
	static NSString * prefixLetter = @"PPP";
	return prefixLetter;
}


-(void)viewDidLoad {
    [super viewDidLoad];
    
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    //Initialize the PPP Channel
    self.pppChannel = [ICPPP sharedChannel];
    self.pppChannel.delegate = self;
    
    [self displayDeviceState:[ICISMPDevice isAvailable]];
}


-(void)viewWillDisappear:(BOOL)animated {
    //Close the PPP Channel
    [self.pppChannel closeChannel];
    self.pppChannel.delegate = nil;
    self.pppChannel = nil;
    
    [super viewWillDisappear:animated];
}


-(void)viewDidUnload {
    [super viewDidUnload];
}



//#pragma mark NSStreamDelegate
//
//-(void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode {
//
//}
//
//#pragma mark -


#pragma mark ICDeviceDelegate

-(void)accessoryDidConnect:(ICISMPDevice *)sender {
	if (sender == self.pppChannel) {
		[self displayDeviceState:YES];
	}
}

-(void)accessoryDidDisconnect:(ICISMPDevice *)sender {
	if (sender == self.pppChannel) {
		[self displayDeviceState:NO];
	}
}

#pragma mark -


#pragma mark ICPPPDelegate

-(void)pppChannelDidOpen {
    NSLog(@"%s", __FUNCTION__);
    
    [self logMessage:@"PPP Started!!"];
}

-(void)pppChannelDidClose {
    NSLog(@"%s", __FUNCTION__);
    
    [self logMessage:@"PPP Disconnected!!"];
}

#pragma mark -

//Don't display serial traces
-(void)logSerialData:(NSData *)data incomming:(BOOL)isIncoming {
 
}
 
@end
