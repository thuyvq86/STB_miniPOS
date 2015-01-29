//
//  ConfigurationTest_024.h
//  iSMPTestSuite
//
//  Created by Hichem Boussetta on 23/01/12.
//  Copyright (c) 2012 Ingenico. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BasicConfigurationTest.h"
#import "BundleImagePicker.h"

@interface ConfigurationTest_024 : BasicConfigurationTest<BundleImagePickerDelegate>

@property (nonatomic, assign) UISwitch      * switchPrinter;
@property (nonatomic, assign) UITextField   * textLogoName;
@property (nonatomic, assign) UITextField   * textLogoFileName;
@property (nonatomic, assign) UIButton      * buttonSelectLogo;
@property (nonatomic, assign) UIButton      * buttonStoreLogo;
@property (nonatomic, assign) UIButton      * buttonPrintLogo;
@property (nonatomic, assign) UIButton      * buttonGetPrinterStatus;
@property (nonatomic, retain) NSArray       * bitmapArray;
@property (nonatomic, assign) NSInteger       lastPrinterStatus;

-(NSString *)printerResultToString:(iBPResult)result;
-(void)storeOrPrintLogo:(id)sender;
-(void)getPrinterStatus;
-(void)selectLogo;

@end
