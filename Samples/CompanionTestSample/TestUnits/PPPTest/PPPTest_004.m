//
//  PPPTest_004.m
//  iSMPTestSuite
//
//  Created by Hichem BOUSSETTA on 14/06/13.
//  Copyright (c) 2013 Ingenico. All rights reserved.
//

#import "PPPTest_004.h"

#define NB_SERVER_INSTANCES         5

@implementation PPPTest_004


+(NSString *)title {
	return @"Multi Internal CNX";
}

+(NSString *)subtitle {
	return @"Multi Telium to iOS Bridges";
}

+(NSString *)instructions {
	return @"Turn the switch ON to start the PPP Stack and the bridges. Open from the terminal multiple connections to iOS on the ports you've chosen and exchange data.";
}

+(NSString *)category {
	return @"Stress";
}


-(void)viewDidLoad {
    [super viewDidLoad];
    
    //Initialize arrays
    self.tcpServers = [NSMutableArray array];
    self.textPorts  = [NSMutableArray array];
    
    self.switchPPP              = [self addSwitchWithTitle:@"PPP Stack"];
    [self.switchPPP addTarget:self action:@selector(onSwitchPPPValueChanged) forControlEvents:UIControlEventValueChanged];
    self.textWlanIP             = [self addTextFieldWithTitle:@"WLAN IP"];
    self.textIP                 = [self addTextFieldWithTitle:@"IP"];
    
    //Initialize the text fields of the server ports & the servers
    NSInteger i = 0, basePort = 8880;
    UITextField * textField = nil;
    ICTcpServer * server = nil;
    
    for (i = 0; i < NB_SERVER_INSTANCES; i++) {
        textField = [self addTextFieldWithTitle:[NSString stringWithFormat:@"Port %d", i]];
        textField.text = [NSString stringWithFormat:@"%d", basePort + i];
        [self.textPorts addObject:textField];
        
        //Initialize server
        server = [[[ICTcpServer alloc] init] autorelease];
        server.delegate = self;
        server.streamDelegate = self;
        server.port = [textField.text integerValue];
        [self.tcpServers addObject:server];
    }
    
    self.segServers         = [self addSegmentedControlWithTitle:@"Server"];
    [self.segServers removeAllSegments];
    NSArray * items = [NSArray arrayWithObjects:@"1", @"2", @"3", @"4", @"5", nil];
    i = 0;
    for (NSString * item in items) {
        [self.segServers insertSegmentWithTitle:item atIndex:i++ animated:NO];
    }
    self.segServers.selectedSegmentIndex = 0;   //Select first element by default
    
    self.textMessage            = [self addTextFieldWithTitle:@"Message"];
    self.buttonSend             = [self addButtonWithTitle:@"Send Message" andAction:@selector(onButtonSendMessagePressed)];
    
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
            [self startTcpServers];
        } else {
            //Log Activity
            [self logMessage:@"Failed to start PPP: Terminal not connected"];
            
            self.switchPPP.on = NO;
        }
        
    } else {
        
        //Stop PPP
        [self.pppChannel closeChannel];
        
        //Stop TCP Servers
        [self stopTcpServers];
        
        //Log Activity
        [self logMessage:@"Closing PPP"];
        
        //Reset the network properties
        self.textIP.text            = @"";
        
    }
}

-(void)startTcpServers {
    NSLog(@"%s", __FUNCTION__);
    
    NSInteger i = 0;
    ICTcpServer * server = nil;
    
    for (i = 0; i < NB_SERVER_INSTANCES; i++) {
        server = [self.tcpServers objectAtIndex:i];
        server.port = [[(UITextField *)[self.textPorts objectAtIndex:i] text] integerValue];
        [server startServer];
    }
}

-(void)stopTcpServers {
    NSLog(@"%s", __FUNCTION__);
    
    for (ICTcpServer * server in self.tcpServers) {
        [server stopServer];
    }
}


-(NSInteger)getIndexOfServerWithOutStream:(NSOutputStream *)stream {
    NSInteger i = 0;
    for (i = 0; i < NB_SERVER_INSTANCES; i++) {
        if ([(ICTcpServer *)[self.tcpServers objectAtIndex:i] outputStream] == stream) {
            break;
        }
    }
    
    return i;
}

