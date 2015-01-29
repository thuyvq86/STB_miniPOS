//
//  Transac_Test_006.m
//  iSMPTestSuite
//
//  Created by Hichem Boussetta on 24/05/12.
//  Copyright (c) 2012 Ingenico. All rights reserved.
//

#import "Transac_Test_002.h"

#define DEFAULT_PAYLOAD_SIZE    128
#define RX_BUFFER               4096

@interface Transac_Test_002 ()

@property (nonatomic, retain) NSMutableData * iPhone2iSPMData;
@property (nonatomic, retain) NSMutableData * iSMP2iPhoneData;
@property (assign)            BOOL            isTestRunning;
@property (nonatomic, retain) NSData        * payload;
@property (nonatomic, assign) NSUInteger      loopCount;
@property (nonatomic, assign) double          mediumTime;
@property (nonatomic, assign) double          mediumBaudRate;
@property (nonatomic, assign) NSUInteger      payloadSize;

-(void)openTransactionChannel;
-(void)closeTransactionChannel;
-(void)writePayload;
-(void)resetMeasures;
-(void)updateMeasures:(double)newTimeValue;

@end


@implementation Transac_Test_002

@synthesize transactionChannel;
@synthesize iPhone2iSPMData;
@synthesize iSMP2iPhoneData;
@synthesize textBufferLength;
@synthesize buttonStart;
@synthesize isTestRunning;
@synthesize payload;
@synthesize textBaudrate;
@synthesize textMediumTime;
@synthesize textLoopCount;


+(NSString *)title {
	return @"Round Trip Time";
}

+(NSString *)subtitle {
	return @"Measure the Round Trip Time";
}

+(NSString *)instructions {
	return @"Ensure that the device is ready and that the COM0_ECHO app is started on the iSMP. Push Start/Stop button to start/stop the testing";
}

+(NSString *)category {
	return @"Basic";
}




-(void)viewDidLoad {
    [super viewDidLoad];
    
    //Initialize UI
    self.textBufferLength       = [self addTextFieldWithTitle:@"Number of Bytes"];
    self.buttonStart            = [self addButtonWithTitle:@"Start" andAction:@selector(onStart)];
    self.textBufferLength.text  = [NSString stringWithFormat:@"%d", DEFAULT_PAYLOAD_SIZE];
    self.textLoopCount          = [self addTextFieldWithTitle:@"Loop Count"];
    self.textMediumTime         = [self addTextFieldWithTitle:@"Medium Time (s)"];
    self.textBaudrate           = [self addTextFieldWithTitle:@"Medium Baudrate (kb/s)"];
    self.textLoopCount.enabled  = NO;
    self.textBaudrate.enabled   = NO;
    self.textMediumTime.enabled = NO;
    self.textLoopCount.text     = @"0";
    self.textMediumTime.text    = @"0";
    self.textBaudrate.text      = @"0";
    
    //Other Initialization
    self.isTestRunning      = NO;
    self.iPhone2iSPMData    = [NSMutableData data];
    self.iSMP2iPhoneData    = [NSMutableData data];
    self.payload            = nil;
}

-(void)viewWillDisappear:(BOOL)animated
{
	//Close transaction channel
    [self closeTransactionChannel];
    
	[super viewWillDisappear:animated];
}
-(void)viewDidUnload {
    
    //Close transaction channel
    [self closeTransactionChannel];
    
    [super viewDidUnload];
}

-(void)resetMeasures {
    NSLog(@"%s", __FUNCTION__);
    
    self.mediumTime                 = 0;
    self.loopCount                  = 0;
    self.textLoopCount.text         = @"0";
    self.textMediumTime.text        = @"0";
    self.textBaudrate.text          = @"0";
}

-(void)updateMeasures:(double)newTimeValue {
    static NSUInteger prevLoopCount = 0;
    static double baudrate = 0;
    
    prevLoopCount = self.loopCount;
    self.loopCount++;
    
    baudrate = (2 * self.payloadSize * 8) / (newTimeValue * 1024);
    
    self.mediumTime = ((self.mediumTime * prevLoopCount) + newTimeValue) / self.loopCount;
    self.mediumBaudRate = ((self.mediumBaudRate * prevLoopCount) + (self.payloadSize * 2 * 8 / newTimeValue)) / self.loopCount;     // 8 is the number of bits per byte
    
    self.textLoopCount.text         = [NSString stringWithFormat:@"%lu", (unsigned long)self.loopCount];
    self.textMediumTime.text        = [NSString stringWithFormat:@"%f", self.mediumTime];
    self.textBaudrate.text          = [NSString stringWithFormat:@"%f", self.mediumBaudRate / 1024];    //We divide by 1024 to get the baudrate in kb/s
    
    NSString * _userMessage = [NSString stringWithFormat:@"Round Trip Time: %f s  ***** Baudrate: %f kb/s", newTimeValue, baudrate];
    
    //Display the time to user
    [self performSelectorOnMainThread:@selector(logMessage:) withObject:_userMessage waitUntilDone:NO];
}


