//
//  ConfigurationTest_022.h
//  iSMPTestSuite
//
//  Created by Hichem Boussetta on 04/01/12.
//  Copyright (c) 2012 Ingenico. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BasicConfigurationTest.h"

@interface ConfigurationTest_005 : BasicConfigurationTest

@property (nonatomic, assign) UIButton      * buttonPrintText;
@property (nonatomic, assign) UISwitch      * switchPrinter;
@property (nonatomic, assign) UITextField   * textString;
@property (nonatomic, assign) UITextField   * textCharacterCount;
@property (nonatomic, assign) UIButton      * buttonGetPrinterStatus;
@property (nonatomic, assign) NSInteger       lastPrinterStatus;

-(void)printerValueChanged;
-(NSString *)printerResultToString:(iBPResult)result;
-(void)printText;
-(void)textFieldDidChange;
-(void)getPrinterStatus;

@end
