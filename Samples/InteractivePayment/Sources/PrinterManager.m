//
//  PrinterManager.m
//  InteractivePayment
//
//  Created by Hichem Boussetta on 07/12/11.
//  Copyright (c) 2011 Ingenico. All rights reserved.
//

#import "PrinterManager.h"


#define DEFAULT_REFRESH_TIMEOUT     1

//Private Properties
@interface PrinterManager ()

@property (nonatomic, retain) ICPrinter         * printer;
@property (nonatomic, retain) NSMutableData     * printerData;
@property (nonatomic, assign) NSUInteger          lineCount;
@property (nonatomic, assign) NSInteger           refreshTimeout;
//@property (nonatomic, retain) UIImage           * lastReceipt;
@property (nonatomic, assign) ICBitmapReceipt   * bitmapReceipt;

//-(UIImage*)buildReceiptImage:(NSData*)data rowCount:(NSUInteger)count;

-(void)refreshReceipt;

-(void)appActive;
-(void)appResignActive;

@end


//Shared Instance
static PrinterManager * g_sharedPrinter = nil;




@implementation PrinterManager

@synthesize printer;
@synthesize printerData;
@synthesize lineCount;
@synthesize refreshTimeout;
@synthesize delegate;
//@synthesize lastReceipt;
@synthesize bitmapReceipt;


+(PrinterManager *)sharedPrinterManager {
    if (g_sharedPrinter == nil) {
        g_sharedPrinter = [[PrinterManager alloc] init];
    }
    return g_sharedPrinter;
}

-(id)init {
    if ((self = [super init])) {
        self.printer            = [ICPrinter sharedPrinter];
        self.printer.delegate   = self;
        self.printerData        = [NSMutableData dataWithLength:0];
        self.lineCount          = 0;
        self.refreshTimeout     = DEFAULT_REFRESH_TIMEOUT;
        self.bitmapReceipt      = [ICBitmapReceipt sharedBitmapReceipt];
        
        // Subscribe for appActive notification
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appActive) name:UIApplicationDidBecomeActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appResignActive) name:UIApplicationWillResignActiveNotification object:nil];
    }
    return self;
}

-(oneway void)release {
    
}


#pragma mark Open/Close the communication channel when entering/leaving sleep mode

//Start the printer
-(void)start {
    NSLog(@"%s", __FUNCTION__);
    self.printer = [ICPrinter sharedPrinter];
    self.printer.delegate = self;
}

//Stop the printer
-(void)stop {
    NSLog(@"%s", __FUNCTION__);
    self.printer = nil;
}

//Callback triggered when the application becomes active
-(void)appActive {
    NSLog(@"%s", __FUNCTION__);
    [self start];   //Start the printer
}

//Callback triggered when the application resigns from active state
-(void)appResignActive {
    NSLog(@"%s", __FUNCTION__);
    
    //Check the cradle mode global parameter and decide whether to close the channel or not
    if ([[SettingsManager sharedSettingsManager] cradleMode] == NO) {
        [self stop];
    } else {
        NSLog(@"%s Cradle Mode Enabled", __FUNCTION__);
    }
}

#pragma mark -



-(void)clearReceiptData {
    self.printerData.length = 0;
    self.lineCount = 0;
    //self.lastReceipt = nil;
    [self.bitmapReceipt clearBitmap];
}

-(id)getLastReceipt {
    //return self.lastReceipt;
    return [self.bitmapReceipt getImage];
}

-(void)refreshReceipt {
    //Save the receipt
    //self.lastReceipt = [self buildReceiptImage:self.printerData rowCount:self.lineCount];
    [self.bitmapReceipt drawRawMonochromeBitmapWithData:self.printerData andRowCount:self.lineCount];
    self.printerData.length = 0;
    self.lineCount = 0;
    
    //Stop printing animation on the receiver
    if ([(NSObject *)delegate respondsToSelector:@selector(shouldStopPrintingAnimation)]) {
        [delegate shouldStopPrintingAnimation];
    }
    
    //Refresh the receiver
    if ([(NSObject *)delegate respondsToSelector:@selector(shouldRefreshReceipt:)]) {
        [delegate shouldRefreshReceipt:[self getLastReceipt]];
    }
}

/*
-(UIImage*)buildReceiptImage:(NSData*)data rowCount:(NSUInteger)count {
    NSLog(@"%s", __FUNCTION__);
    //Convert Pixel Encoding to 8 bits per pixel
	NSUInteger size = [data length] * 8;
	char * receiptBuffer = (char *)malloc(size);
	char * microlineBuffer = (char *)[data bytes];
	NSUInteger i = 0;
	NSUInteger width = size / count;
	for (i = 0; i < size; i++) {
		receiptBuffer[i] = (((microlineBuffer[i / 8] & (0x80 >> (i % 8))) == 0x00) ? 0xFF : 0x00);
	}
	
	//Build a UIImage from the bitmap data
	CGDataProviderRef dataProvider = CGDataProviderCreateWithData(NULL, receiptBuffer, size, NULL);
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
	CGImageRef cgimage = CGImageCreate(width, count, 8, 8, width, colorSpace, kCGBitmapByteOrderDefault, dataProvider, NULL, NO, kCGRenderingIntentDefault);
    
    NSData * imageData = UIImageJPEGRepresentation([UIImage imageWithCGImage:cgimage], 1.0);
    UIImage * retimage = [[[UIImage imageWithData:[NSData  dataWithData:imageData]] retain] autorelease];
    
	CGImageRelease(cgimage);        
	CGColorSpaceRelease(colorSpace);    
	CGDataProviderRelease(dataProvider);
	
    free(receiptBuffer);
    return retimage;
}
*/


#pragma mark ICISMPDeviceDelegate

-(void)logEntry:(NSString *)message withSeverity:(int)severity {
    NSLog(@"[%@][%@]", [ICISMPDevice severityLevelString:severity], message);
}

#pragma mark -


#pragma mark ICPrinterDelegate

-(void)receivedPrinterData:(NSData *)data numberOfLines:(NSInteger)count {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(refreshReceipt) object:nil];
    
    [self.printerData appendData:data];
    self.lineCount += count;
    
    [self performSelector:@selector(refreshReceipt) withObject:nil afterDelay:self.refreshTimeout];
    
    //Call printing animation on the receiver
    if ([(NSObject *)delegate respondsToSelector:@selector(shouldStartPrintingAnimation)]) {
        [delegate shouldStartPrintingAnimation];
    }
}

#pragma mark -

@end
