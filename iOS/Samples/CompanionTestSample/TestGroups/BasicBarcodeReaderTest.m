//
//  BasicBarcodeReaderTest.m
//  iSMPTestSuite
//
//  Created by Hichem Boussetta on 27/12/10.
//  Copyright 2010 Ingenico. All rights reserved.
//

#import "BasicBarcodeReaderTest.h"


@implementation BasicBarcodeReaderTest
@synthesize barcodeReader=_barcodeReader;
#pragma mark class methods

+(NSString *)prefixLetter {
	static NSString * prefixLetter = @"B";
	return prefixLetter;
}

#pragma mark instance methods

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[super viewDidLoad];
	scanTime		= 0;
	scanTimeAverage = 0;
	barcodeCount	= 0;
	gotFirstScan	= NO;
	self.barcodeReader = [ICBarCodeReader sharedICBarCodeReader];
	self.barcodeReader.delegate = self;
    self.barcodeReader.iscpRetryCount = 100;
    [self.barcodeReader powerOn];
	[self displayDeviceState:[ICISMPDevice isAvailable]];
	//[self.barcodeReader applyDefaultConfiguration];
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [super viewDidUnload];	
}


-(void)viewWillDisappear:(BOOL)animated {
	self.barcodeReader.delegate = nil;
	self.barcodeReader			= nil;
	[super viewWillDisappear:animated];
}

- (void)dealloc {
    [super dealloc];
}


#pragma mark ICBarCodeReaderDelegate

-(void)barcodeData:(id)data ofType:(int)type {
	if (gotFirstScan == NO) {
		gotFirstScan = YES;
		[self logMessage:@"-- First scan performed - Starting scan period measure --"];
		[self beginTimeMeasure];
		return;
	}
	scanTime = [self endTimeMeasure];
	barcodeCount++;
	scanTimeAverage = ((scanTimeAverage * (barcodeCount - 1)) + scanTime) / barcodeCount;
	[self clearAndLogMessage:[NSString stringWithFormat:@"Scan N° %06lld - Code: %@ - Time Average: %f", barcodeCount, (NSString*)data, scanTimeAverage]];
	[self beginTimeMeasure];
}

-(void)onConfigurationApplied {
	
}

-(void)barcodeLogEntry:(NSString *)logEntry withSeverity:(int)severity {
	//if(severity != SEV_DEBUG)
		NSLog(@"[%@] %@", [ICISMPDevice severityLevelString:severity], logEntry);
	//[self performSelectorOnMainThread:@selector(logMessage:) withObject:logEntry waitUntilDone:NO];
}

/*
-(void)barcodeSerialData:(NSData *)data incoming:(BOOL)isIncoming {
	if (isIncoming) {
		NSLog(@"iSMP->iPhone: %@", [data hexDump]);
	} else {
		NSLog(@"iPhone->iSMP: %@", [data hexDump]);
	}
}
*/
-(void)triggerReleased {
	[self resetScanTimeMeasure];
}

-(void)enableTriggerSync {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	[self.barcodeReader enableTrigger:YES];
    [pool release];
}

-(void)configurationRequest {
    if (self.barcodeReader.isAvailable)
    {
        [self performSelectorInBackground:@selector(enableTriggerSync) withObject:nil];
    }
}

#pragma mark -


-(void)resetScanTimeMeasure {
	gotFirstScan	= NO;
	barcodeCount	= 0;
	scanTime		= 0;
	scanTimeAverage	= 0;
}

@end
