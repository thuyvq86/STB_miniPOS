//
//  BCRTest_013.m
//  iSMPTestSuite
//
//  Created by Hichem Boussetta on 05/08/11.
//  Copyright 2011 Ingenico. All rights reserved.
//

#import "BCRTest_003.h"


@implementation BCRTest_003


+(NSString *)title {
	return @"Open/Close Channel";
}

+(NSString *)subtitle {
	return @"Open/Config/Close Channel Loop";
}

+(NSString *)instructions {
	return @"Press the Start button to start an open/config/close the barcode channel. Press the Stop button to end the test.";
}

+(NSString *)category {
	return @"Stress";
}


-(void)viewDidLoad {
	[super viewDidLoad];
	startTest = NO;
	[self addButtonWithTitle:@"Start" andAction:@selector(test:)];
}

-(void)viewWillDisappear:(BOOL)animated {
	startTest = NO;
	[[UIApplication sharedApplication] setIdleTimerDisabled:NO];
	[super viewWillDisappear:animated];
}

-(void)testHelper {
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	[[UIApplication sharedApplication] setIdleTimerDisabled:YES];
	unsigned int count_ok = 0;
    unsigned int count_ko = 0;
	while (startTest) {
		[self.barcodeReader powerOn];
        if (self.barcodeReader.isAvailable)
        {
            count_ok++;
            [self.barcodeReader enableTrigger:YES];
            [NSThread sleepForTimeInterval:1.0];
            [self.barcodeReader powerOff];
        }
        else
        {
            count_ko++;
            [NSThread sleepForTimeInterval:1.0];
        }
        
        
		[self performSelectorOnMainThread:@selector(clearAndLogMessage:) withObject:[NSString stringWithFormat:@"Open/Config/Close\r\n- OK = %08d\r\n- KO = %08d\r\n", count_ok, count_ko] waitUntilDone:YES];
	}
	[[UIApplication sharedApplication] setIdleTimerDisabled:NO];
	[pool release];
}

-(void)test:(id)sender {
	UIButton * button = (UIButton *)sender;
	if ([button.titleLabel.text isEqualToString:@"Start"]) {
		[button setTitle:@"Stop" forState:UIControlStateNormal];
		startTest = YES;
        //Reboot the terminal
        [self performSelector:@selector(resetTerminal) withObject:nil afterDelay:(3 + random() % 3)];
		[self performSelectorInBackground:@selector(testHelper) withObject:nil];
	} else {
		startTest = NO;
		[button setTitle:@"Start" forState:UIControlStateNormal];
	}
}


#pragma mark ICBarCodeReaderDelegate

-(void)configurationRequest {
    
}

#pragma -




@end
