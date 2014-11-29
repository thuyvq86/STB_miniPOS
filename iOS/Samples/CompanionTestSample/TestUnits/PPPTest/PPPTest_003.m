//
//  PPPTest_003.m
//  iSMPTestSuite
//
//  Created by Hichem BOUSSETTA on 14/06/13.
//  Copyright (c) 2013 Ingenico. All rights reserved.
//

#import "PPPTest_003.h"

@implementation PPPTest_003

+(NSString *)title {
	return @"External CNX";
}

+(NSString *)subtitle {
	return @"iOS to Telium Bridge";
}

+(NSString *)instructions {
	return @"Turn the PPP Stack on and start a server on the terminal for the port of your choosing. Connect an external client to your iOS device on the same port and exchange data";
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
    self.textPortForExternalConnections = [self addTextFieldWithTitle:@"Port for External CNX"];
    
    //Default Port for incoming connections
    self.textPortForExternalConnections.text    = @"8890";
    
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
            [self logMessage:@"Staring PPP..."];
            
        } else {
            //Log Activity
            [self logMessage:@"Failed to start PPP: Terminal not connected"];
            
            self.switchPPP.on = NO;
        }
        
    } else {
        
        //Stop PPP
        [self.pppChannel closeChannel];
        
        //Stop TCP Server
        
        //Log Activity
        [self logMessage:@"Closing PPP"];
        
        //Reset the network properties
        self.textIP.text            = @"";
        
    }
}

#pragma mark ICPPPDelegate

-(void)pppChannelDidOpen {
    
    //Open the port for incoming connections
    [self.pppChannel addiOSToTerminalBridgeOnPort:[self.textPortForExternalConnections.text integerValue]];
    
    //Fill the network properties fields
    self.textIP.text            = self.pppChannel.IP;
    
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
