//
//  ConfigurationTest_007.m
//  iSMPTestSuite
//
//  Created by Hichem Boussetta on 10/01/11.
//  Copyright 2011 Ingenico. All rights reserved.
//

#import "ConfigurationTest_007.h"


@implementation ConfigurationTest_007


-(void)pay {
    
    //Prepare the transaction request
	ICTransactionRequest request;
	NSString * str_amount = nil;
    str_amount = [NSString stringWithFormat:@"%08d", 5];
	
	strncpy(request.amount
			, [str_amount UTF8String], (unsigned int)sizeof(request.amount));
	request.accountType = '0';
	strncpy(request.currency, "978", (unsigned int)sizeof(request.currency));
	request.specificField = '1';
	request.transactionType = '0';
	strncpy(request.privateData, "0000000000", (unsigned int)sizeof(request.privateData));
	request.posNumber = 1;
	request.delay = '1';
	request.authorization = '0';
    
    //Perform the transaction
	[self.configurationChannel doTransaction:request];
}


-(void)viewDidLoad {
	[super viewDidLoad];
	
	signatureView = [[ICSignatureView alloc] initWithFrame:CGRectMake(0, 0, scrollView.frame.size.width, scrollView.frame.size.height)];
	[scrollView addSubview:signatureView];
	[self addButtonsWithTitle:@"Submit" andTitle2:@"Cancel" toAction:@selector(submit:)];
	[signatureView setUserInteractionEnabled:NO];
	scrollView.scrollEnabled = NO;
	shouldCaptureSignature = NO;
    
    [self pay];
}


+(NSString *)title {
	return @"Signature Capture";
}


+(NSString *)subtitle {
	return @"Perform a signature capture on the iPhone's screen";
}

+(NSString *)instructions {
	return @"Ensure that the device is ready and issue a signature capture request from the iSMP. Draw the signature on the canvas and submit.";
}

+(NSString *)category {
	return @"Miscellaneous";
}



-(void)shouldDoSignatureCapture:(ICSignatureData)signatureData {
	[self logMessage:@"Draw Signature Request Received"];
	[signatureView clear];
	[signatureView setUserInteractionEnabled:YES];
	[signatureView setExclusiveTouch:NO];
	[self logMessage:[NSString stringWithFormat:@"You have %lu seconds to draw your signature", (unsigned long)signatureData.userSignTimeout]];
	[self beginTimeMeasure];
	shouldCaptureSignature = YES;
}

-(void)signatureTimeoutExceeded {
	[self logMessage:@"Signature Capture Timeout"];
}


-(void)submit:(id)sender {
	if (shouldCaptureSignature == NO) {
		return;
	}
	UIButton * button = (UIButton *)sender;
	if (button.tag == 0) {
		UIImage * signature = [signatureView getSignatureDataAtBoundingBox];
		[self.configurationChannel submitSignatureWithImage:signature];
		[self logMessage:@"Signature submitted"];
		
		UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Signature" message:@"" delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];
		UIImageView * imageView = [[[UIImageView alloc] init] autorelease];
		imageView.image = signature;
		[alert addSubview:imageView];
		//[self.scrollView addSubview:imageView];
		[alert show];
		[alert setFrame:CGRectMake(0, 0, alert.frame.size.width, 300)];
		imageView.frame = CGRectMake((alert.frame.size.width - 100)/2, 130, 100, 100);
		[alert release];
		
	} else {
		[self.configurationChannel submitSignatureWithImage:nil];
		[self logMessage:@"Signature Capture Aborted"];
	}
	[signatureView setUserInteractionEnabled:NO];
	[self logMessage:[NSString stringWithFormat:@"Total Time: %f", [self endTimeMeasure]]];
	shouldCaptureSignature = NO;
}


@end
