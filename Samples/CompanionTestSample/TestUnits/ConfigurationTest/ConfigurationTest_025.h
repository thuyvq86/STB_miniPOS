//
//  ConfigurationTest_025.h
//  iSMPTestSuite
//
//  Created by Hichem Boussetta on 01/02/12.
//  Copyright (c) 2012 Ingenico. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BasicConfigurationTest.h"


@interface ConfigurationTest_025 : BasicConfigurationTest<ICPrinterDelegate>

@property (nonatomic, assign) UITextField       * doTransactionTimeout;
@property (nonatomic, assign) UITextField       * amount;
@property (nonatomic, retain) NSMutableData     * printerData;
@property (nonatomic, retain) ICPrinter         * printer;
@property (nonatomic, assign) UISwitch          * emptyExtendedData;
@property (nonatomic, assign) UITextField       * paymentApplicationNumber;

@end