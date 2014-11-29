//
//  ConfigurationTest_016.m
//  iSMPTestSuite
//
//  Created by Hichem Boussetta on 30/03/11.
//  Copyright 2011 Ingenico. All rights reserved.
//

#import "ConfigurationTest_016.h"


@implementation ConfigurationTest_016


+(NSString *)title {
	return @"Get State Loop";
}


+(NSString *)subtitle {
	return @"Loop sending Get State commands";
}

+(NSString *)instructions {
	return @"Ensure the device is ready. Press the Start button to start the test, Stop to end it. If the test fails, a notification dialog is displayed.";
}

+(NSString *)category {
	return @"Stress";
}


-(void)viewDidLoad {
	[super viewDidLoad];
	
	loopTest = NO;
	[self addButtonWithTitle:@"Start" andAction:@selector(test:)];
}

-(void)viewWillDisappear:(BOOL)animated {
	loopTest = NO;
	[[UIApplication sharedApplication] setIdleTimerDisabled:NO];
	[super viewWillDisappear:animated];
}


-(void)testHelper {
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	[[UIApplication sharedApplication] setIdleTimerDisabled:YES];
	while (loopTest == YES) {
		[self.configurationChannel isIdle];
	}
	[[UIApplication sharedApplication] setIdleTimerDisabled:NO];
	[pool release];
}


-(void)test:(id)sender {
	UIButton * button = (UIButton *)sender;
	if ([button.titleLabel.text isEqualToString:@"Start"]) {
		[button setTitle:@"Stop" forState:UIControlStateNormal];
		loopTest = YES;
		[self performSelectorInBackground:@selector(testHelper) withObject:nil];
	} else {
		[button setTitle:@"Start" forState:UIControlStateNormal];
		loopTest = NO;
	}
}

@end
