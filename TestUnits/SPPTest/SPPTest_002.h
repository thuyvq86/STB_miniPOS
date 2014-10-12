//
//  SPPTest_002.h
//  iSMPTestSuite
//
//  Created by Boris LECLERE on 8/27/12.
//  Copyright (c) 2012 Ingenico. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BasicSPPTest.h"

@interface SPPTest_002 : BasicSPPTest<ICISMPDeviceExtensionDelegate>

@property (nonatomic, retain) UITextField           * textMessage;
@property (nonatomic, retain) UIButton              * buttonStart;

-(void)onStart;

@end
