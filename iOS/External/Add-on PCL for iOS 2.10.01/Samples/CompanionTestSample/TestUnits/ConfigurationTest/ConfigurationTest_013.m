//
//  ConfigurationTest_013.m
//  iSMPTestSuite
//
//  Created by Hichem Boussetta on 13/01/11.
//  Copyright 2011 Ingenico. All rights reserved.
//

#import "ConfigurationTest_013.h"
#define vSpace 2


@implementation ConfigurationTest_013
@synthesize pdfReceipt;
@synthesize printingHasStarted;
@synthesize bPrintRawText;


-(void)viewDidLoad {
	[super viewDidLoad];
	
	self.pdfReceipt = [[[ICPdfReceipt alloc] init] autorelease];
	[self.pdfReceipt beginPdfCreate];
	printPos.x = 0;
	printPos.y = 0;
    self.printingHasStarted = NO;
    self.bPrintRawText = FALSE;
}

-(void)dealloc {
	self.pdfReceipt = nil;
	[super dealloc];
}

+(NSString *)title {
	return @"Printing";
}


+(NSString *)subtitle {
	return @"Advanced Receipt Printing";
}

+(NSString *)instructions {
	return @"Ensure that the device is ready and issue from the iSMP a print receipt request.";
}

+(NSString *)category {
	return @"Miscellaneous";
}


-(void)shouldStartTimeMeasure {
    if (self.printingHasStarted == NO) {
        self.printingHasStarted = YES;
        [self beginTimeMeasure];
    }
}


-(void)printingDidEnded {
	}


-(void)confLogEntry:(NSString *)message withSeverity:(int)severity {
	[self performSelectorOnMainThread:@selector(logMessage:) withObject:message waitUntilDone:NO];
}


-(void)shouldFeedPaper {
	printPos.y += vSpace;
    [self shouldStartTimeMeasure];
}

-(void)shouldFeedPaperWithLines:(NSUInteger) linesToJump {
	printPos.y += vSpace * linesToJump;
    NSLog(@" %s ", __FUNCTION__);
    CGSize textBoxSize = [self.pdfReceipt   drawText:@"SHOULD PAPER 5 LINES" atPosition:printPos];
    printPos.y += vSpace + textBoxSize.height;
    [self shouldStartTimeMeasure];
}

-(void)shouldPrintImage:(UIImage *)image {
    CGSize imageBoxSize = [self.pdfReceipt getBitmapSizeWithImage:image];
    printPos.y += vSpace + imageBoxSize.height;
    [self.pdfReceipt drawBitmapWithImage:image atPosition:printPos];
    printPos.y += vSpace + imageBoxSize.height;
    [self shouldStartTimeMeasure];
}

-(void)shouldPrintText:(NSString *)text withFont:(UIFont *)font andAlignment:(UITextAlignment)alignment {
	if(bPrintRawText == FALSE)
    {
        self.pdfReceipt.pdfTextFont = [font fontName];
        self.pdfReceipt.pdfTextSize = 20;
        self.pdfReceipt.pdfTextAlignment = alignment;
        CGSize textBoxSize = [self.pdfReceipt drawText:text atPosition:printPos];
        printPos.y += vSpace + textBoxSize.height;
    }
    [self shouldStartTimeMeasure];
}

-(void)shouldPrintRawText:(char *)text withCharset:(NSInteger)charset withFont:(UIFont *)font alignment:(UITextAlignment)alignment XScaling:(NSInteger)xFactor YScaling:(NSInteger)yFactor underline:(BOOL)underline bold:(BOOL)bold {
    if (charset == 127)
    {
        bPrintRawText = TRUE;
        NSString *formatedText = [[NSString alloc]initWithCString:text encoding:NSWindowsCP1251StringEncoding];
        self.pdfReceipt.pdfTextFont = [font fontName];
        self.pdfReceipt.pdfTextSize = 20;
        self.pdfReceipt.pdfTextAlignment = alignment;
        CGSize textBoxSize = [self.pdfReceipt drawText:formatedText atPosition:printPos];
        printPos.y += vSpace + textBoxSize.height;
        [formatedText release];
    }
    else
    {
        bPrintRawText = FALSE;
    }
    [self shouldStartTimeMeasure];
}

-(NSInteger)shouldStartReceipt:(NSInteger)receiptType {
    NSLog(@" %s ", __FUNCTION__);
    CGSize textBoxSize = [self.pdfReceipt   drawText:@"******** START RECEIPT ********" atPosition:printPos];
    printPos.y += vSpace + textBoxSize.height;
    switch(receiptType)
    {
        case 0:
            textBoxSize = [self.pdfReceipt   drawText:@"MERCHANT" atPosition:printPos];
            printPos.y += vSpace + textBoxSize.height;
            break;

        case 1:
            textBoxSize = [self.pdfReceipt   drawText:@"CUSTOMER" atPosition:printPos];
            printPos.y += vSpace + textBoxSize.height;
            break;
    }
    return 1;
}

-(NSInteger)shouldEndReceipt {
    NSLog(@" %s ", __FUNCTION__);
    CGSize textBoxSize = [self.pdfReceipt   drawText:@"******** END RECEIPT ********" atPosition:printPos];
    printPos.y += vSpace + textBoxSize.height;
    return 1;
}

-(NSInteger)shouldAddSignature {
    NSLog(@" %s ", __FUNCTION__);
    CGSize textBoxSize = [self.pdfReceipt   drawText:@"SHOULD ADD SIGNATURE" atPosition:printPos];
    printPos.y += vSpace + textBoxSize.height;
    return 1;
}

-(void)accessoryDidDisconnect:(ICISMPDevice *)sender {
	if (sender == self.configurationChannel) {
		[self performSelectorOnMainThread:@selector(logMessage:) withObject:@"Printing Aborted" waitUntilDone:NO];
		printPos.x = 0;
		printPos.y = 0;
		self.pdfReceipt = [[[ICPdfReceipt alloc] init] autorelease];
	}
	[super accessoryDidDisconnect:sender];
}


-(void)shouldCutPaper
{
    NSLog(@" %s ", __FUNCTION__);    
    //CGSize textBoxSize = [self.pdfReceipt   drawText:@"----------------" atPosition:printPos];
    //printPos.y += vSpace + textBoxSize.height;
    
    NSData * pdfData = [self.pdfReceipt endPdfCreate];
	//printPos.x = 0;
	//printPos.y = 0;
	//self.pdfReceipt = [[[ICPdfReceipt alloc] init] autorelease];
	//[self.pdfReceipt beginPdfCreate];
	
	UIWebView * webView = [[[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height)] autorelease];
	[self.scrollView setScrollEnabled:NO];
	[webView scalesPageToFit];
	[webView loadData:pdfData MIMEType:@"application/pdf" textEncodingName:@"utf-8" baseURL:nil];
	[self.scrollView addSubview:webView];
	[self.scrollView setScrollEnabled:NO];
    
    //End time measure
    float totalTime = [self endTimeMeasure];
    [self performSelectorOnMainThread:@selector(logMessage:) withObject:[NSString stringWithFormat:@"Total Printing Time: %f", totalTime] waitUntilDone:NO];
    self.printingHasStarted = NO;
}
@end
