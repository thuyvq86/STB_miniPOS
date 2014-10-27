//
//  SPPTest_003.m
//  iSMPTestSuite
//
//  Created by Stephane Rabiller on 14/05/13.
//  Copyright (c) 2013 Ingenico. All rights reserved.
//

#import "SPPTest_003.h"

#define DEFAULT_PAYLOAD_SIZE    128
#define RX_BUFFER               4096

@interface SPPTest_003 ()

@property (atomic, assign)    BOOL            isTestRunning;

-(void)openSPPChannel;

@end

@implementation SPPTest_003


#define RX_BUFFER 4096

+(NSString *)title {
	return @"Get Peripheral Status";
}

+(NSString *)subtitle {
	return @"Measure the Round Trip Time";
}

+(NSString *)instructions {
	return @"Ensure that the device is ready and that the iSMP is paired to a bluetooth device. Push Start/Stop button to start/stop the testing";
}

+(NSString *)category {
	return @"Basic";
}


-(void)viewDidLoad {
    [super viewDidLoad];
        self.buttonStart        = [self addButtonWithTitle:@"Get Peripheral Status" andAction:@selector(onButtonPressed)];
}

-(void)viewWillDisappear:(BOOL)animated
{
	
	[super viewWillDisappear:animated];
}
-(void)viewDidUnload
{
    [super viewDidUnload];
}


-(void)backgroundGetSPPStatus {
    NSLog(@"%s", __FUNCTION__);
    iSMPPeripheral device;
    device = 0;
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    
    self.configurationChannel = [ICAdministration sharedChannel];
    self.configurationChannel.delegate = self;
    
    [self.configurationChannel open];
    [self.configurationChannel getPeripheralStatus:device];
    
    [pool release];
}


-(void)onButtonPressed {
    NSLog(@"%s", __FUNCTION__);

    [self performSelectorInBackground:@selector(backgroundGetSPPStatus) withObject:nil];
}

-(void)openSPPChannel {
    NSLog(@"%s", __FUNCTION__);
	self.sppChannel.delegate = self;
}



@end

