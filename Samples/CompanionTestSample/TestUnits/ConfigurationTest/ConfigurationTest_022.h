//
//  ConfigurationTest_005.h
//  iSMPTestSuite
//
//  Created by Hichem Boussetta on 10/01/11.
//  Copyright 2011 Ingenico. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BasicConfigurationTest.h"


@interface ConfigurationTest_022 : BasicConfigurationTest {
	
	UITextField	* spmState;
}


@property (nonatomic, retain) UITextField * spmState;

-(void)refresh;

@end
