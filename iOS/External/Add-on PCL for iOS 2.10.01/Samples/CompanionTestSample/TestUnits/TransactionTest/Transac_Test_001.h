//
//  Transac_Test_005.h
//  iSMPTestSuite
//
//  Created by Hichem Boussetta on 06/05/11.
//  Copyright 2011 Ingenico. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BasicTransactionTest.h"


@interface Transac_Test_001 : BasicTransactionTest<ICISMPDeviceExtensionDelegate> {

	NSMutableData * iPhone2iSPMData;
	
}

@property (nonatomic, retain) ICTransaction * transactionChannel;
@property (nonatomic, retain) UITextField * textMessage;
@property (nonatomic, retain) UIButton * buttonSubmit;

@end
