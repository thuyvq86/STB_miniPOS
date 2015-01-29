//
//  SPPTest_001.m
//  iSMPTestSuite
//
//  Created by Hichem Boussetta on 24/05/12.
//  Copyright (c) 2012 Ingenico. All rights reserved.
//

#import "SPPTest_001.h"

@implementation SPPTest_001

@synthesize textMessage;
@synthesize buttonSubmit;
@synthesize iPhone2iSPMData;

#define RX_BUFFER 4096

+(NSString *)title {
	return @"Write/Read";
}

+(NSString *)subtitle {
	return @"Write and Read data on the SPP channel";
}

+(NSString *)instructions {
	return @"Ensure that the device is ready. Type your text and submit to send it the iSMP. What you receive is displayed at the log box.";
}

+(NSString *)category {
	return @"Basic";
}


-(void)viewDidLoad {
    [super viewDidLoad];
    
    self.textMessage        = [self addTextFieldWithTitle:@"Your Message"];
    self.buttonSubmit       = [self addButtonWithTitle:@"Submit" andAction:@selector(submitMessage)];
    self.iPhone2iSPMData    = [NSMutableData data];
}


-(void)dealloc {
    self.iPhone2iSPMData = nil;
    
    [super dealloc];
}

-(void)submitMessage {
    NSLog(@"%s", __FUNCTION__);
    
    //Check if SPP channel is available first
    if (self.textMessage.text.length == 0) {
        NSLog(@"%s Empty Text Field", __FUNCTION__);
        [self logMessage:@"Text Field is Empty"];
    } else if (self.sppChannel.isAvailable == NO) {
        NSLog(@"%s Failed to sent data: %@ is unavailable", __FUNCTION__, self.sppChannel.protocolName);
        [self logMessage:@"Failed to send message: SPP Channel not available"];
    } else {
		
		NSData * DataToSend = [NSData dataWithBytes:[textMessage.text UTF8String] length:textMessage.text.length];
		[self.sppChannel SendDataAsync:DataToSend];
		/*
        [self.iPhone2iSPMData appendBytes:[textMessage.text UTF8String] length:[self.textMessage.text lengthOfBytesUsingEncoding:NSUTF8StringEncoding]];
        [self stream:self.sppChannel.outStream handleEvent:NSStreamEventHasSpaceAvailable];
		 */
    }
}

#pragma mark 
/** Reception */
/*
-(void)willReceiveData:(ICISMPDevice *)Sender
{
	NSLog(@"%@ will Receive data", Sender.protocolName);
}
*/
/** Reception */

-(void)didReceiveData:(NSData *)Data fromICISMPDevice:(ICISMPDevice *)Sender
{
	NSLog(@"%@ did Received data", Sender.protocolName);
	
	NSString * msg = [[NSString alloc] initWithBytes:Data.bytes length:Data.length encoding:NSUTF8StringEncoding];
	[self performSelectorOnMainThread:@selector(logMessage:) withObject:[NSString stringWithFormat:@"Received: %@", msg] waitUntilDone:NO];
	[msg release];
}


/** Send */

/*
-(void)willSendData:(ICISMPDevice *)Sender
{
	NSLog(@"%@ will send data", Sender.protocolName);
}
-(void)didSendData:(NSData *)Data withNumberOfBytesSent:(unsigned int) NbBytesSent fromICISMPDevice:(ICISMPDevice *)Sender
{
	NSLog(@"%@ did sent data", Sender.protocolName);
}
*/

#pragma mark NSStreamDelegate


#pragma mark -


@end
