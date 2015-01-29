//
//  Transac_Test_005.m
//  iSMPTestSuite
//
//  Created by Hichem Boussetta on 06/05/11.
//  Copyright 2011 Ingenico. All rights reserved.
//

#import "Transac_Test_001.h"


@implementation Transac_Test_001
@synthesize transactionChannel;
@synthesize textMessage;
@synthesize buttonSubmit;

#define READ_BUFFER 4096

+(NSString *)title {
	return @"Write/Read";
}

+(NSString *)subtitle {
	return @"Write and Read data on the transaction channel";
}

+(NSString *)instructions {
	return @"Ensure that the device is ready. Type your text and submit to send it the iSMP. What you receive is displayed at the log box.";
}

+(NSString *)category {
	return @"Basic";
}


-(void)viewDidLoad {
	[super viewDidLoad];
	
	self.textMessage = [self addTextFieldWithTitle:@"Your Message"];
	self.buttonSubmit = [self addButtonWithTitle:@"Submit" andAction:@selector(submitMessage)];
	self.transactionChannel = [ICTransaction sharedChannel];
	self.transactionChannel.delegate = self;
	//[self.transactionChannel forwardStreamEvents:YES to:self];
	iPhone2iSPMData = [[NSMutableData alloc] init];
	
	if (self.transactionChannel.isAvailable) {
		[self displayDeviceState:YES];
	} else {
		[self displayDeviceState:NO];
	}

}


-(void)dealloc {
	[iPhone2iSPMData release];
	self.transactionChannel = nil;
	[super dealloc];
}

-(void)submitMessage {
	/*
	[iPhone2iSPMData appendBytes:[textMessage.text UTF8String] length:[textMessage.text lengthOfBytesUsingEncoding:NSUTF8StringEncoding]];
	[self.transactionChannel.outStream write:NULL maxLength:0];
	 */
	
	NSData * DataToSend = [[NSData dataWithBytes:[textMessage.text UTF8String] length:[textMessage.text lengthOfBytesUsingEncoding:NSUTF8StringEncoding]]retain];
	
	[transactionChannel SendDataAsync:DataToSend];
	[DataToSend release];
}


#pragma mark NSStreamDelegate

/** Reception */
-(void)didReceiveData:(NSData *)Data fromICISMPDevice:(ICISMPDevice *)Sender
{
	NSString * msg = [[NSString alloc] initWithBytes:Data.bytes	length:Data.length encoding:NSUTF8StringEncoding];
	[self performSelectorOnMainThread:@selector(logMessage:) withObject:[NSString stringWithFormat:@"Received: %@", msg] waitUntilDone:NO];
	[msg release];
}
//-(void)stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent {
//	int written = 0;
//	int read = 0;
//	uint8_t buffer[READ_BUFFER];
//	switch (streamEvent) {
//		case NSStreamEventHasBytesAvailable:
//			if (theStream == self.transactionChannel.inStream) {
//				read = [self.transactionChannel.inStream read:buffer maxLength:READ_BUFFER];
//				if (read > 0) {
//					NSString * msg = [[NSString alloc] initWithBytes:buffer length:read encoding:NSUTF8StringEncoding];
//					[self performSelectorOnMainThread:@selector(logMessage:) withObject:[NSString stringWithFormat:@"Received: %@", msg] waitUntilDone:NO];
//					[msg release];
//				}
//			}
//			break;
//		case NSStreamEventHasSpaceAvailable:
//			if (theStream == self.transactionChannel.outStream) {
//				if ([iPhone2iSPMData length] > 0) {
//					written = [transactionChannel.outStream write:(uint8_t *)[iPhone2iSPMData bytes] maxLength:[iPhone2iSPMData length]];
//					if (written > 0) {
//						[iPhone2iSPMData setData:[iPhone2iSPMData subdataWithRange:NSMakeRange(written, [iPhone2iSPMData length] - written)]];
//					}
//				}
//			}
//			break;
//
//		default:
//			break;
//	}
//}

#pragma mark -

#pragma mark ICDeviceDelegate

-(void)accessoryDidConnect:(ICISMPDevice *)sender {
	if (sender == self.transactionChannel) {
		[self displayDeviceState:YES];
	}
}

-(void)accessoryDidDisconnect:(ICISMPDevice *)sender {
	if (sender == self.transactionChannel) {
		[self displayDeviceState:NO];
	}
}

#pragma mark -

@end
