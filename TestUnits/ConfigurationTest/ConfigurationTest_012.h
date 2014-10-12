//
//  ConfigurationTest_028.h
//  iSMPTestSuite
//
//  Created by Hichem Boussetta on 14/02/12.
//  Copyright (c) 2012 Ingenico. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BasicConfigurationTest.h"

@interface ConfigurationTest_012 : BasicConfigurationTest

@property (nonatomic, assign) UIButton      * buttonPrintText;
@property (nonatomic, assign) UISwitch      * switchPrinter;
@property (nonatomic, assign) UITextField   * textCharacterCount;
@property (nonatomic, assign) UIButton      * buttonGetPrinterStatus;
@property (nonatomic, assign) NSInteger       lastPrinterStatus;

-(void)printerValueChanged;
-(NSString *)printerResultToString:(iBPResult)result;
-(void)printText;
-(void)getPrinterStatus;

@end