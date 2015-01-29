//
//  ConfigurationTest_027.m
//  iSMPTestSuite
//
//  Created by Stephane RABILLER on 30/12/13.
//  Copyright 2013 Ingenico. All rights reserved.
//

#import "ConfigurationTest_027.h"


@implementation ConfigurationTest_027
@synthesize spmciVersion;

+(NSString *)title {
	return @"SPMCI Version";
}


+(NSString *)subtitle {
	return @"Retrieve the SPMCI component version";
}

+(NSString *)instructions {
	return @"Ensure the device is ready and press the Get SPMCI Version button. The running software components and their CRCs should appear below";
}

+(NSString *)category {
	return @"Device Configuration";
}


-(void)viewDidLoad {
	[super viewDidLoad];
	
	[self addButtonWithTitle:@"Get SPMCI version" andAction:@selector(refresh)];
	spmciVersion	= [self addTextFieldWithTitle:@"SPMCI version"];
	[spmciVersion setEnabled:NO];
}


-(void)getSpmciVersionHelper {
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	[self beginTimeMeasure];
	NSString* SpmciVersion = [self.configurationChannel getSpmciVersion];
	double totalTime = [self endTimeMeasure];
	self.spmciVersion.text	= [NSString stringWithString:SpmciVersion];
    [self performSelectorOnMainThread:@selector(logMessage:) withObject:[NSString stringWithFormat:@"Total Time: %f", totalTime] waitUntilDone:NO];
	[pool release];
}


-(void)refresh {
	[self performSelectorInBackground:@selector(getSpmciVersionHelper) withObject:nil];
}

@end
