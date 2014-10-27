//
//  BasicSPPTest.m
//  iSMPTestSuite
//
//  Created by Hichem Boussetta on 24/05/12.
//  Copyright (c) 2012 Ingenico. All rights reserved.
//

#import "BasicSPPTest.h"
#import <iSMP/ICISMPDevice.h>

@implementation BasicSPPTest

@synthesize sppChannel;


+(NSString *)prefixLetter {
	static NSString * prefixLetter = @"SPP";
	return prefixLetter;
}


-(void)viewDidLoad {
    [super viewDidLoad];
    
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    //Initialize the SPP Channel
    self.sppChannel = [ICSPP sharedChannel];
    self.sppChannel.delegate = self;
    //self.sppChannel.streamDelegate = self;
    
    [self displayDeviceState:[self.sppChannel isAvailable]];
}


-(void)viewWillDisappear:(BOOL)animated {
    //Close the SPP Channel
    self.sppChannel.delegate = nil;
    self.sppChannel = nil;
    
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
	if (sender == self.sppChannel) {
		[self displayDeviceState:YES];
	}
}

-(void)accessoryDidDisconnect:(ICISMPDevice *)sender {
	if (sender == self.sppChannel) {
		[self displayDeviceState:NO];
	}
}

-(void)logSerialData:(NSData *)data incomming:(BOOL)isIncoming {
    //NSLog(@"%s [%@][Length: %d]\n\t%@", __FUNCTION__, ((isIncoming) ? @"iSMP -> iPhone" : @"iPhone -> iSMP"), [data length], [data hexDump]);
}

/** Reception */
-(void)willReceiveData:(ICISMPDevice *)Sender
{
	//NSLog(@"%@ will Receive data", Sender.protocolName);
}
/** Reception */
-(void)didReceiveData:(NSData *)Data fromICISMPDevice:(ICISMPDevice *)Sender
{
	//NSLog(@"%@ did Received data", Sender.protocolName);
    NSLog(@"%s [Length: %d]\n\t", __FUNCTION__, [Data length]);
}

/** Send */
-(void)willSendData:(ICISMPDevice *)Sender
{
	//NSLog(@"%@ will send data", Sender.protocolName);
}
-(void)didSendData:(NSData *)Data withNumberOfBytesSent:(unsigned int) NbBytesSent fromICISMPDevice:(ICISMPDevice *)Sender
{
	//NSLog(@"%@ did sent data", Sender.protocolName);
}

@end
