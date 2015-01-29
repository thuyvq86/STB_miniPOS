//
//  PPPTest_006.h
//  iSMPTestSuite
//
//  Created by Stephane RABILLER on 11/04/14.
//  Copyright (c) 2014 Ingenico. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BasicPPPTest.h"

@interface PPPTest_006 : BasicPPPTest

@property (nonatomic, retain) UISwitch              * switchPPP;
@property (nonatomic, retain) UITextField           * textWlanIP;
@property (nonatomic, retain) UITextField           * textIP;

@property (nonatomic, retain) NSMutableArray        * textPorts;

-(void)onSwitchPPPValueChanged;

-(void)startiOSToTeliumBridges;

@end
