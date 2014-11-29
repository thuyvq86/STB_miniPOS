//
//  PrinterTest_001.h
//  iSMPTestSuite
//
//  Created by Hichem Boussetta on 27/12/10.
//  Copyright 2010 Ingenico. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BasicPrintingTest.h"

@interface PrinterTest_001 : BasicPrintingTest {

	NSMutableData		* printerData;
}

@property (nonatomic, retain) NSMutableData * printerData;
@property (nonatomic, assign) BOOL            printingHasStarted;

@end
