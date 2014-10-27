//
//  BCRTest_005.m
//  iSMPTestSuite
//
//  Created by Hichem Boussetta on 26/01/11.
//  Copyright 2011 Ingenico. All rights reserved.
//

#import "BCRTest_005.h"


@implementation BCRTest_005


+(NSString *)title {
	return @"Scan with NO Beep";
}

+(NSString *)subtitle {
	return @"Scanner in silent mode";
}

+(NSString *)instructions {
	return @"Target your scanner to some close barcodes (UPC-A / Code128) and touch the start button to launch the scan.";
}

+(NSString *)category {
	return @"Stress";
}


-(void)viewDidLoad {
	[super viewDidLoad];
	
	[self addButtonsWithTitle:@"Start" andTitle2:@"Stop" toAction:@selector(test:)];
	[self.barcodeReader configureBarCodeReaderMode:ICBarCodeScanMode_SingleScan];
	[self.barcodeReader configureImagerMode:ICBarCodeImagerMode_1D2D];
	[self.barcodeReader enableSymbologies:NULL symbologyCount:0];
	int symbologies[2] = {ICBarCode_UPCA, ICBarCode_Code128};
	[self.barcodeReader enableSymbologies:symbologies symbologyCount:2];
	[self.barcodeReader goodScanBeepEnable:NO];
}

-(void)dealloc {
	[super dealloc];
}

-(void)test:(id)sender {
	if (((UIButton *)sender).tag == 0) {
		//Start the test
		[self.barcodeReader startScan];
	} else {
		//Stop the test
		[self.barcodeReader stopScan];
		[self resetScanTimeMeasure];
	}
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
