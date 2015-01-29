//
//  ConfigurationTest_009.h
//  iSMPTestSuite
//
//  Created by Hichem Boussetta on 10/01/11.
//  Copyright 2011 Ingenico. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BasicConfigurationTest.h"


@interface ConfigurationTest_009 : BasicConfigurationTest<ICPrinterDelegate>

@property (nonatomic, assign) UITextField       * doTransactionTimeout;
@property (nonatomic, assign) UITextField       * amount;
@property (nonatomic, retain) NSMutableData     * printerData;
@property (nonatomic, retain) ICPrinter         * printer;

@end
