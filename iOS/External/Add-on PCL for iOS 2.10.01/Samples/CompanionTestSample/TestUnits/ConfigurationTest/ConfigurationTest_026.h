//
//  ConfigurationTest_026.h
//  iSMPTestSuite
//
//  Created by Hichem Boussetta on 07/02/12.
//  Copyright (c) 2012 Ingenico. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BasicConfigurationTest.h"

@interface ConfigurationTest_026 : BasicConfigurationTest

@property (nonatomic, assign) UISwitch      * switchPrinter;
@property (nonatomic, assign) UIButton      * buttonPrint;
@property (nonatomic, assign) UIButton      * buttonGetPrinterStatus;
@property (nonatomic, assign) NSInteger       lastPrinterStatus;

-(void)printerValueChanged;
-(void)printFonts;
-(void)getPrinterStatus;
-(NSString *)printerResultToString:(iBPResult)result;
-(NSArray *)iOSSupportedFonts;

@end
