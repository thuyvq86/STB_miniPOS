//
//  BasicPPPTest.h
//  iSMPTestSuite
//
//  Created by Ingenico on 28/05/13.
//  Copyright (c) 2013 Ingenico. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BasicTest.h"

@interface BasicPPPTest : BasicTest <ICISMPDeviceDelegate, ICPPPDelegate, ICAdministrationStandAloneDelegate>{
    ICAdministration			* _configurationChannel;
}

@property (nonatomic, retain) ICAdministration *configurationChannel;
@property (nonatomic, retain) ICPPP         * pppChannel;

@property (nonatomic, retain) UISwitch              * switchPPP;
@property (nonatomic, retain) UITextField           * textWlanIP;
@property (nonatomic, retain) UITextField           * textIP;

@end
