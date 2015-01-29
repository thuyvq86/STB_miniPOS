//
//  ConfigurationTest_003.m
//  iSMPTestSuite
//
//  Created by Hichem Boussetta on 10/01/11.
//  Copyright 2011 Ingenico. All rights reserved.
//

#import "ConfigurationTest_003.h"


@implementation ConfigurationTest_003
@synthesize serialNumber, reference, protocol;


-(void)viewDidLoad {
	[super viewDidLoad];
	
	[self addButtonWithTitle:@"Refresh" andAction:@selector(refresh)];
	serialNumber	= [self addTextFieldWithTitle:@"Serial Number"];
	reference		= [self addTextFieldWithTitle:@"Product Reference"];
	protocol		= [self addTextFieldWithTitle:@"Payment Protocol"];
	[serialNumber setEnabled:NO];
	[reference setEnabled:NO];
	[protocol setEnabled:NO];
}


+(NSString *)title {
	return @"iSMP information";
}


+(NSString *)subtitle {
	return @"Retrieve the iSMP product information";
}

+(NSString *)instructions {
	return @"Ensure that the device is ready and press the refresh button. The iSMP information should then be displayed.";
}

+(NSString *)category {
	return @"Device Configuration";
}


-(void)getInformationHelper {
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	[self beginTimeMeasure];
	ICDeviceInformation deviceInformation = [self.configurationChannel getInformation];
	double totalTime = [self endTimeMeasure];
	serialNumber.text	= [NSString stringWithFormat:@"%lx", (long)deviceInformation.serialNumber];
	reference.text		= [NSString stringWithFormat:@"%lx", (long)deviceInformation.reference];
	protocol.text		= [[[NSString alloc] initWithBytes:deviceInformation.protocol length:strlen(deviceInformation.protocol) encoding:NSUTF8StringEncoding] autorelease];
	[self performSelectorOnMainThread:@selector(logMessage:) withObject:[NSString stringWithFormat:@"Total Time: %f", totalTime] waitUntilDone:NO];
	[pool release];
}


-(void)refresh {
	[self performSelectorInBackground:@selector(getInformationHelper) withObject:nil];
}


@end
