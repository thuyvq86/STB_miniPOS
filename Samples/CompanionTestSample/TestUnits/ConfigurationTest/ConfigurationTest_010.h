//
//  ConfigurationTest_027.h
//  iSMPTestSuite
//
//  Created by Hichem Boussetta on 14/02/12.
//  Copyright (c) 2012 Ingenico. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BasicConfigurationTest.h"


@interface ConfigurationTest_010 : BasicConfigurationTest<UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIPopoverControllerDelegate>

@property (nonatomic, assign) UISwitch      * switchPrinter;
@property (nonatomic, assign) UITextField   * textSelectedBitmap;
@property (nonatomic, assign) UIButton      * buttonSelectBitmap;
@property (nonatomic, assign) UIButton      * buttonPrintBitmap;
@property (nonatomic, retain) UIImage       * selectedBitmap;
@property (nonatomic, assign) UIButton      * buttonGetPrinterStatus;
@property (nonatomic, assign) NSInteger       lastPrinterStatus;
@property (nonatomic, assign) UITextField   * preferredWidth;
@property (nonatomic, assign) UITextField   * preferredHeight;

@property (nonatomic, retain) UIPopoverController * popover;

-(NSString *)printerResultToString:(iBPResult)result;
-(void)printerValueChanged;
-(void)selectBitmap;
-(void)printBitmap;
-(void)getPrinterStatus;

@end