-(void)onStart {
    NSLog(@"%s", __FUNCTION__);
    
    if (self.isTestRunning == NO) {
        
        //Open transaction channel
        [self openTransactionChannel];
        
        //Check if the channel is opened
        if (!self.transactionChannel.isAvailable) {
            [self logMessage:@"Failed to open transaction channel"];
            return;
        }
        
        NSLog(@"%s Start Measuring", __FUNCTION__);
        self.isTestRunning = YES;
        [self.buttonStart setTitle:@"Stop" forState:UIControlStateNormal];
        
        //Prepare the Payload
        NSInteger userBufferSize = [self.textBufferLength.text integerValue];
        NSInteger size = ((userBufferSize > 0) ? userBufferSize : DEFAULT_PAYLOAD_SIZE);
        self.payloadSize = size;
        char * _payload = (char *)malloc(size * sizeof(char));
        memset(_payload, '*', size);
        _payload[size - 1] = 'A';
        self.payload = [NSData dataWithBytes:_payload length:size];
        free(_payload);
        
        //Reset the reception buffer
        self.iSMP2iPhoneData.length = 0;
        
        //Reset Measures
        [self resetMeasures];
        
        //Write the payload
        [self writePayload];
    } else {
        NSLog(@"%s Stop Measuring", __FUNCTION__);
        self.isTestRunning = NO;
        [self.buttonStart setTitle:@"Start" forState:UIControlStateNormal];
        
        //Close transaction channel
        [self closeTransactionChannel];
    }
}

-(void)openTransactionChannel {
    NSLog(@"%s", __FUNCTION__);
    
    self.transactionChannel = [ICTransaction sharedChannel];
    self.transactionChannel.delegate = self;
	//[self.transactionChannel forwardStreamEvents:YES to:self];
}

-(void)closeTransactionChannel {
    NSLog(@"%s", __FUNCTION__);
    
    self.transactionChannel = nil;
}

-(void)writePayload {
    NSLog(@"%s", __FUNCTION__);
    
    self.iPhone2iSPMData.length = 0;
    [self.iPhone2iSPMData appendData:self.payload];
	
    //Start time measure
    [self beginTimeMeasure];
    
	[transactionChannel SendDataAsync:payload];
    //[self stream:self.transactionChannel.outStream handleEvent:NSStreamEventHasSpaceAvailable];
}

/** Reception */
-(void)didReceiveData:(NSData *)Data fromICISMPDevice:(ICISMPDevice *)Sender
{
    static double roundTripTime = 0;
    //Append the received data to the in buffer
    [self.iSMP2iPhoneData appendData:Data];
    //NSLog(@"%s Received %d/%d", __FUNCTION__, self.iSMP2iPhoneData.length, self.payload.length);
    
	if ([self.iSMP2iPhoneData isEqualToData:self.payload])
	{
		roundTripTime = [self endTimeMeasure];
        
        //Update measures
        [self updateMeasures:roundTripTime];

		
        //Reset the in buffer
        self.iSMP2iPhoneData.length = 0;
        
        //Restart the test
		if (isTestRunning) {
            [NSThread sleepForTimeInterval:0.5f];
			[self writePayload];
        } else {
            [self performSelectorOnMainThread:@selector(logMessage:) withObject:@"Testing Stopped: Aborting..." waitUntilDone:NO];
			
            //Close transaction channel
            [self closeTransactionChannel];
		}
	}
	else if (self.iSMP2iPhoneData.length > self.payload.length)
	{
		NSLog(@"%s Received Data is different from payload", __FUNCTION__);
		//[self logEntry:[NSString stringWithFormat:@"%s Received Data:[Length: %d] \n\t%@", __FUNCTION__, [self.iSMP2iPhoneData length], [self.iSMP2iPhoneData hexDump]] withSeverity:SEV_DEBUG];
		
		//[self logEntry:[NSString stringWithFormat:@"%s Payload Data:[Length: %d] \n\t %@", __FUNCTION__, [self.payload length], [self.payload hexDump]] withSeverity:SEV_DEBUG];
        
        self.iSMP2iPhoneData.length = 0;
        
        //Stop the testing
        self.isTestRunning = NO;
        [self.buttonStart setTitle:@"Start" forState:UIControlStateNormal];
    }
}
#pragma mark NSStreamEventDelegate

