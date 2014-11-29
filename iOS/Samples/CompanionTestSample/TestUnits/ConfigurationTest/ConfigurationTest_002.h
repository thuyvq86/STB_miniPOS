//
//  ConfigurationTest_002.h
//  iSMPTestSuite
//
//  Created by Hichem Boussetta on 29/12/10.
//  Copyright 2010 Ingenico. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BasicConfigurationTest.h"


@interface ConfigurationTest_002 : BasicConfigurationTest<ICNetworkDelegate> {
	UIButton * buttonUpdate;
}

@property (nonatomic, retain) ICNetwork * network;

@end
