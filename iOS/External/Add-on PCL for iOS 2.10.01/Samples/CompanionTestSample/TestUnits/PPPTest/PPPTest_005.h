//
//  PPPTest_005.h
//  iSMPTestSuite
//
//  Created by Hichem BOUSSETTA on 17/06/13.
//  Copyright (c) 2013 Ingenico. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BasicPPPTest.h"

@interface PPPTest_005 : BasicPPPTest

@property (nonatomic, retain) UISwitch              * switchPPP;
@property (nonatomic, retain) UITextField           * textWlanIP;
@property (nonatomic, retain) UITextField           * textIP;

@property (nonatomic, retain) NSMutableArray        * textPorts;

-(void)onSwitchPPPValueChanged;

-(void)startiOSToTeliumBridges;

@end
