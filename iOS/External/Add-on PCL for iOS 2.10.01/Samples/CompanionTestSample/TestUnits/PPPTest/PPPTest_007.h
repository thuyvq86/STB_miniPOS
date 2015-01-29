//
//  PPPTest_003.h
//  iSMPTestSuite
//
//  Created by Hichem BOUSSETTA on 14/06/13.
//  Copyright (c) 2013 Ingenico. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BasicPPPTest.h"

@interface PPPTest_007 : BasicPPPTest <NSStreamDelegate>

@property (nonatomic, retain) UISwitch              * switchPPP;
@property (nonatomic, retain) UITextField           * textWlanIP;
@property (nonatomic, retain) UITextField           * textIP;
@property (nonatomic, retain) UITextField           * textPortForExternalConnections;
@property (nonatomic, retain) NSOutputStream        * outputStream;

- (void) initNetworkCommunication;
@end
