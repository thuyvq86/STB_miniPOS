//
//  ConfigurationTest_032.h
//  iSMPTestSuite
//
//  Created by Hichem Boussetta on 19/09/12.
//  Copyright (c) 2012 Ingenico. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BasicConfigurationTest.h"

@interface ConfigurationTest_021 : BasicConfigurationTest

@property (nonatomic, assign) UIButton      * buttonStartTesting;
@property (nonatomic, assign) UISwitch      * switchPrinter;
@property (nonatomic, assign) UIButton      * buttonGetPrinterStatus;
@property (nonatomic, assign) NSInteger       lastPrinterStatus;
@property (nonatomic, assign) BOOL            isTesting;

-(void)printerValueChanged;
-(NSString *)printerResultToString:(iBPResult)result;
-(void)startTesting;
-(void)getPrinterStatus;

@end
