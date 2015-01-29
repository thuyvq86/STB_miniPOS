//
//  BCRTest_007.m
//  iSMPTestSuite
//
//  Created by Hichem Boussetta on 28/03/11.
//  Copyright 2011 Ingenico. All rights reserved.
//

#import "BCRTest_006.h"


@implementation BCRTest_006

+(NSString *)title {
	return @"Power On/Off";
}

+(NSString *)subtitle {
	return @"Power On/Off BCR Loop";
}

+(NSString *)instructions {
	return @"Press the Start button to start an power On/Off the scanner. Press the Stop button to end the test.";
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
	unsigned int count = 0;
    [self.barcodeReader powerOff];
	while (startTest) {
		[self.barcodeReader powerOn];
        if (!self.barcodeReader.isAvailable) {
            [self performSelectorOnMainThread:@selector(logMessage:) withObject:@"BCR NOT AVAILABLE: TEST FAILED" waitUntilDone:NO];
            startTest = NO;
        }
		[self.barcodeReader powerOff];
        
		[self performSelectorOnMainThread:@selector(clearAndLogMessage:) withObject:[NSString stringWithFormat:@"Power On/Off #%08d", ++count] waitUntilDone:YES];
	}
	[[UIApplication sharedApplication] setIdleTimerDisabled:NO];
	[pool release];
}

-(void)test:(id)sender {
	UIButton * button = (UIButton *)sender;
	if ([button.titleLabel.text isEqualToString:@"Start"]) {
		[button setTitle:@"Stop" forState:UIControlStateNormal];
		startTest = YES;
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

#pragma mark ICAdministrationDelegate

-(void)confLogEntry:(NSString *)message withSeverity:(int)severity {
    NSLog(@"%@", message);
}

-(void)confSerialData:(NSData *)data incoming:(BOOL)isIncoming {
    NSLog(@"[Data: %@, Length: %lu]\n\t", (isIncoming == YES ? @"iSMP -> iPhone" : @"iPhone -> iSMP"), (unsigned long)[data length]);
}

#pragma mark -

@end
