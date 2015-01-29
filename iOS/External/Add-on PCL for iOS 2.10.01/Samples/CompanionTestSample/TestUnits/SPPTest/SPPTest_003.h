//
//  SPPTest_003.h
//  iSMPTestSuite
//
//  Created by Christophe Cayrol on 14/05/13.
//  Copyright (c) 2013 Ingenico. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BasicSPPTest.h"
#import <iSMP/ICAdministration.h>

@interface SPPTest_003 : BasicSPPTest<ICISMPDeviceExtensionDelegate, ICAdministrationDelegate>

@property (nonatomic, retain) UITextField           * textMessage;
@property (nonatomic, retain) UIButton              * buttonStart;
@property (nonatomic, retain) ICAdministration		* configurationChannel;

-(void)onButtonPressed;

@end
