//
//  ConfigurationTest_032.h
//  iSMPTestSuite
//
//  Created by Stephane RABILLER on 22/09/14.
//  Copyright 2014 Ingenico. All rights reserved.
//

#import "ConfigurationTest_032.h"

@implementation ConfigurationTest_032

@synthesize pppNetwork;
@synthesize switchPPP;

-(void)viewDidAppear:(BOOL)animated {
    
    //Initialize the PPP Channel
    self.switchPPP              = [self addSwitchWithTitle:@"Start PPP"];
    [self.switchPPP addTarget:self action:@selector(onSwitchPPPValueChanged) forControlEvents:UIControlEventValueChanged];
    
    buttonUpdate = [self addButtonWithTitle:@"Update" andAction:@selector(update)];
    
    self.pppNetwork = [ICPPP sharedChannel];
    self.pppNetwork.delegate = self;
    [super viewDidAppear:false];
}

-(void)viewDidDisappear:(BOOL)animated {
    //Close the PPP Channel
    [self.pppNetwork closeChannel];
    self.pppNetwork.delegate = nil;
    self.pppNetwork = nil;
    [super viewDidDisappear: false];
}

-(void)dealloc {
    [super dealloc];
}


+(NSString *)title {
    return @"Remote Update using PPP";
}


+(NSString *)subtitle {
    return @"Remote update the device";
}

+(NSString *)instructions {
    return @"Switch on the PPP and wait PPP Started!! message. Then, touch down the Update button and make sure the iSMP approves the request and reboots to start the remote update process";
}

+(NSString *)category {
    return @"Device Update";
}

#pragma mark ICAdministrationDelegate



//PPP

-(void)onSwitchPPPValueChanged {
    NSLog(@"%s", __FUNCTION__);
    
    if (self.switchPPP.on) {
        
        //Start the PPP Stack
        if ([self.pppNetwork openChannel] == ISMP_Result_SUCCESS) {
            //Log Activity
            [self logMessage:@"Starting PPP..."];
        } else {
            //Log Activity
            [self logMessage:@"Failed to start PPP: Terminal not connected"];
            
            self.switchPPP.on = NO;
        }
        
    } else {
        
        //Stop PPP
        [self.pppNetwork closeChannel];
        
        //Log Activity
        [self logMessage:@"Closing PPP"];
    }
}


-(void)updateHelper {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    [self beginTimeMeasure];
    BOOL retValue = [self.configurationChannel startRemoteDownload];
    double totalTime = [self endTimeMeasure];
    NSString * msg = @"Update Request Approved";
    if (retValue == NO) {
        msg = @"Update Request Failed";
    }
    [self performSelectorOnMainThread:@selector(logMessage:) withObject:[NSString stringWithFormat:@"%@\nTotal Time: %f", msg, totalTime] waitUntilDone:NO];
    [buttonUpdate setEnabled:YES];
    [pool release];
}

-(void)update {
    [buttonUpdate setEnabled:NO];
    [self performSelectorInBackground:@selector(updateHelper) withObject:nil];
}

#pragma mark ICPPPDelegate

-(void)pppChannelDidOpen {
    
    NSLog(@"%s", __FUNCTION__);
    [self logMessage:@"PPP Started!!"];
}

-(void)pppChannelDidClose {
    
    NSLog(@"%s", __FUNCTION__);
    [self logMessage:@"PPP Stopped"];
}

#pragma mark -

@end