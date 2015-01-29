//
//  BasicPrintingTest.h
//  iSMPTestSuite
//
//  Created by Hichem Boussetta on 27/12/10.
//  Copyright 2010 Ingenico. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BasicTest.h"


@interface BasicPrintingTest : BasicTest <ICPrinterDelegate> {

	ICPrinter			* _printer;
}
@property(nonatomic, retain) ICPrinter			* printer;
@end
