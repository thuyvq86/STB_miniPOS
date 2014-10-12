//
//  ConfigurationTest_017.m
//  iSMPTestSuite
//
//  Created by Hichem Boussetta on 04/04/11.
//  Copyright 2011 Ingenico. All rights reserved.
//

#import "ConfigurationTest_017.h"


@implementation ConfigurationTest_017


+(NSString *)title {
	return @"Terminal Reset";
}


+(NSString *)subtitle {
	return @"Issue a Terminal Reset from the iPhone";
}

+(NSString *)instructions {
	return @"Ensure the device is ready and press the reset button to reset the terminal";
}

+(NSString *)category {
	return @"Device Configuration";
}


-(void)viewDidLoad {
	[super viewDidLoad];
	
	[self addButtonWithTitle:@"Reset" andAction:@selector(reset:)];
}

-(void)reset:(id)sender {
	[self.configurationChannel reset:0];
}

@end
