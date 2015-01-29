//
//  Transac_Test_007.m
//  iSMPTestSuite
//
//  Created by Hichem BOUSSETTA on 28/09/12.
//  Copyright (c) 2012 Ingenico. All rights reserved.
//

#import "Transac_Test_003.h"

@implementation Transac_Test_003

@synthesize admin;
@synthesize transactionChannel;

+(NSString *)title {
	return @"Com Drop";
}

+(NSString *)subtitle {
	return @"Reset During Communication";
}

+(NSString *)instructions {
	return @"The stress testings has started";
}

+(NSString *)category {
	return @"Stress";
}


-(void)_backgroundOpen {
    NSLog(@"%s", __FUNCTION__);
    
    if ([self.admin respondsToSelector:@selector(open)]) {
        [self.admin open];
    }
    
    if (self.admin.isAvailable) {
        //Reboot the terminal
        [self performSelectorOnMainThread:@selector(resetTerminal) withObject:nil waitUntilDone:NO];
    }
    
    [self displayDeviceState:[self.admin isAvailable]];
}


-(void)viewDidLoad {
    [super viewDidLoad];
    
    self.transactionChannel = [ICTransaction sharedChannel];
    self.transactionChannel.delegate = self;
    
    self.admin = [ICAdministration sharedChannel];
    self.admin.delegate = self;
    
    [self performSelectorInBackground:@selector(_backgroundOpen) withObject:nil];
    
    //Ignore SIGPIPE
    signal(SIGPIPE, SIG_IGN);
    
    [self writeDataOnTransactionChannel];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(writeDataOnTransactionChannel) object:nil];
}



-(void)resetTerminal {
    NSLog(@"%s", __FUNCTION__);
    
    [self.admin performSelector:@selector(reset:) withObject:nil afterDelay:(1 + random() % 3)];
}

#define DATA_LENGTH 2048
-(void)writeDataOnTransactionChannel {
    NSLog(@"%s", __FUNCTION__);
    
    char buffer[DATA_LENGTH];
    memset(buffer, '*', DATA_LENGTH);
    
    if (self.transactionChannel.isAvailable) {
        [self.transactionChannel SendDataAsync:[NSData dataWithBytes:buffer length:DATA_LENGTH]];
    }
    [self performSelector:@selector(writeDataOnTransactionChannel) withObject:nil afterDelay:0.25];
}

#pragma mark ICISMPDeviceDelegate

-(void)onAccessoryDidConnect:(id)sender {
    NSLog(@"%s", __FUNCTION__);
    
    if (sender == self.transactionChannel) {
        
    } else if (sender == self.admin) {
        if ([self.admin respondsToSelector:@selector(open)]) {
            [self performSelectorInBackground:@selector(_backgroundOpen) withObject:nil];
        }
    }
}

#pragma mark -


#pragma mark ICISMPDeviceExtensionDelegate

-(void)didReceiveData:(NSData *)Data fromICISMPDevice:(ICISMPDevice *)Sender {
    NSLog(@"Received Bytes[Length: %lu] %@", (unsigned long)[Data length], [Data hexDump]);
}

#pragma mark -


#pragma mark ICISMPDeviceDelegate

-(void)logSerialData:(NSData *)data incomming:(BOOL)isIncoming {
    //NSLog(@"%s [%@][Length: %d]\n\t%@", __FUNCTION__, ((isIncoming) ? @"iSMP -> iPhone" : @"iPhone -> iSMP"), [data length], [data hexDump]);
    [self performSelectorOnMainThread:@selector(logMessage:) withObject:[NSString stringWithFormat:@"[Data: %@, Length: %lu]", ((isIncoming) ? @"iSMP -> iPhone" : @"iPhone -> iSMP"), (unsigned long)[data length]] waitUntilDone:NO];
}

#pragma mark -


@end