-(NSInteger)getIndexOfServerWithInStream:(NSInputStream *)stream {
    NSInteger i = 0;
    for (i = 0; i < NB_SERVER_INSTANCES; i++) {
        if ([(ICTcpServer *)[self.tcpServers objectAtIndex:i] inputStream] == stream) {
            break;
        }
    }
    
    return i;
}

-(NSInteger)getIndexOfServer:(ICTcpServer *)server {
    NSInteger i = 0;
    for (i = 0; i < NB_SERVER_INSTANCES; i++) {
        if ([self.tcpServers objectAtIndex:i] == server) {
            break;
        }
    }
    
    return i;
}


-(void)onButtonSendMessagePressed {
    NSLog(@"%s", __FUNCTION__);
    
    uint8_t * buffer = (uint8_t *)[self.textMessage.text UTF8String];
    NSInteger offset = 0, len = 0, messageLen = [self.textMessage.text lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    
    NSInteger serverIndex = self.segServers.selectedSegmentIndex;
    ICTcpServer * server = [self.tcpServers objectAtIndex:serverIndex];
    
    if ([server.outputStream streamStatus] == NSStreamStatusOpen) {
        while (offset < messageLen) {
            len = [server.outputStream write:&buffer[offset] maxLength:messageLen - len];
            
            if (len > 0) {
                offset += len;
            } else if (len < 0) {
                [self logMessage:[NSString stringWithFormat:@"Server [%d] Encountered an Error when sending the message", serverIndex]];
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
    for (UITextField * textField in self.textPorts) {
        [self.pppChannel addTerminalToiOSBridgeOnPort:[textField.text integerValue]];
    }
    
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
    
    NSInteger serverIndex = [self getIndexOfServer:sender];
    
    [self logMessage:[NSString stringWithFormat:@"[%d]Client Connected [Name: %@]", serverIndex, sender.peerName]];
}

#pragma mark -


#pragma mark NSStreamDelegate

#define BUFFER_SIZE     4096

-(void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode {
    
    uint8_t buffer[BUFFER_SIZE];
    int len = 0;
    NSInteger serverIndex = 0;
    
    switch (eventCode) {
        case NSStreamEventOpenCompleted:
            break;
        case NSStreamEventHasBytesAvailable:
            //Display the received data
            serverIndex = [self getIndexOfServerWithInStream:(NSInputStream *)aStream];
            if (serverIndex < NB_SERVER_INSTANCES) {
                len = [[(ICTcpServer *)[self.tcpServers objectAtIndex:serverIndex] inputStream] read:buffer maxLength:sizeof(buffer)];
                
                if (len > 0) {
                    NSString * message = [[NSString alloc] initWithBytes:buffer length:len encoding:NSUTF8StringEncoding];
                    if (message != nil) {
                        [self performSelectorOnMainThread:@selector(logMessage:) withObject:[NSString stringWithFormat:@"[%d]Received: %@", serverIndex, message] waitUntilDone:NO];
                    }
                    [message release];
                }
            }
            break;
        case NSStreamEventHasSpaceAvailable:
            break;
        case NSStreamEventEndEncountered:
            if ([aStream isKindOfClass:[NSInputStream class]]) {
                serverIndex = [self getIndexOfServerWithInStream:(NSInputStream *)aStream];
            } else if ([aStream isKindOfClass:[NSOutputStream class]]) {
                serverIndex = [self getIndexOfServerWithOutStream:(NSOutputStream *)aStream];
            }
            [self performSelectorOnMainThread:@selector(logMessage:) withObject:[NSString stringWithFormat:@"[%d]Tcp Server Streams did close", serverIndex] waitUntilDone:NO];
            break;
        case NSStreamEventErrorOccurred:
            if ([aStream isKindOfClass:[NSInputStream class]]) {
                serverIndex = [self getIndexOfServerWithInStream:(NSInputStream *)aStream];
            } else if ([aStream isKindOfClass:[NSOutputStream class]]) {
                serverIndex = [self getIndexOfServerWithOutStream:(NSOutputStream *)aStream];
            }
            [self performSelectorOnMainThread:@selector(logMessage:) withObject:[NSString stringWithFormat:@"[%d]Tcp Server Streams Encountered an Error", serverIndex] waitUntilDone:NO];
            break;
            
        default:
            break;
    }
}

#pragma mark -

@end
