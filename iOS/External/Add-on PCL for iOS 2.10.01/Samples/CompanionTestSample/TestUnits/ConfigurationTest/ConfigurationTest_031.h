//
//  ConfigurationTest_031.h
//  iSMPTestSuite
//
//  Created by Stephane RABILLER on 22/09/14.
//  Copyright 2014 Ingenico. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BasicConfigurationTest.h"

@interface ConfigurationTest_031 :  BasicConfigurationTest<ICPrinterDelegate, ICISMPDeviceDelegate, ICPPPDelegate, ICAdministrationStandAloneDelegate>

@property (nonatomic, assign) UITextField       * doTransactionTimeout;
@property (nonatomic, assign) UITextField       * amount;
@property (nonatomic, retain) NSMutableData     * printerData;
@property (nonatomic, retain) ICPrinter         * printer;

@property (nonatomic, retain) ICPPP             * pppNetwork;
@property (nonatomic, retain) UISwitch          * switchPPP;

@end