//-(void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode {
//    int written = 0;
//	int read = 0;
//	uint8_t inBuffer[RX_BUFFER];
//    switch (eventCode) {
//		case NSStreamEventHasBytesAvailable:
//			if (aStream == self.transactionChannel.inStream) {
//                
//                //Check if the testing is stopped
//                if (self.isTestRunning == NO) {
//                    NSLog(@"%s Testing Stopped: Aborting...", __FUNCTION__);
//                    
//                    //Close transaction channel
//                    self.transactionChannel = nil;
//                    return;
//                }
//                
//				read = [self.transactionChannel.inStream read:inBuffer maxLength:RX_BUFFER];
//                
//				if (read > 0) {
//                    //Log received data
//                    [self logSerialData:[NSData dataWithBytes:inBuffer length:read] incomming:YES];
//                    
//					//Append the received data to the reception buffer
//                    [self.iSMP2iPhoneData appendBytes:inBuffer length:read];
//                    
//                    //Process
//                    if ([self.iSMP2iPhoneData isEqualToData:self.payload]) {
//                        //Clear the received data
//                        self.iSMP2iPhoneData.length = 0;
//                        
//                        float roundTripTime = [self endTimeMeasure];
//                        
//                        NSString * _userMessage = [NSString stringWithFormat:@"Round Trip Time: %f", roundTripTime];
//                        
//                        //Display the time to user
//                        [self performSelectorOnMainThread:@selector(logMessage:) withObject:_userMessage waitUntilDone:NO];
//                        
//                        //Restart the test
//                        [self writePayload];
//                    } else {
//                        NSLog(@"%s Received Data is different from payload", __FUNCTION__);
//                        
//                        [self logEntry:[NSString stringWithFormat:@"%s Received Data: %@", __FUNCTION__, [self.iSMP2iPhoneData hexDump]] withSeverity:SEV_DEBUG];
//                        
//                        [self logEntry:[NSString stringWithFormat:@"%s Payload Data: %@", __FUNCTION__, [self.payload hexDump]] withSeverity:SEV_DEBUG];
//                    }
//				} else {
//                    NSLog(@"%s Failed to read NSInputStream data", __FUNCTION__);
//                }
//			}
//			break;
//		case NSStreamEventHasSpaceAvailable:
//			if (aStream == self.transactionChannel.outStream) {
//                
//				if ([self.iPhone2iSPMData length] > 0) {
//					written = [self.transactionChannel.outStream write:(uint8_t *)[self.iPhone2iSPMData bytes] maxLength:[self.iPhone2iSPMData length]];
//					if (written > 0) {
//                        //Log the sent data
//                        [self logSerialData:[self.iPhone2iSPMData subdataWithRange:NSMakeRange(0, written)] incomming:NO];
//                        
//						[self.iPhone2iSPMData setData:[self.iPhone2iSPMData subdataWithRange:NSMakeRange(written, [self.iPhone2iSPMData length] - written)]];
//					}
//				}
//			}
//			break;
//            
//		default:
//			break;
//	}
//}

#pragma mark -


#pragma mark ICDeviceDelegate

-(void)logEntry:(NSString *)message withSeverity:(int)severity {
    NSLog(@"%s [%@][%@]", __FUNCTION__, [ICTransaction severityLevelString:severity], message);
}
 
-(void)logSerialData:(NSData *)data incomming:(BOOL)isIncoming {
    //NSLog(@"%s [%@][Length: %d]\n\t%@", __FUNCTION__, ((isIncoming) ? @"iSMP -> iPhone" : @"iPhone -> iSMP"), [data length], [data hexDump]);
    //NSLog(@"%s [%@][Length: %d]", __FUNCTION__, ((isIncoming) ? @"iSMP -> iPhone" : @"iPhone -> iSMP"), [data length]);
}

#pragma mark -

@end
