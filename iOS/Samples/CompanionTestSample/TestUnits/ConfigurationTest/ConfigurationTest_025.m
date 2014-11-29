//
//  ConfigurationTest_025.m
//  iSMPTestSuite
//
//  Created by Hichem Boussetta on 01/02/12.
//  Copyright (c) 2012 Ingenico. All rights reserved.
//

#import "ConfigurationTest_025.h"

@implementation ConfigurationTest_025

@synthesize amount;
@synthesize printerData;
@synthesize printer;
@synthesize doTransactionTimeout;
@synthesize emptyExtendedData;
@synthesize paymentApplicationNumber;


-(void)viewDidLoad {
	[super viewDidLoad];
	
    self.doTransactionTimeout       = [self addTextFieldWithTitle:@"Transaction Timeout"];
	self.amount                     = [self addTextFieldWithTitle:@"Amount"];
    self.paymentApplicationNumber   = [self addTextFieldWithTitle:@"Payment Application N°"];
    self.emptyExtendedData          = [self addSwitchWithTitle:@"Empty Extended Data"];
	self.printerData = [[[NSMutableData alloc] init] autorelease];
	[self addButtonWithTitle:@"DO TRANSACTION" andAction:@selector(pay)];
	self.printer = [ICPrinter sharedPrinter];
	self.printer.delegate = self;
    
    self.amount.text = @"5";
    self.paymentApplicationNumber.text = @"0";
    
    //Show the default transaction timeout in the doTransactionTimeout text field
    doTransactionTimeout.text = [NSString stringWithFormat:@"%d", [self.configurationChannel getDoTransactionTimeout]];
}

-(void)dealloc {
	self.printer = nil;
	self.printerData = nil;
	[super dealloc];
}


+(NSString *)title {
	return @"Do Transaction Extended";
}


+(NSString *)subtitle {
	return @"Perform a transaction with extra parameters";
}

+(NSString *)instructions {
	return @"Ensure that the device is ready, then type the amount and validate. Default value of the amount is 5.";
}

+(NSString *)category {
	return @"Payment";
}

-(void)pay {
    
    //Prepare the transaction request
	ICTransactionRequest request;
	NSString * str_amount = nil;
	if ([amount.text intValue] <= 0) {
		str_amount = [NSString stringWithFormat:@"%08d", 5];
	}
	else {
		str_amount = [NSString stringWithFormat:@"%08d", [amount.text intValue]];
	}
	
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
    
    //Set the transaction timeout
    [self.configurationChannel setDoTransactionTimeout:[doTransactionTimeout.text intValue]];
    
    //Get the payment application number
    NSUInteger paymentAppNum = [self.paymentApplicationNumber.text intValue];
    
    //Set the extended data
    NSData * extendedData = nil;
    const unsigned int extendedDataSize = 16 * 1024;
    //const unsigned int extendedDataSize = 10;
    if (self.emptyExtendedData.on == NO) {
        char buf[extendedDataSize];
        memset(buf, '*', extendedDataSize);
        extendedData = [NSData dataWithBytes:buf length:extendedDataSize];
    }
    
    //Perform the transaction
	[self.configurationChannel doTransaction:request withData:extendedData andApplicationNumber:paymentAppNum];
    
    //Start time measure
	[self beginTimeMeasure];
}

