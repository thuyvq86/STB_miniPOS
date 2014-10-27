//
//  ConfigurationTest_003.h
//  iSMPTestSuite
//
//  Created by Hichem Boussetta on 10/01/11.
//  Copyright 2011 Ingenico. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BasicConfigurationTest.h"


@interface ConfigurationTest_003 : BasicConfigurationTest {
	
	UITextField			* serialNumber;
	UITextField			* reference;
	UITextField			* protocol;
}


@property (nonatomic, retain) UITextField * serialNumber;
@property (nonatomic, retain) UITextField * reference;
@property (nonatomic, retain) UITextField * protocol;


@end
