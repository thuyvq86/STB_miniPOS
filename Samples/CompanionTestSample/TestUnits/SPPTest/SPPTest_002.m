//
//  SPPTest_002.m
//  iSMPTestSuite
//
//  Created by Boris LECLERE on 8/27/12.
//  Copyright (c) 2012 Ingenico. All rights reserved.
//

#import "SPPTest_002.h"

#define DEFAULT_PAYLOAD_SIZE    128
#define RX_BUFFER               4096

@interface SPPTest_002 ()

@property (nonatomic, retain) NSMutableData * iPhone2iSPMData;
@property (nonatomic, retain) NSMutableData * iSMP2iPhoneData;
@property (assign)            BOOL            isTestRunning;
@property (nonatomic, retain) NSData        * payload;
@property (nonatomic, retain) UITextField * textBufferLength;

-(void)openSPPChannel;
-(void)writePayload;

@end

@implementation SPPTest_002
@synthesize textMessage;
@synthesize buttonStart;

@synthesize iPhone2iSPMData;
@synthesize iSMP2iPhoneData;
@synthesize isTestRunning;
@synthesize payload;
@synthesize textBufferLength;

#define RX_BUFFER 4096

+(NSString *)title {
	return @"Round Trip Time";
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
    
    //Initialize UI
    self.textBufferLength   = [self addTextFieldWithTitle:@"Number of Bytes"];
    self.buttonStart        = [self addButtonWithTitle:@"Start" andAction:@selector(onStart)];
    self.textBufferLength.text = [NSString stringWithFormat:@"%d", DEFAULT_PAYLOAD_SIZE];
    
    //Other Initialization
    self.isTestRunning      = NO;
    self.iPhone2iSPMData    = [NSMutableData data];
    self.iSMP2iPhoneData    = [NSMutableData data];
    self.payload            = nil;
}

-(void)viewWillDisappear:(BOOL)animated
{
	
	[super viewWillDisappear:animated];
}
-(void)viewDidUnload
{
    [super viewDidUnload];
}


-(void)onStart {
    NSLog(@"%s", __FUNCTION__);
    
    if (self.isTestRunning == NO) {
        NSLog(@"%s Start Measuring", __FUNCTION__);
        self.isTestRunning = YES;
        [self.buttonStart setTitle:@"Stop" forState:UIControlStateNormal];
        
        //Prepare the Payload
        NSInteger userBufferSize = [self.textBufferLength.text integerValue];
        NSInteger size = ((userBufferSize > 0) ? userBufferSize : DEFAULT_PAYLOAD_SIZE);
        char * _payload = (char *)malloc(size * sizeof(char));
        memset(_payload, '*', size);
        _payload[size - 1] = 'A';
        self.payload = [NSData dataWithBytes:_payload length:size];
        free(_payload);
        
        //Reset the reception buffer
        self.iSMP2iPhoneData.length = 0;
        
        //Write the payload
        [self writePayload];
    } else {
        NSLog(@"%s Stop Measuring", __FUNCTION__);
        self.isTestRunning = NO;
        [self.buttonStart setTitle:@"Start" forState:UIControlStateNormal];
    }
}

-(void)openSPPChannel {
    NSLog(@"%s", __FUNCTION__);
    
	//self.sppChannel.delegate = self;
	self.sppChannel.delegate = self;
}

-(void)writePayload {
    NSLog(@"%s", __FUNCTION__);
    
    //Open transaction channel
    [self openSPPChannel];
    
    self.iPhone2iSPMData.length = 0;
    [self.iPhone2iSPMData appendData:self.payload];
	
	[self.sppChannel SetReceiveBufferSize:payload.length];
	[self.sppChannel SendDataAsync:payload];
    //[self stream:self.transactionChannel.outStream handleEvent:NSStreamEventHasSpaceAvailable];
    
    //Start time measure
    [self beginTimeMeasure];
}

/** Reception */
-(void)didReceiveData:(NSData *)Data fromICISMPDevice:(ICISMPDevice *)Sender
{
	if ([self.iPhone2iSPMData isEqualToData:Data])
	{
		float roundTripTime = [self endTimeMeasure];
		
		NSString * _userMessage = [NSString stringWithFormat:@"Round Trip Time: %f", roundTripTime];
		
		//Display the time to user
		[self performSelectorOnMainThread:@selector(logMessage:) withObject:_userMessage waitUntilDone:NO];
		//Restart the test
		
		if (isTestRunning)
			[self writePayload];
		else
		{
			NSLog(@"%s Testing Stopped: Aborting...", __FUNCTION__);
		}
	}
	else
	{
		NSLog(@"%s Received Data is different from payload", __FUNCTION__);
	}
}
@end
