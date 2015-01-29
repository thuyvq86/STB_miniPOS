//
//  ConfigurationTest_032.h
//  iSMPTestSuite
//
//  Created by Stephane RABILLER on 22/09/14.
//  Copyright 2014 Ingenico. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BasicConfigurationTest.h"

@interface ConfigurationTest_032:  BasicConfigurationTest<ICPrinterDelegate, ICISMPDeviceDelegate, ICPPPDelegate, ICAdministrationStandAloneDelegate> {
 UIButton * buttonUpdate;   
}

@property (nonatomic, retain) ICPPP             * pppNetwork;
@property (nonatomic, retain) UISwitch          * switchPPP;

@end