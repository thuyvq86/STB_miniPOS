//
//  Transac_Test_006.h
//  iSMPTestSuite
//
//  Created by Hichem Boussetta on 24/05/12.
//  Copyright (c) 2012 Ingenico. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BasicTransactionTest.h"

@interface Transac_Test_002 : BasicTransactionTest <ICISMPDeviceExtensionDelegate>


@property (nonatomic, retain) ICTransaction * transactionChannel;
@property (nonatomic, retain) UITextField * textBufferLength;
@property (nonatomic, retain) UIButton * buttonStart;
@property (nonatomic, retain) UITextField * textLoopCount;
@property (nonatomic, retain) UITextField * textMediumTime;
@property (nonatomic, retain) UITextField * textBaudrate;

-(void)onStart;

@end
