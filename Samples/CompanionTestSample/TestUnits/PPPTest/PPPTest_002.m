//
//  PPPTest_002.m
//  iSMPTestSuite
//
//  Created by Hichem BOUSSETTA on 14/06/13.
//  Copyright (c) 2013 Ingenico. All rights reserved.
//

#import "PPPTest_002.h"

@implementation PPPTest_002

+(NSString *)title {
	return @"Internal CNX";
}

+(NSString *)subtitle {
	return @"Telium to iOS Bridge";
}

+(NSString *)instructions {
	return @"Ensure that the device is ready. Turn the switch ON to start the PPP Stack. Connect from the terminal to iOS device and exchange data.";
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
    self.textPortForInternalConnections = [self addTextFieldWithTitle:@"Port for Internal CNX"];
    self.textMessage            = [self addTextFieldWithTitle:@"Message"];
    self.buttonSend             = [self addButtonWithTitle:@"Send Message" andAction:@selector(onButtonSendMessagePressed)];
    
    //Default Port for incoming connections
    self.textPortForInternalConnections.text    = @"8880";
    
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
            
            //Start TCP Server
            [self startTcpServer];
        } else {
            //Log Activity
            [self logMessage:@"Failed to start PPP: Terminal not connected"];
            
            self.switchPPP.on = NO;
        }
        
    } else {
        
        //Stop PPP
        [self.pppChannel closeChannel];
        
        //Stop TCP Servers
        [self stopTcpServer];
        
        //Log Activity
        [self logMessage:@"Closing PPP"];
        
        //Reset the network properties
        self.textIP.text            = @"";
        
    }
}

-(void)startTcpServer {
    NSLog(@"%s", __FUNCTION__);
    
    self.tcpServer = [[[ICTcpServer alloc] init] autorelease];
    self.tcpServer.port = [self.textPortForInternalConnections.text integerValue];
    self.tcpServer.delegate = self;
    self.tcpServer.streamDelegate = self;
    [self.tcpServer startServer];
}

-(void)stopTcpServer {
    NSLog(@"%s", __FUNCTION__);
    
    self.tcpServer = nil;
}

-(void)onButtonSendMessagePressed {
    NSLog(@"%s", __FUNCTION__);
    
    uint8_t * buffer = (uint8_t *)[self.textMessage.text UTF8String];
    NSInteger offset = 0, len = 0, messageLen = [self.textMessage.text lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    
    if ([self.tcpServer.outputStream streamStatus] == NSStreamStatusOpen) {
        while (offset < messageLen) {
            len = [self.tcpServer.outputStream write:&buffer[offset] maxLength:messageLen - len];
            
            if (len > 0) {
                offset += len;
            } else if (len < 0) {
                [self logMessage:@"Encountered an Error when sending the message"];
                break;
            }
        }
    }
}


#pragma mark ICPPPDelegate

-(void)pppChannelDidOpen {
    
    //Fill the network properties fields
    self.textIP.text            = self.pppChannel.IP;
    
    //Open the port for incoming connections
    [self.pppChannel addTerminalToiOSBridgeOnPort:[self.textPortForInternalConnections.text integerValue]];
    
    [super pppChannelDidOpen];
}

-(void)pppChannelDidClose {
    
    //Fill the network properties fields
    self.textIP.text            = @"";
    self.switchPPP.on           = NO;
    
    [super pppChannelDidClose];
}

#pragma mark -

#pragma mark ICTcpServerDelegate

-(void)connectionEstablished:(ICTcpServer *)sender {
    NSLog(@"%s", __FUNCTION__);
    
    [self logMessage:[NSString stringWithFormat:@"Client Connected [Name: %@]", self.tcpServer.peerName]];
}

#pragma mark -


#pragma mark NSStreamDelegate

#define BUFFER_SIZE     4096

-(void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode {
    
    uint8_t buffer[BUFFER_SIZE];
    int len = 0;
    
    switch (eventCode) {
        case NSStreamEventOpenCompleted:
            break;
        case NSStreamEventHasBytesAvailable:
            //Display the received data
            if (aStream == self.tcpServer.inputStream) {
                len = [self.tcpServer.inputStream read:buffer maxLength:sizeof(buffer)];
                
                if (len > 0) {
                    NSString * message = [[NSString alloc] initWithBytes:buffer length:len encoding:NSUTF8StringEncoding];
                    if (message != nil) {
                        [self performSelectorOnMainThread:@selector(logMessage:) withObject:message waitUntilDone:NO];
                    }
                    [message release];
                }
            }
            break;
        case NSStreamEventHasSpaceAvailable:
            break;
        case NSStreamEventEndEncountered:
            if ((aStream == self.tcpServer.inputStream) || (aStream == self.tcpServer.outputStream)) {
                [self performSelectorOnMainThread:@selector(logMessage:) withObject:@"Tcp Server Streams did close" waitUntilDone:NO];
            }
            break;
        case NSStreamEventErrorOccurred:
            if ((aStream == self.tcpServer.inputStream) || (aStream == self.tcpServer.outputStream)) {
                [self performSelectorOnMainThread:@selector(logMessage:) withObject:@"Tcp Server Streams Encountered an Error" waitUntilDone:NO];
            }
            break;
            
        default:
            break;
    }
}

#pragma mark -


@end
