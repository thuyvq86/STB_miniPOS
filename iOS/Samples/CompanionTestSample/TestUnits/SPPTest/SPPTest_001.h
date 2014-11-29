//
//  SPPTest_001.h
//  iSMPTestSuite
//
//  Created by Hichem Boussetta on 24/05/12.
//  Copyright (c) 2012 Ingenico. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BasicSPPTest.h"

@interface SPPTest_001 : BasicSPPTest<ICISMPDeviceExtensionDelegate>

@property (nonatomic, retain) UITextField           * textMessage;
@property (nonatomic, retain) UIButton              * buttonSubmit;
@property (nonatomic, retain) NSMutableData         * iPhone2iSPMData;

-(void)submitMessage;

@end
