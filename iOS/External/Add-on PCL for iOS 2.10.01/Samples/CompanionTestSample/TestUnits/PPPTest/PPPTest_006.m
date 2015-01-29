//
//  PPPTest_006.m
//  iSMPTestSuite
//
//  Created by Stephane RABILLER on 11/04/14.
//  Copyright (c) 2014 Ingenico. All rights reserved.
//

#import "PPPTest_006.h"


#define NB_BRIDGES          5


@implementation PPPTest_006

+(NSString *)title {
	return @"Multi External CNX";
}

+(NSString *)subtitle {
	return @"Multi iOS to Telium Bridges";
}

+(NSString *)instructions {
	return @"Turn the switch ON to initialize the PPP stack. Start 5 servers on the terminal on the same ports as those chosen below. Connect a telnet client to iOS on those ports and start exchanging data";
}

+(NSString *)category {
	return @"Stress";
}


-(void)viewDidLoad {
    [super viewDidLoad];
    
    //Initialize arrays
    self.textPorts  = [NSMutableArray array];
    
    self.switchPPP              = [self addSwitchWithTitle:@"PPP Stack"];
    [self.switchPPP addTarget:self action:@selector(onSwitchPPPValueChanged) forControlEvents:UIControlEventValueChanged];
    self.textWlanIP             = [self addTextFieldWithTitle:@"WLAN IP"];
    self.textIP                 = [self addTextFieldWithTitle:@"IP"];
    
    //Initialize the text fields of the server ports & the servers
    NSInteger i = 0, basePort = 8890;
    UITextField * textField = nil;
    
    for (i = 0; i < NB_BRIDGES; i++) {
        textField = [self addTextFieldWithTitle:[NSString stringWithFormat:@"Port %ld", (long)i]];
        textField.text = [NSString stringWithFormat:@"%d", basePort + i];
        [self.textPorts addObject:textField];
    }

    self.textWlanIP.enabled     = NO;
    self.textIP.enabled         = NO;
    
    //Get Wlan IP Address
    self.textWlanIP.text = [self getIPAddress];
}


-(void)onSwitchPPPValueChanged {
    NSLog(@"%s", __FUNCTION__);
    
    if (self.switchPPP.on) {
        
        //Start the PPP Stack
        if ([self.pppChannel openChannel] == ISMP_Result_SUCCESS) {
            
            //Log Activity
            [self logMessage:@"Starting PPP..."];
            
        } else {
            //Log Activity
            [self logMessage:@"Failed to start PPP: Terminal not connected"];
            
            self.switchPPP.on = NO;
        }
        
    } else {
        
        //Stop PPP
        [self.pppChannel closeChannel];
        
        //Log Activity
        [self logMessage:@"Closing PPP"];
        
        //Reset the network properties
        self.textIP.text            = @"";
        
    }
}


-(void)startiOSToTeliumBridges {
    NSLog(@"%s", __FUNCTION__);
    
    
    NSInteger i = 0;
    for (i = 0; i < NB_BRIDGES; i++) {
        [self.pppChannel addiOSToTerminalBridgeLocalOnPort:[[(UITextField *)[self.textPorts objectAtIndex:i] text] integerValue]];
    }
}


#pragma mark ICPPPDelegate

-(void)pppChannelDidOpen {
    
    //Fill the network properties fields
    self.textIP.text            = self.pppChannel.IP;
    
    //Set the bridges for external connections
    [self startiOSToTeliumBridges];
    
    [super pppChannelDidOpen];
}

-(void)pppChannelDidClose {
    
    //Fill the network properties fields
    self.textIP.text            = @"";
    self.switchPPP.on           = NO;
    
    [super pppChannelDidClose];
}

#pragma mark -

@end
