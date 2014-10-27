//
//  PPPTest_001.h
//  iSMPTestSuite
//
//  Created by Hichem BOUSSETTA on 03/06/13.
//  Copyright (c) 2013 Ingenico. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BasicPPPTest.h"

@interface PPPTest_001 : BasicPPPTest <NSStreamDelegate>

@property (nonatomic, retain) UITextField           * textSubmask;
@property (nonatomic, retain) UITextField           * textDns;
@property (nonatomic, retain) UITextField           * textTerminalIP;


-(void)onSwitchPPPValueChanged;

@end
