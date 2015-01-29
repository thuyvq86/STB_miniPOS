//
//  ConfigurationTest_005.m
//  iSMPTestSuite
//
//  Created by Hichem Boussetta on 10/01/11.
//  Copyright 2011 Ingenico. All rights reserved.
//

#import "ConfigurationTest_022.h"


@implementation ConfigurationTest_022
@synthesize spmState;


-(void)viewDidLoad {
	[super viewDidLoad];
	
	[self addButtonWithTitle:@"Refresh" andAction:@selector(refresh)];
	spmState = [self addTextFieldWithTitle:@"The iSMP is "];
	[spmState setEnabled:NO];
	[self refresh];
	//[self.configurationChannel isIdle];
}


+(NSString *)title {
	return @"iSMP State";
}


+(NSString *)subtitle {
	return @"Get the iSMP state";
}

+(NSString *)instructions {
	return @"Ensure that the device is ready and press the refresh button. The iSMP can be either idle or busy.";
}

+(NSString *)category {
	return @"Device Configuration";
}


-(void)refresh {
	[self performSelectorInBackground:@selector(backgroundGetState) withObject:nil];
}

-(void)backgroundGetState {
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	[self beginTimeMeasure];
	BOOL idle = [self.configurationChannel isIdle];
	double totalTime = [self endTimeMeasure];
	NSString * msg = @"Idle";
	if (idle == NO) {
		msg = @"Busy";
	}
	self.spmState.text = msg;
	[self performSelectorOnMainThread:@selector(logMessage:) withObject:[NSString stringWithFormat:@"Total Time: %f", totalTime] waitUntilDone:NO];
	[pool release];
}


@end
