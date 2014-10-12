//
//  ConfigurationTest_034.m
//  iSMPTestSuite
//
//  Created by Stephane Rabiller on 07/06/13.
//  Copyright 2013 Ingenico. All rights reserved.
//
//

#import "ConfigurationTest_004.h"


@implementation ConfigurationTest_004
@synthesize fullSerialNumber;


-(void)viewDidLoad {
	[super viewDidLoad];
	
	[self addButtonWithTitle:@"Refresh" andAction:@selector(refresh)];
	fullSerialNumber	= [self addTextFieldWithTitle:@"Full Serial Number"];
	[fullSerialNumber setEnabled:NO];
}


+(NSString *)title {
	return @"iSMP full SN";
}


+(NSString *)subtitle {
	return @"Retrieve the iSMP full Serial Number";
}

+(NSString *)instructions {
	return @"Ensure that the device is ready and press the refresh button. The iSMP information should then be displayed.";
}

+(NSString *)category {
	return @"Device Configuration";
}


-(void)getFullSerialNumberHelper {
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	[self beginTimeMeasure];
	NSString* SerialNumber = [self.configurationChannel getFullSerialNumber];
	double totalTime = [self endTimeMeasure];
	self.fullSerialNumber.text	= [NSString stringWithString:SerialNumber];
    [self performSelectorOnMainThread:@selector(logMessage:) withObject:[NSString stringWithFormat:@"Total Time: %f", totalTime] waitUntilDone:NO];
	[pool release];
}


-(void)refresh {
	[self performSelectorInBackground:@selector(getFullSerialNumberHelper) withObject:nil];
}


@end
