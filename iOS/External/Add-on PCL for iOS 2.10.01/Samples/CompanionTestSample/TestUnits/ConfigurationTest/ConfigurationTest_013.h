//
//  ConfigurationTest_013.h
//  iSMPTestSuite
//
//  Created by Hichem Boussetta on 13/01/11.
//  Copyright 2011 Ingenico. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BasicConfigurationTest.h"
#import "ICPdfReceipt.h"


@interface ConfigurationTest_013 : BasicConfigurationTest {

	ICPdfReceipt		* pdfReceipt;
	CGPoint				  printPos;
}

@property (nonatomic, retain) ICPdfReceipt * pdfReceipt;
@property (nonatomic, assign) BOOL           printingHasStarted;
@property (nonatomic, retain) UIWebView    * webView;
@property (nonatomic, assign) BOOL           bPrintRawText;

-(void)shouldStartTimeMeasure;

@end