-(void)transactionDidEndWithTimeoutFlag:(BOOL)replyReceived result:(ICTransactionReply)transactionReply andData:(NSData *)extendedData {
    [self logMessage:[NSString stringWithFormat:@"Total Time: %f", [self endTimeMeasure]]];
	if (replyReceived == NO) {
		[self logMessage:@"Request Timeout"];
		return;
	}
	char _amount[sizeof(transactionReply.amount)+1];
	char currency[sizeof(transactionReply.currency)+1];
	char privateData[sizeof(transactionReply.privateData)+1];
	char pan[sizeof(transactionReply.PAN)+1];
	char cardValidity[sizeof(transactionReply.cardValidity)+1];
	char cmc7[sizeof(transactionReply.CMC7)+1];
	char iso2[sizeof(transactionReply.ISO2)+1];
	char fnci[sizeof(transactionReply.FNCI)+1];
	char guarantor[sizeof(transactionReply.guarantor)+1];
    char zoneRep[sizeof(transactionReply.zoneRep) + 1];
    char zonePriv[sizeof(transactionReply.zonePriv) + 1];
    char _extendedData[[extendedData length] + 1];
	strncpy(_amount, transactionReply.amount, sizeof(transactionReply.amount));
	strncpy(currency, transactionReply.currency, sizeof(transactionReply.currency));
	strncpy(privateData, transactionReply.privateData, sizeof(transactionReply.privateData));
	strncpy(pan, transactionReply.PAN, sizeof(transactionReply.PAN));
	strncpy(cardValidity, transactionReply.cardValidity, sizeof(transactionReply.cardValidity));
	strncpy(cmc7, transactionReply.CMC7, sizeof(transactionReply.CMC7));
	strncpy(iso2, transactionReply.ISO2, sizeof(transactionReply.ISO2));
	strncpy(fnci, transactionReply.FNCI, sizeof(transactionReply.FNCI));
	strncpy(guarantor, transactionReply.guarantor, sizeof(transactionReply.guarantor));
    strncpy(zoneRep, transactionReply.zoneRep, sizeof(transactionReply.zoneRep));
    strncpy(zonePriv, transactionReply.zonePriv, sizeof(transactionReply.zonePriv));
    strncpy(_extendedData, [extendedData bytes], [extendedData length]);
	_amount[sizeof(transactionReply.amount)] = '\0';
	currency[sizeof(transactionReply.currency)] = '\0';
	privateData[sizeof(transactionReply.privateData)] = '\0';
	pan[sizeof(transactionReply.PAN)] = '\0';
	cardValidity[sizeof(transactionReply.cardValidity)] = '\0';
	cmc7[sizeof(transactionReply.CMC7)] = '\0';
	iso2[sizeof(transactionReply.ISO2)] = '\0';
	fnci[sizeof(transactionReply.FNCI)] = '\0';
	guarantor[sizeof(transactionReply.guarantor)] = '\0';
    zoneRep[sizeof(transactionReply.zoneRep)] = '\0';
    zonePriv[sizeof(transactionReply.zonePriv)] = '\0';
    _extendedData[[extendedData length]] = '\0';
    
	
	NSString * transactionParameters = 
	[NSString stringWithFormat:@"posNumber: %i\noperationStatus: %c\namount: %s\naccount type: %c\ncurrency: %s\nprivate data: %s\nPAN: %s\ncard validity: %s\nauthorization number: %s\nCMC7: %s\nISO2: %s\nFNCI: %s\nGuarantor: %s\nZone Rep: %s\nZone Priv: %s\nExtended Data: %s",
	 transactionReply.posNumber,		transactionReply.operationStatus, _amount, transactionReply.accountType, currency,
	 privateData, pan, cardValidity, transactionReply.authorizationNumber, cmc7,
	 iso2, fnci, guarantor, zoneRep, zonePriv, _extendedData];
	NSString * msg = @"Transaction succeeded";
	if (transactionReply.operationStatus != '0') {
		msg = @"Transaction failed";
	}
	[self logMessage:msg];
	[self logMessage:transactionParameters];
}


#pragma mark ICPrinterDelegate

-(void)receivedPrinterData:(NSData *)data {
	[self.printerData appendData:data];
}

-(void)printingDidEndWithRowNumber:(NSUInteger)count {
	//Convert Pixel Encoding to 8 bits per pixel
	NSUInteger size = [self.printerData length] * 8;
	char * receiptBuffer = (char *)malloc(size);
	char * microlineBuffer = (char *)[self.printerData bytes];
	NSUInteger i = 0;
	NSUInteger width = size / count;
	for (i = 0; i < size; i++) {
		receiptBuffer[i] = (((microlineBuffer[i / 8] & (0x80 >> (i % 8))) == 0x00) ? 0xFF : 0x00);
	}
	
	//Build a UIImage from the bitmap data
	CGDataProviderRef dataProvider = CGDataProviderCreateWithData(NULL, receiptBuffer, size, NULL);
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
	CGImageRef cgimage = CGImageCreate(width, count, 8, 8, width, colorSpace, kCGBitmapByteOrderDefault, dataProvider, NULL, NO, kCGRenderingIntentDefault);
	UIImage * image = [UIImage imageWithCGImage:cgimage];
	
	//View the receipt
	UIWebView * webView = [[[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height)] autorelease];
	[webView scalesPageToFit];
	[webView loadData:UIImagePNGRepresentation(image) MIMEType:@"image/png" textEncodingName:@"utf-8" baseURL:nil];
	[self.scrollView addSubview:webView];
	[self.scrollView setScrollEnabled:NO];
	
	CGDataProviderRelease(dataProvider);
	CGImageRelease(cgimage);
	CGColorSpaceRelease(colorSpace);
	
	self.printerData = [[[NSMutableData alloc] init] autorelease];
	free(receiptBuffer);
}

#pragma mark -


@end