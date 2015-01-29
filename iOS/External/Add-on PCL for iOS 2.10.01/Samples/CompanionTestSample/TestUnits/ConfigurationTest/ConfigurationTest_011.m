//
//  ConfigurationTest_031.m
//  iSMPTestSuite
//
//  Created by Hichem Boussetta on 06/06/12.
//  Copyright (c) 2012 Ingenico. All rights reserved.
//

#import "ConfigurationTest_011.h"

#define PAYLOAD_SIZE 1024


@interface ConfigurationTest_011 ()

-(void)_backgroundSendMessage;

@property (nonatomic, retain) NSData * payload;

@end


@implementation ConfigurationTest_011

@synthesize payload;

+(NSString *)title {
	return @"Communication Drop";
}


+(NSString *)subtitle {
	return @"Reboot the terminal while communicating";
}

+(NSString *)instructions {
	return @"Watch progress in the log box. The app keeps sending a payload of 512KB to the terminal and resets it randomly in meantime";
}

+(NSString *)category {
	return @"Stress";
}


-(void)viewDidLoad {
    [super viewDidLoad];
    
    //Init the payload
    char * bytes = (char *)malloc(PAYLOAD_SIZE * sizeof(char));
    memset(bytes, '*', PAYLOAD_SIZE);
    self.payload = [NSData dataWithBytes:bytes length:PAYLOAD_SIZE];
    free(bytes);
    
    //Start sending the payload
    [self sendMessage];
    
    //Reboot the terminal
    [self performSelector:@selector(resetTerminal) withObject:nil afterDelay:(3 + random() % 3)];
}


-(void)delayedSendMessage {
    [self sendMessage];
}


-(void)viewWillDisappear:(BOOL)animated {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(delayedSendMessage) object:nil];
    [super viewWillDisappear:animated];
}


-(void)resetTerminal {
    NSLog(@"%s", __FUNCTION__);
    
    [self performSelectorOnMainThread:@selector(logMessage:) withObject:[NSString stringWithFormat:@"%s", __FUNCTION__] waitUntilDone:NO];
    
    [self.configurationChannel reset:0];
}

-(void)_backgroundSendMessage {
    NSLog(@"%s", __FUNCTION__);
    
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    
    if (self.configurationChannel.isAvailable) {
        BOOL result = [self.configurationChannel sendMessage:self.payload];
        
        NSString * report = ((result == YES) ? @"Message Delivered" : @"Message Rejected");
        
        [self performSelectorOnMainThread:@selector(logMessage:) withObject:report waitUntilDone:NO];
    }
    
    [NSThread sleepForTimeInterval:0.25];
    
    [self performSelector:@selector(delayedSendMessage) withObject:nil afterDelay:0.25];
    
    [pool release];
}

-(void)sendMessage {
    NSLog(@"%s", __FUNCTION__);
    
    [self performSelectorInBackground:@selector(_backgroundSendMessage) withObject:nil];
}

#pragma mark ICDeviceDelegate

-(void)accessoryDidConnect:(ICISMPDevice *)sender {
    
    //Reboot the terminal
    [self performSelector:@selector(resetTerminal) withObject:nil afterDelay:(3 + random() % 3)];
    
    [super accessoryDidConnect:sender];
}

#pragma mark -


@end
