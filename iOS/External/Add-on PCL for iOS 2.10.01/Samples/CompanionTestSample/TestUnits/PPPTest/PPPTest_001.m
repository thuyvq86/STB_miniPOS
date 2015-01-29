//
//  PPPTest_001.m
//  iSMPTestSuite
//
//  Created by Hichem BOUSSETTA on 03/06/13.
//  Copyright (c) 2013 Ingenico. All rights reserved.
//

#import "PPPTest_001.h"

@implementation PPPTest_001

@synthesize switchPPP;
@synthesize textIP;
@synthesize textSubmask;
@synthesize textDns;

+(NSString *)title {
	return @"Start PPP";
}

+(NSString *)subtitle {
	return @"Start PPP Stack";
}

+(NSString *)instructions {
	return @"Ensure that the device is ready. Turn the switch ON to start the PPP Stack. Turn it off to stop it.";
}

+(NSString *)category {
	return @"Basic";
}


-(void)viewDidLoad {
    [super viewDidLoad];
    
    self.switchPPP              = [self addSwitchWithTitle:@"PPP Stack"];
    [self.switchPPP addTarget:self action:@selector(onSwitchPPPValueChanged) forControlEvents:UIControlEventValueChanged];
    self.textWlanIP             = [self addTextFieldWithTitle:@"WLAN IP"];
    self.textIP                 = [self addTextFieldWithTitle:@"IP"];
    self.textSubmask            = [self addTextFieldWithTitle:@"SUBMASK"];
    self.textDns                = [self addTextFieldWithTitle:@"DNS"];
    self.textTerminalIP         = [self addTextFieldWithTitle:@"Terminal IP"];
    
    self.textWlanIP.enabled     = NO;
    self.textIP.enabled         = NO;
    self.textSubmask.enabled    = NO;
    self.textDns.enabled        = NO;
    self.textTerminalIP.enabled = NO;
    
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
        
        [self.configurationChannel close];
        
        //Log Activity
        [self logMessage:@"Closing PPP"];
        
        //Reset the network properties
        self.textIP.text            = @"";
        self.textSubmask.text       = @"";
        self.textDns.text           = @"";
        self.textTerminalIP.text    = @"";
        
    }
}


#pragma mark ICPPPDelegate

-(void)pppChannelDidOpen {
    
    //Fill the network properties fields
    self.textIP.text            = self.pppChannel.IP;
    self.textSubmask.text       = self.pppChannel.submask;
    self.textDns.text           = self.pppChannel.dns;
    self.textTerminalIP.text    = self.pppChannel.terminalIP;
    
    [super pppChannelDidOpen];
}

-(void)pppChannelDidClose {
    
    //Fill the network properties fields
    self.textIP.text            = @"";
    self.textSubmask.text       = @"";
    self.textDns.text           = @"";
    self.textTerminalIP.text    = @"";
    self.switchPPP.on       = NO;
    
    [super pppChannelDidClose];
}

#pragma mark -


@end
