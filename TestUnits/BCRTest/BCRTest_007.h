//
//  BCRTest_014.h
//  iSMPTestSuite
//
//  Created by Stephane Rabiller on 03/06/13.
//  Copyright 2013 Ingenico. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BasicBarcodeReaderTest.h"

@interface BCRTest_007 : BasicBarcodeReaderTest<ICAdministrationDelegate> {
    BOOL		startTest;
}

@property (nonatomic, retain) ICAdministration      * configurationChannel;

-(void)resetTerminal;
@end
