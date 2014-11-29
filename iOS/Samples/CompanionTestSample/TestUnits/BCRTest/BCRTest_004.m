//
//  BCRTest_004.m
//  iSMPTestSuite
//
//  Created by Hichem Boussetta on 25/01/11.
//  Copyright 2011 Ingenico. All rights reserved.
//

#import "BCRTest_004.h"


@implementation BCRTest_004


+(NSString *)title {
	return @"Scan with 2 Soft Beeps";
}

+(NSString *)subtitle {
	return @"Send two playBeep requests after read";
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

- (void)lowLevelBeep {
	[self.barcodeReader playBeep:2700 during:80 andWait:0];
	[self.barcodeReader playBeep:3000 during:80 andWait:0];
}


-(void)barcodeData:(id)data ofType:(int)type {
	[self lowLevelBeep];
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
