//
//  NetworkTest_001.m
//  iSMPTestSuite
//
//  Created by Hichem Boussetta on 04/03/11.
//  Copyright 2011 Ingenico. All rights reserved.
//

#import "NetworkTest_001.h"


@implementation NetworkTest_001

+(NSString *)title {
	return @"Gateway";
}

+(NSString *)subtitle {
	return @"Network Gateway";
}

+(NSString *)instructions {
	return @"Perform any native network operation on the terminal side. The connection progress and the length of the exchanged bytes are displayed in the log panel.";
}

+(NSString *)category {
	return @"Basic Tests";
}

@end
