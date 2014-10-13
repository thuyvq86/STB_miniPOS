//
//  BasicTransactionTest.h
//  iSMPTestSuite
//
//  Created by Hichem Boussetta on 27/12/10.
//  Copyright 2010 Ingenico. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BasicTest.h"

@interface BasicTransactionTest : BasicTest<ICISMPDeviceDelegate, ICAdministrationDelegate, NSStreamDelegate, ICISMPDeviceExtensionDelegate, ICAdministrationStandAloneDelegate> {
    ICAdministration			* _configurationChannel;
}
@property (nonatomic, retain) ICAdministration			* configurationChannel;

@end
