//
//  BasicConfigurationTest.h
//  iSMPTestSuite
//
//  Created by Hichem Boussetta on 27/12/10.
//  Copyright 2010 Ingenico. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BasicTest.h"

@interface BasicConfigurationTest : BasicTest <ICISMPDeviceDelegate, ICAdministrationDelegate, NSStreamDelegate, ICISMPDeviceExtensionDelegate> {

	ICAdministration			* _configurationChannel;
}

@property (nonatomic, retain) ICAdministration			* configurationChannel;

-(NSString *)iSMPResultToString:(iSMPResult)result;

@end
