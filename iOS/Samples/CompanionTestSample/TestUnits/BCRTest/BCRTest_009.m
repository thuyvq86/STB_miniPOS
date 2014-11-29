//
//  BCRTest_009.m
//  iSMPTestSuite
//
//  Created by Hichem Boussetta on 16/06/11.
//  Copyright 2011 Ingenico. All rights reserved.
//

#import "BCRTest_009.h"


@implementation BCRTest_009


+(NSString *)title {
	return @"Enable/Disable Turbo Mode";
}

+(NSString *)subtitle {
	return @"Enable/Disable the scanner's turbo mode";
}

+(NSString *)instructions {
	return @"Ensure the device is ready. Push the switch button On/Off to enable/disable the scanner's turbo mode. Check the request result in the log box at the bottom of the view.";
}

+(NSString *)category {
	return @"Unit Tests";
}


-(void)viewDidLoad {
	[super viewDidLoad];
	turboModeSwitch = [self addSwitchWithTitle:@"Enable Turbo Mode"];
    [turboModeSwitch addTarget:self action:@selector(enableTurboMode) forControlEvents:UIControlEventValueChanged];
}


-(void)enableTurboModeHelper {
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	[self beginTimeMeasure];
    BOOL retValue = [self.barcodeReader enableTurboMode:turboModeSwitch.on];
    double totalTime = [self endTimeMeasure];
    NSString * msg = nil;
    if (retValue == YES) {
        if (turboModeSwitch.on == YES) {
            msg = @"Turbo Mode Enabled";
        } else {
            msg = @"Turbo Mode Disabled";
        }
    } else {
        if (turboModeSwitch.on == YES) {
            msg = @"Failed to enable turbo mode";
        } else {
            msg = @"Failed to disable turbo mode";
        }
        turboModeSwitch.on = ! turboModeSwitch.on;
    }
    [self performSelectorOnMainThread:@selector(clearAndLogMessage:) withObject:[NSString stringWithFormat:@"%@\nTotal Time: %f", msg, totalTime] waitUntilDone:YES];
    [turboModeSwitch setEnabled:YES];
	[pool release];
}

-(void)enableTrigger {
	[turboModeSwitch setEnabled:NO];
    [self performSelectorInBackground:@selector(enableTurboModeHelper) withObject:nil];
}


@end
