//
//  ConfigurationTest_014.m
//  iSMPTestSuite
//
//  Created by Hichem Boussetta on 27/01/11.
//  Copyright 2011 Ingenico. All rights reserved.
//

#import "ConfigurationTest_014.h"


@implementation ConfigurationTest_014


-(void)viewDidLoad {
	[super viewDidLoad];
	
	[self addButtonWithTitle:@"Start" andAction:@selector(test:)];
	loopTest = NO;
}

-(void)viewWillDisappear:(BOOL)animated {
	loopTest = NO;
	[[UIApplication sharedApplication] setIdleTimerDisabled:NO];
	[super viewWillDisappear:animated];
}


+(NSString *)title {
	return @"Open/Close Loop";
}


+(NSString *)subtitle {
	return @"configuration Channel Open/Close Loop";
}

+(NSString *)instructions {
	return @"Ensure the device is ready. Press the Start button to start the test, Stop to end it. If the test fails, a notification dialog is displayed.";
}

+(NSString *)category {
	return @"Stress";
}

-(void)testHelper:(id)sender {
	UIButton * button = (UIButton *)sender;
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	[[UIApplication sharedApplication] setIdleTimerDisabled:YES];
	long i = 0;
	while (loopTest == YES) {
		self.configurationChannel = nil;
		[pool drain];
		pool  = [[NSAutoreleasePool alloc] init];
		self.configurationChannel = [ICAdministration sharedChannel];
		self.configurationChannel.delegate = self;
        
        if ([self.configurationChannel respondsToSelector:@selector(open)]) {
            [self.configurationChannel open];
        }
        
		if (self.configurationChannel.isAvailable == NO) {
			[self performSelectorOnMainThread:@selector(clearAndLogMessage:) withObject:@"Failed to open channel" waitUntilDone:YES];
		} else {
            [self performSelectorOnMainThread:@selector(clearAndLogMessage:) withObject:[NSString stringWithFormat:@"Close/Open #%08ld", ++i] waitUntilDone:YES];
        }
	}
	[button setTitle:@"Start" forState:UIControlStateNormal];
	loopTest = NO;
	[pool release];
}

-(void)test:(id)sender {
	UIButton * button = (UIButton *)sender;
	if ([button.titleLabel.text isEqualToString:@"Start"]) {
		[button setTitle:@"Stop" forState:UIControlStateNormal];
		loopTest = YES;
		[self performSelectorInBackground:@selector(testHelper:) withObject:button];
	} else {
		[button setTitle:@"Start" forState:UIControlStateNormal];
		loopTest = NO;
	}
}


@end
