//
//  BCRTest_014.h
//  iSMPTestSuite
//
//  Created by Stephane Rabiller on 03/06/13.
//  Copyright 2013 Ingenico. All rights reserved.
//

#import "BCRTest_007.h"



@implementation BCRTest_007


+(NSString *)title {
	return @"Open/Close Channel with random reset";
}

+(NSString *)subtitle {
	return @"Test added for Apple crash";
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
    signal(SIGPIPE, SIG_IGN);
    self.configurationChannel = [ICAdministration sharedChannel];
    self.configurationChannel.delegate = self;

    [self performSelectorInBackground:@selector(_backgroundOpen) withObject:nil];
	[self addButtonWithTitle:@"Start" andAction:@selector(test:)];
}

-(void)viewWillDisappear:(BOOL)animated {
	startTest = NO;
	[[UIApplication sharedApplication] setIdleTimerDisabled:NO];
	[super viewWillDisappear:animated];
}

-(void)resetTerminal {
    NSLog(@"%s", __FUNCTION__);
    
    [self performSelectorOnMainThread:@selector(logMessage:) withObject:[NSString stringWithFormat:@"%s", __FUNCTION__] waitUntilDone:NO];
    
    [self.configurationChannel reset:0];
}

-(void)accessoryDidConnect:(ICISMPDevice *)sender {
    
    //Reboot the terminal
    if(sender == self.barcodeReader)
    {
        [self performSelector:@selector(resetTerminal) withObject:nil afterDelay:(3 + random() % 3)];
        
    }
    if(sender == self.configurationChannel)
    {
        [self performSelectorInBackground:@selector(_backgroundOpen) withObject:nil];
    }
    [super accessoryDidConnect:sender];
}

-(void)_backgroundOpen {
    NSLog(@"%s", __FUNCTION__);
    
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    
    if ([(NSObject *)self.configurationChannel respondsToSelector:@selector(open)]) {
        [self.configurationChannel open];
    }
    
    [self displayDeviceState:[self.configurationChannel isAvailable]];
    
    [pool release];
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
