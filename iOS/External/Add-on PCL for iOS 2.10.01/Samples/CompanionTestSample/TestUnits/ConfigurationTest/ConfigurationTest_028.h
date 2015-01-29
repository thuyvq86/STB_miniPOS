//
//  ConfigurationTest_023.h
//  iSMPTestSuite
//
//  Created by Hichem Boussetta on 20/01/12.
//  Copyright (c) 2012 Ingenico. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BasicConfigurationTest.h"
#import "BundleImagePicker.h"

@interface ConfigurationTest_028 : BasicConfigurationTest<UINavigationControllerDelegate, UIImagePickerControllerDelegate, BundleImagePickerDelegate>

@property (nonatomic, assign) UISwitch      * switchPrinter;
@property (nonatomic, assign) UITextField   * textSelectedBitmap;
@property (nonatomic, assign) UIButton      * buttonSelectBitmap;
@property (nonatomic, assign) UIButton      * buttonPrintBitmap;
@property (nonatomic, retain) UIImage       * selectedBitmap;
@property (nonatomic, assign) UIButton      * buttonGetPrinterStatus;
@property (nonatomic, retain) NSArray       * bitmapArray;
@property (nonatomic, assign) NSInteger       lastPrinterStatus;


-(NSString *)printerResultToString:(iBPResult)result;
-(void)printerValueChanged;
-(void)selectBitmap;
-(void)printBitmap;
-(void)getPrinterStatus;

@end
