//
//  ConfigurationTest_029.h
//  iSMPTestSuite
//
//  Created by Stephane RABILLER on 22/09/14.
//  Copyright 2014 Ingenico. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BasicConfigurationTest.h"


@interface ConfigurationTest_030 : BasicConfigurationTest {
	
	UITextField			* ip;
	UITextField			* port;
	UITextField			* identifier;
    UITextField         * sslProfiles;
    NSUInteger          labelCount;
}


@property (nonatomic, retain) UITextField * ip;
@property (nonatomic, retain) UITextField * port;
@property (nonatomic, retain) UITextField * identifier;
@property (nonatomic, retain) UITextField * sslProfiles;

@end
