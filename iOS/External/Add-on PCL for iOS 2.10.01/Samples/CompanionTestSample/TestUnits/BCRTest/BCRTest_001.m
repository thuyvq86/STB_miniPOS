//
//  BCRTest_001.m
//  iSMPTestSuite
//
//  Created by Hichem Boussetta on 04/01/11.
//  Copyright 2011 Ingenico. All rights reserved.
//

#import "BCRTest_001.h"


@implementation BCRTest_001


+(NSString *)title {
	return @"Scans with Hard Beep";
}

+(NSString *)subtitle {
	return @"Scanner emitting a good scan beep ";
}

+(NSString *)instructions {
	return @"Target your scanner to all symbologies and touch the start button to launch the scan.";
}

+(NSString *)category {
	return @"Stress";
}


-(void)viewDidLoad {
	[super viewDidLoad];
	
	[self addButtonsWithTitle:@"Start" andTitle2:@"Stop" toAction:@selector(test:)];
	[self.barcodeReader configureBarCodeReaderMode:ICBarCodeScanMode_SingleScan];
	/*[self.barcodeReader configureImagerMode:ICBarCodeImagerMode_1D2D];
	[self.barcodeReader enableSymbologies:NULL symbologyCount:0];
	int symbologies[] = {ICBarCode_UPCA, ICBarCode_Code128, ICBarCode_EAN13};
	[self.barcodeReader enableSymbologies:symbologies symbologyCount:sizeof(symbologies)/sizeof(symbologies[0])];*/
    [self.barcodeReader bufferWriteCommands];
    [self.barcodeReader configureImagerMode:ICBarCodeImagerMode_1D2D];
    [self.barcodeReader goodScanBeepEnable:NO];
    [self.barcodeReader enableSymbology:ICBarCode_AllSymbologies enabled:YES];
	[self.barcodeReader unbufferSetupCommands];
    [self.barcodeReader enableTrigger:YES];
	[self.barcodeReader goodScanBeepEnable:YES];
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
