//
//  BasicSPPTest.h
//  iSMPTestSuite
//
//  Created by Hichem Boussetta on 24/05/12.
//  Copyright (c) 2012 Ingenico. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BasicTest.h"

@interface BasicSPPTest : BasicTest <ICISMPDeviceDelegate, ICISMPDeviceExtensionDelegate>

@property (nonatomic, retain) ICSPP         * sppChannel;

@end
