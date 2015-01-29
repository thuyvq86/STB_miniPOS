//
//  ConfigurationTest_007.h
//  iSMPTestSuite
//
//  Created by Hichem Boussetta on 10/01/11.
//  Copyright 2011 Ingenico. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BasicConfigurationTest.h"
#import "ICSignatureView.h"


@interface ConfigurationTest_007 : BasicConfigurationTest {

	ICSignatureView * signatureView;
	BOOL			  shouldCaptureSignature;
}

@end
