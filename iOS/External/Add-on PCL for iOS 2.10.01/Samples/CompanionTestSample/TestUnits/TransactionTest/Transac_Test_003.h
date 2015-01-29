//
//  Transac_Test_007.h
//  iSMPTestSuite
//
//  Created by Hichem BOUSSETTA on 28/09/12.
//  Copyright (c) 2012 Ingenico. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BasicTransactionTest.h"

@interface Transac_Test_003 : BasicTransactionTest <ICISMPDeviceExtensionDelegate, ICAdministrationDelegate>

@property (nonatomic, retain) ICTransaction * transactionChannel;
@property (nonatomic, retain) ICAdministration * admin;

-(void)resetTerminal;

-(void)writeDataOnTransactionChannel;

@end
