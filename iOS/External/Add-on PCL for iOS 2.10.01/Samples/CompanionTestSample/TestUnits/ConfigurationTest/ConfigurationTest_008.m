//
//  ConfigurationTest_008.m
//  iSMPTestSuite
//
//  Created by Hichem Boussetta on 10/01/11.
//  Copyright 2011 Ingenico. All rights reserved.
//

#import "ConfigurationTest_008.h"


@implementation ConfigurationTest_008


-(void)viewDidLoad {
	[super viewDidLoad];
	
	switchMode = [self addSwitchWithTitle:@"ASCII[0] / Zero Buffer[1]"];
	message = [self addTextFieldWithTitle:@"Text / Size"];
	buttonSend = [self addButtonWithTitle:@"Send" andAction:@selector(send)];
}


+(NSString *)title {
	return @"Undercover Messaging";
}


+(NSString *)subtitle {
	return @"Send or receive a user message to/from the iSMP";
}

+(NSString *)instructions {
	return @"Ensure that the device is ready. Choose whether to send ascii text or a zero-bytes buffer, type the message or the size of the buffer and validate.";
}

+(NSString *)category {
	return @"Miscellaneous";
}


-(void)sendAsciiHelper {
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	[self beginTimeMeasure];
	BOOL retValue = [self.configurationChannel sendMessage:[NSData dataWithBytes:[message.text UTF8String] length:[message.text length]]];
	double totalTime = [self endTimeMeasure];
	NSString * msg = @"Message delivered";
	if (retValue == NO) {
		msg = @"Message rejected";
	}
	[self performSelectorOnMainThread:@selector(logMessage:) withObject:[NSString stringWithFormat:@"%@\nTotal Time: %f", msg, totalTime] waitUntilDone:NO];
	[buttonSend setEnabled:YES];
	[pool release];
}

-(void)sendDataHelper {
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	[self beginTimeMeasure];
	char * buffer = (char *)malloc([message.text intValue]);
    memset(buffer, 0x2A, [message.text intValue]);
	NSData * data = [NSData dataWithBytesNoCopy:buffer length:[message.text intValue]];
	BOOL retValue = [self.configurationChannel sendMessage:data];
	double totalTime = [self endTimeMeasure];
	NSString * msg = @"Data delivered";
	if (retValue == NO) {
		msg = @"Data rejected";
	}
	[self performSelectorOnMainThread:@selector(logMessage:) withObject:[NSString stringWithFormat:@"%@\nTotal Time: %f", msg, totalTime] waitUntilDone:NO];
	[buttonSend setEnabled:YES];
	[pool release];
}

-(void)send {
	[buttonSend setEnabled:NO];
	if (switchMode.on) {
		[self performSelectorInBackground:@selector(sendDataHelper) withObject:nil];
	} else {
		[self performSelectorInBackground:@selector(sendAsciiHelper) withObject:nil];
	}
}

-(void)messageReceivedWithData:(NSData *)data {
	NSString * msg = [[NSString alloc] initWithBytes:[data bytes] length:[data length] encoding:NSUTF8StringEncoding];
	[self logMessage:@"Just received a message from the iSMP"];
	[self logMessage:[NSString stringWithFormat:@"Content: %@", msg]];
	[msg release];
    
    //[self send];
    [self performSelector:@selector(send) withObject:nil afterDelay:0];
}


@end
