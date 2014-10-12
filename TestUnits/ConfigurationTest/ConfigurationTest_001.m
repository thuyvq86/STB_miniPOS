//
//  ConfigurationTest_010.m
//  iSMPTestSuite
//
//  Created by Hichem Boussetta on 12/01/11.
//  Copyright 2011 Ingenico. All rights reserved.
//

#import "ConfigurationTest_001.h"


@implementation ConfigurationTest_001
@synthesize barcodeReader, control, stressCommunication;

+(NSString *)title {
	return @"Device Battery Life";
}


+(NSString *)subtitle {
	return @"Battery Life in Standby/Scan/Communication";
}

+(NSString *)instructions {
	return @"Ensure the device is ready and usb is switched to iPhone. Choose in which configuration to measure the battery life, launch the test and wait until the device disconnects.";
}

+(NSString *)category {
	return @"Power Management";
}


-(void)viewDidLoad {
	[super viewDidLoad];
	segConfigurations	= [self addSegmentedControlWithTitle:@"Configurations"];
	[segConfigurations insertSegmentWithTitle:@"Standby"		atIndex:0 animated:NO];
	[segConfigurations insertSegmentWithTitle:@"Scan"			atIndex:1 animated:NO];
	[segConfigurations insertSegmentWithTitle:@"Com"			atIndex:2 animated:NO];
	[segConfigurations setSelectedSegmentIndex:0];
	
	buttonMeasure		= [self addButtonWithTitle:@"Start Measure" andAction:@selector(measure)];
	measureSesssionInProgress	= NO;
	self.barcodeReader			= nil;
	self.control				= nil;
	self.stressCommunication	= NO;
}

-(void)viewWillDisappear:(BOOL)animated {
	self.stressCommunication	= NO;
	self.control				= nil;
	[self.barcodeReader stopScan];
	self.barcodeReader			= nil;
	[[UIApplication sharedApplication] setIdleTimerDisabled:NO];
	[super viewWillDisappear:animated];
}


-(void)measure {
	if ([ICISMPDevice isAvailable] == NO) {
		UIAlertView * alert = [[[UIAlertView alloc] initWithTitle:@"Error" message:@"The device is not ready" delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil] autorelease];
		[alert show];
		return;
	}
	[buttonMeasure setEnabled:NO];
	[segConfigurations setEnabled:NO];
	[[UIApplication sharedApplication] setIdleTimerDisabled:YES];
	switch (segConfigurations.selectedSegmentIndex) {
		case 0:
			self.control = [ICAdministration sharedChannel];
			self.control.delegate = self;
			[self logMessage:@"Time Measure on Standby Started"];
			break;
		case 1:
			self.barcodeReader = [ICBarCodeReader sharedICBarCodeReader];
			self.barcodeReader.delegate = self;
			[self.barcodeReader startScan];
			[self logMessage:@"Time Measure on Scan Started"];
			break;
		case 2:
			self.control = [ICAdministration sharedChannel];
			self.control.delegate = self;
			self.stressCommunication = YES;
			[self performSelectorInBackground:@selector(startCommunication) withObject:nil];
			[self logMessage:@"Time Measure on Communication Started"];
			break;

		default:
			break;
	}
	[self beginTimeMeasure];
	measureSesssionInProgress = YES;
}

-(void)startCommunication {
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	char buf[950];
	NSData * data = [NSData dataWithBytes:buf length:950];
	while (self.stressCommunication) {
		[self.control sendMessage:data];
	}
	[pool release];
}

-(void)accessoryDidDisconnect:(ICISMPDevice *)sender {
	[super accessoryDidDisconnect:sender];
	if (measureSesssionInProgress == NO) {
		return;
	}
	[buttonMeasure setEnabled:YES];
	[segConfigurations setEnabled:YES];
	double totalTime = [self endTimeMeasure];
	NSDate * date1 = [[NSDate alloc] init];
	NSDate * date2 = [[NSDate alloc] initWithTimeInterval:totalTime sinceDate:date1];
	NSCalendar *sysCalendar = [NSCalendar currentCalendar];
	unsigned int unitFlags = NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit | NSDayCalendarUnit;
	NSDateComponents *conversionInfo = [sysCalendar components:unitFlags fromDate:date1  toDate:date2  options:0];
	[self logMessage:[NSString stringWithFormat:@"Battery Life: %d Days, %d Hours, %d Minutes, %d Seconds", 
					  [conversionInfo day], [conversionInfo hour], [conversionInfo minute], [conversionInfo second]]];
	[date1 release];
	[date2 release];
	self.stressCommunication	= NO;
	self.control				= nil;
	//[self.barcodeReader stopScan];
	self.barcodeReader			= nil;
	measureSesssionInProgress	= NO;
	[[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

#pragma mark ICBarCodeReaderDelegate

-(void)triggerReleased {
	[self.barcodeReader startScan];
}

-(void)barcodeData:(id)data ofType:(int)type {
	
}

-(void)configurationRequest {
	
}

#pragma mark -

@end
