//
//  ConfigurationTest_010.h
//  iSMPTestSuite
//
//  Created by Hichem Boussetta on 12/01/11.
//  Copyright 2011 Ingenico. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BasicConfigurationTest.h"
#import <iSMP/ICBarCodeReader.h>


@interface ConfigurationTest_001 : BasicConfigurationTest<ICBarCodeReaderDelegate> {
	UIButton			* buttonMeasure;
	BOOL				  measureSesssionInProgress;
	UISegmentedControl	* segConfigurations;
}

@property (retain) ICBarCodeReader * barcodeReader;
@property (retain) ICAdministration * control;
@property (assign) BOOL stressCommunication;

@end
