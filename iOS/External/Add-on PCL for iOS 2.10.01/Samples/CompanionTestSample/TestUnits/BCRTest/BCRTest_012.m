//
//  BCRTest_012.m
//  iSMPTestSuite
//
//  Created by Stephane RAbiller on 04/10/14.
//  Copyright 2014 Ingenico. All rights reserved.
//

#import "BCRTest_012.h"


@implementation BCRTest_012


+(NSString *)title {
	return @"Default configuration";
}

+(NSString *)subtitle {
	return @"Force to apply default configuration ";
}

+(NSString *)instructions {
	return @"touch the Default button to factory reset and apply the default configuration of the barcode reader.";
}

+(NSString *)category {
	return @"Unit Tests";
}


-(void)viewDidLoad {
	[super viewDidLoad];
	
	[self addButtonWithTitle:@"Default" andAction:@selector(test:)];
}

-(void)test:(id)sender {
		//Start the test
		[self.barcodeReader applyDefaultConfiguration];
}


-(void)barcodeData:(id)data ofType:(int)type {
	[super barcodeData:data ofType:type];
	[self.barcodeReader startScan];
}

-(void)accessoryDidConnect:(ICISMPDevice *)sender {
	[super accessoryDidConnect:sender];
	
	if (sender == self.barcodeReader) {
		[self.barcodeReader configureBarCodeReaderMode:ICBarCodeScanMode_SingleScan];
		[self.barcodeReader configureImagerMode:ICBarCodeImagerMode_1D2D];
		[self.barcodeReader enableSymbologies:NULL symbologyCount:0];
		int symbologies[] = {ICBarCode_UPCA, ICBarCode_Code128};
		[self.barcodeReader enableSymbologies:symbologies symbologyCount:sizeof(symbologies)/sizeof(symbologies[0])];
		[self.barcodeReader goodScanBeepEnable:YES];
	}
}


@end
