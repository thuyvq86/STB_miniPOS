//
//  BCRTest_008.m
//  iSMPTestSuite
//
//  Created by Hichem Boussetta on 16/06/11.
//  Copyright 2011 Ingenico. All rights reserved.
//

#import "BCRTest_008.h"


@implementation BCRTest_008


+(NSString *)title {
	return @"Enable/Disable Trigger";
}

+(NSString *)subtitle {
	return @"Enable/Disable the scanner's trigger";
}

+(NSString *)instructions {
	return @"Ensure the device is ready. Push the switch button On/Off to change the scanner's trigger state. Push the trigger button on the scanner and ensure the LED's is turned On/Off accordingly.";
}

+(NSString *)category {
	return @"Unit Tests";
}


-(void)viewDidLoad {
	[super viewDidLoad];
	triggerSwitch = [self addSwitchWithTitle:@"Enable Trigger"];
    [triggerSwitch addTarget:self action:@selector(enableTrigger) forControlEvents:UIControlEventValueChanged];
}


-(void)enableTriggerHelper {
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	[self beginTimeMeasure];
    BOOL retValue = [self.barcodeReader enableTrigger:triggerSwitch.on];
    double totalTime = [self endTimeMeasure];
    NSString * msg = nil;
    if (retValue == YES) {
        if (triggerSwitch.on == YES) {
            msg = @"Trigger Enabled";
        } else {
            msg = @"Trigger Disabled";
        }
    } else {
        if (triggerSwitch.on == YES) {
            msg = @"Failed to enable trigger";
        } else {
            msg = @"Failed to disable trigger";
        }
        triggerSwitch.on = ! triggerSwitch.on;
    }
    [self performSelectorOnMainThread:@selector(clearAndLogMessage:) withObject:[NSString stringWithFormat:@"%@\nTotal Time: %f", msg, totalTime] waitUntilDone:YES];
    [triggerSwitch setEnabled:YES];
	[pool release];
}

-(void)enableTrigger {
	[triggerSwitch setEnabled:NO];
    [self performSelectorInBackground:@selector(enableTriggerHelper) withObject:nil];
}

#pragma mark ICBarCodeReaderDelegate

-(void)configurationRequest {
    
}

-(void)barcodeData:(id)data ofType:(int)type {
    
}

#pragma -


@end
