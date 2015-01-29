//
//  BCRTest_011.m
//  iSMPTestSuite
//
//  Created by Hichem Boussetta on 27/06/11.
//  Copyright 2011 Ingenico. All rights reserved.
//

#import "BCRTest_009.h"


@implementation BCRTest_009


+(NSString *)title {
	return @"Scanner Information";
}

+(NSString *)subtitle {
	return @"Retrieve the scanner's name, model, version";
}

+(NSString *)instructions {
	return @"Ensure the device is ready. Push the refresh button to retrieve the scanner's information.";
}

+(NSString *)category {
	return @"Unit Tests";
}


-(void)viewDidLoad {
	[super viewDidLoad];
    scannerName = [self addTextFieldWithTitle:@"Name"];
    scannerModel = [self addTextFieldWithTitle:@"Model"];
    scannerFirmVersion = [self addTextFieldWithTitle:@"Firmware Version"];
    buttonRefresh = [self addButtonWithTitle:@"Refresh" andAction:@selector(refresh)];
    [scannerName setEnabled:NO];
    [scannerModel setEnabled:NO];
    [scannerFirmVersion setEnabled:NO];
}

-(void)refreshHelper {
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    [self beginTimeMeasure];
    NSString *name = nil, *model = nil, *firmVersion = nil;
    name = [self.barcodeReader scannerName];
    model = [self.barcodeReader scannerModel];
    firmVersion = [self.barcodeReader getFirmwareVersion];
    float totalTime = [self endTimeMeasure];
    [scannerName performSelectorOnMainThread:@selector(setText:) withObject:name waitUntilDone:NO];
    [scannerModel performSelectorOnMainThread:@selector(setText:) withObject:model waitUntilDone:NO];
    [scannerFirmVersion performSelectorOnMainThread:@selector(setText:) withObject:firmVersion waitUntilDone:NO];
    [self performSelectorOnMainThread:@selector(logMessage:) withObject:[NSString stringWithFormat:@"Total Time: %f", totalTime] waitUntilDone:NO];
    [buttonRefresh setEnabled:YES];
    [pool release];
}

-(void)refresh {
    [buttonRefresh setEnabled:NO];
    [self performSelectorInBackground:@selector(refreshHelper) withObject:nil];
}

@end
