//
//  ConfigurationTest_006.m
//  iSMPTestSuite
//
//  Created by Hichem Boussetta on 10/01/11.
//  Copyright 2011 Ingenico. All rights reserved.
//

#import "ConfigurationTest_006.h"


@implementation ConfigurationTest_006


-(void)viewDidLoad {
	[super viewDidLoad];
	
	iSpmDate = [self addTextFieldWithTitle:@"iSMP Time"];
	UIButton * button = [self addButtonWithTitle:@"" andAction:nil];
	[button setHidden:YES];
	buttonSetTime = [self addButtonWithTitle:@"Update the iSMP Time" andAction:@selector(setTime)];
	buttonGetTime = [self addButtonWithTitle:@"Retrieve the iSMP Time" andAction:@selector(getTime)];
}


+(NSString *)title {
	return @"Date & Time";
}


+(NSString *)subtitle {
	return @"Update & Retrieve the iSMP Date and Time";
}

+(NSString *)instructions {
	return @"Ensure that the device is ready, then update and retrieve the iSMP time using the provided buttons.";
}

+(NSString *)category {
	return @"Device Configuration";
}

-(void)setTime {
	[buttonSetTime setEnabled:NO];
	[self performSelectorInBackground:@selector(setDateAndTimeHelper) withObject:nil];
}

-(void)getTime {
	[buttonGetTime setEnabled:NO];
	[self performSelectorInBackground:@selector(getTimeHelper) withObject:nil];
}

-(void)setDateAndTimeHelper {
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	[self beginTimeMeasure];
	BOOL ret = [self.configurationChannel setDate];
	double totalTime = [self endTimeMeasure];
	[buttonSetTime setEnabled:YES];
	NSString * msg = @"iSMP Date & Time Updated";
	if (ret == NO) {
		msg = @"iSMP Date & Time Not Updated";
	}
	[self performSelectorOnMainThread:@selector(logMessage:) withObject:[NSString stringWithFormat:@"Total Time: %f\n%@", totalTime, msg] waitUntilDone:NO];
	[pool release];
}

-(void)getTimeHelper {
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	[self beginTimeMeasure];
	NSDate * date = [self.configurationChannel getDate];
	double totalTime = [self endTimeMeasure];
	[buttonGetTime setEnabled:YES];
	NSString * msg = nil;
	if (date != nil) {
		iSpmDate.text = [NSDateFormatter localizedStringFromDate:date dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterShortStyle];
		msg = @"iSMP time retrieved";
	} else {
		iSpmDate.text = @"N/A";
		msg = @"Failed to retrieve the iSMP time";
	}
	[self performSelectorOnMainThread:@selector(logMessage:) withObject:[NSString stringWithFormat:@"%@\nTotal Time: %f", msg, totalTime] waitUntilDone:NO];
	[pool release];
}

@end
