//
//  PrinterTest_001.m
//  iSMPTestSuite
//
//  Created by Hichem Boussetta on 27/12/10.
//  Copyright 2010 Ingenico. All rights reserved.
//

#import "PrinterTest_001.h"


@implementation PrinterTest_001
@synthesize printerData;
@synthesize printingHasStarted;


-(void)viewDidLoad {
	[super viewDidLoad];
	
	self.printerData = [[[NSMutableData alloc] init] autorelease];
    self.printingHasStarted = NO;
}

-(void)dealloc {
	self.printerData = nil;
	[super dealloc];
}


#pragma mark class methods
+(NSString *)title {
	return @"Document Printing";
}

+(NSString *)subtitle {
	return @"Receipt printing throught the printing channel";
}

+(NSString *)instructions {
	return @"Launch a printing command from the iSMP and wait until the receipt is displayed. Then, take a look at the document and check if it was properly generated";
}

+(NSString *)category {
	return @"Remote printing";
}

#pragma mark -
#pragma mark instance methods


-(void)receivedPrinterData:(NSData *)data {
	[self.printerData appendData:data];
    if (self.printingHasStarted == NO) {
        self.printingHasStarted = YES;
        [self beginTimeMeasure];
    }
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
    
    //End time measure
    float totalTime = [self endTimeMeasure];
    [self performSelectorOnMainThread:@selector(logMessage:) withObject:[NSString stringWithFormat:@"Printing Time: %f seconds", totalTime] waitUntilDone:NO];
    self.printingHasStarted = NO;
    
	free(receiptBuffer);
}

-(void)accessoryDidDisconnect:(ICISMPDevice *)sender {
	self.printerData = [[[NSMutableData alloc] init] autorelease];
	[super accessoryDidDisconnect:sender];
}


@end
