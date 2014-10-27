//
//  ConfigurationTest_015.m
//  iSMPTestSuite
//
//  Created by Hichem Boussetta on 27/01/11.
//  Copyright 2011 Ingenico. All rights reserved.
//

#import "ConfigurationTest_015.h"

#define MESSAGE_LENGTH 1024

@implementation ConfigurationTest_015


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


+(NSString *)title {
	return @"Close/Open/Send Msg Loop";
}


+(NSString *)subtitle {
	return @"Close, Open, Send 1KB Message Loop";
}

+(NSString *)instructions {
	return @"Ensure the device is ready. Press the Start button to start the test, Stop to end it. If the test fails, a notification dialog is displayed.";
}

+(NSString *)category {
	return @"Stress";
}

-(void)test:(id)sender {
	UIButton * button = (UIButton *)sender;
	if ([button.titleLabel.text isEqualToString:@"Start"]) {
		[button setTitle:@"Stop" forState:UIControlStateNormal];
		loopTest = YES;
		[self performSelectorInBackground:@selector(testHelper) withObject:nil];
	} else {
		loopTest = NO;
		[button setTitle:@"Start" forState:UIControlStateNormal];
	}

}

-(void)testHelper {
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	long i = 0;
	BOOL ret = YES;
	char buf[MESSAGE_LENGTH];
	
	[[UIApplication sharedApplication] setIdleTimerDisabled:YES];
	
	NSData * data = [[NSData alloc] initWithBytes:buf length:MESSAGE_LENGTH];
	while (loopTest == YES) {
        [self.configurationChannel open];
        if (self.configurationChannel.isAvailable) {
            ret = [self.configurationChannel sendMessage:data];
            [self.configurationChannel close];
            if (ret == YES) {
                [self performSelectorOnMainThread:@selector(clearAndLogMessage:) withObject:[NSString stringWithFormat:@"Open/Send/Close Msg #%08ld succeeded", ++i] waitUntilDone:YES];
            } else {
                [self performSelectorOnMainThread:@selector(clearAndLogMessage:) withObject:[NSString stringWithFormat:@"Open/Send/Close Msg #%08ld failed", ++i] waitUntilDone:YES];
                break;
            }
        } else {
            [self performSelectorOnMainThread:@selector(clearAndLogMessage:) withObject:@"Failed to open Administration channel" waitUntilDone:YES];
            break;
        }
		
	}
	[data release];
	[pool release];
}


@end
