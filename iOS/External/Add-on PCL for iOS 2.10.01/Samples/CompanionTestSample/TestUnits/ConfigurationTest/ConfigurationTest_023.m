//
//  ConfigurationTest_023.m
//  iSMPTestSuite
//
//  Created by Hichem Boussetta on 20/01/12.
//  Copyright (c) 2012 Ingenico. All rights reserved.
//

#import "ConfigurationTest_023.h"

extern char tiger[];

@implementation ConfigurationTest_023

@synthesize buttonPrintBitmap;
@synthesize buttonSelectBitmap;
@synthesize switchPrinter;
@synthesize textSelectedBitmap;
@synthesize selectedBitmap;
@synthesize buttonGetPrinterStatus;
@synthesize bitmapArray;
@synthesize lastPrinterStatus;

-(void)viewDidLoad {
	[super viewDidLoad];
	
    self.switchPrinter      = [self addSwitchWithTitle:@"BT Printer"];
	self.buttonSelectBitmap = [self addButtonWithTitle:@"Select Bitmap" andAction:@selector(selectBitmap)];
    self.textSelectedBitmap = [self addTextFieldWithTitle:@"Selected Bitmap"];
    [self.textSelectedBitmap setEnabled:NO];
    self.buttonPrintBitmap  = [self addButtonWithTitle:@"Print Bitmap" andAction:@selector(printBitmap)];
    self.buttonGetPrinterStatus = [self addButtonWithTitle:@"Get Printer Status" andAction:@selector(getPrinterStatus)];
    
    [self.switchPrinter addTarget:self action:@selector(printerValueChanged) forControlEvents:UIControlEventValueChanged];
    
    self.bitmapArray = [NSArray arrayWithObjects:@"iBP_Sample_1.jpg",
                                                 @"iBP_Sample_2.png",
                                                 @"iBP_Sample_3.jpeg",
                                                 @"iBP_Sample_4.jpg", 
                                                 @"iBP_Sample_5.jpg", 
                                                 @"iBP_Sample_6.jpg", 
                                                 @"iBP_Sample_7.png",
                                                 @"iBP_Sample_8.png",
                                                 @"iBP_Sample_9.png",
                        nil];
    
    self.textSelectedBitmap.text = [self.bitmapArray objectAtIndex:0];
}


+(NSString *)title {
	return @"Print Bitmap";
}


+(NSString *)subtitle {
	return @"Print Bitmap";
}

+(NSString *)instructions {
	return @"Open the printer. Select a picture and print it.";
}

+(NSString *)category {
	return @"iBP";
}


-(NSString *)printerResultToString:(iBPResult)result {
    NSString * retValue = @"";
    
    switch (result) {
        case iBPResult_OK:                              retValue = @"OK"; break;
        case iBPResult_KO:                              retValue = @"KO"; break;
        case iBPResult_TIMEOUT:                         retValue = @"TIMEOUT"; break;
        case iBPResult_ISMP_NOT_CONNECTED:              retValue = @"ISMP NOT DETECTED"; break;
        case iBPResult_PRINTER_NOT_CONNECTED:           retValue = @"PRINTER NOT CONNECTED"; break;
        case iBPResult_INVALID_PARAM:                   retValue = @"INVALID_PARAM"; break;
        case iBPResult_TEXT_TOO_LONG:                   retValue = @"TEXT TOO LONG"; break;
        case iBPResult_BITMAP_CONVERSION_ERROR:         retValue = @"BITMAP CONVERSION ERROR"; break;
        case iBPResult_WRONG_LOGO_NAME_LENGTH:          retValue = @"WRONG LOGO NAME LENGTH"; break;
        case iBPResult_PRINTING_ERROR:                  retValue = @"PRINTING ERROR"; break;
        case iBPResult_PAPER_OUT:                       retValue = @"PAPER OUT"; break;
        case iBPResult_PRINTER_LOW_BATT:                retValue = @"PRINTER IS IN LOW BATT"; break;
            
        default:                                        retValue = @"Unknown Result Code"; break;
    }
    return retValue;
}


#pragma mark Open/Close Printer

-(void)backgroundOpen {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    
    [self beginTimeMeasure];
    BOOL retValue = [self.configurationChannel iBPOpenPrinter];
    float totalTime = [self endTimeMeasure];
    
    NSString * resultString = [NSString stringWithFormat:@"Printer Open: %@", [self printerResultToString:retValue]];
    
    [self performSelectorOnMainThread:@selector(logMessage:) 
                           withObject:[NSString stringWithFormat:@"%@ [Time: %f]", resultString, totalTime] waitUntilDone:NO];
    
    if (retValue != iBPResult_OK) {
        self.switchPrinter.on = NO;
    }
    [self performSelectorOnMainThread:@selector(enableUserInteraction:) withObject:[NSNumber numberWithBool:YES] waitUntilDone:NO];
    
    [pool release];
}

-(void)backgroundClose {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    
    [self beginTimeMeasure];
    iBPResult retValue = [self.configurationChannel iBPClosePrinter];
    float totalTime = [self endTimeMeasure];
    
    NSString * resultString = [NSString stringWithFormat:@"Printer Close: %@", [self printerResultToString:retValue]];
    
    [self performSelectorOnMainThread:@selector(logMessage:) 
                           withObject:[NSString stringWithFormat:@"%@ [Time: %f]", resultString, totalTime] waitUntilDone:NO];
    
    [self performSelectorOnMainThread:@selector(enableUserInteraction:) withObject:[NSNumber numberWithBool:YES] waitUntilDone:NO];
    
    [pool release];
}

-(void)printerValueChanged
{
    if (self.switchPrinter.on) {
        [self.view setUserInteractionEnabled:NO];
        [self performSelectorInBackground:@selector(backgroundOpen) withObject:nil];
    } else {
        [self.view setUserInteractionEnabled:NO];
        [self performSelectorInBackground:@selector(backgroundClose) withObject:nil];
    }
}

#pragma mark -

-(void)selectBitmap {
    BundleImagePicker * imagePicker = [[[BundleImagePicker alloc] init] autorelease];
    imagePicker.delegate = self;
    imagePicker.bitmapNames = self.bitmapArray;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

-(void)enableUserInteraction:(NSNumber *)booleanNumber {
    [self.view setUserInteractionEnabled:[booleanNumber boolValue]]; 
}

-(void)backgroundPrintBitmap {
    NSLog(@"%s", __FUNCTION__);
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
     
    //NSData * bitmapData = [NSData dataWithBytes:tiger length:10622];
    
    NSString * bitmapName = [self.textSelectedBitmap.text stringByDeletingPathExtension];
    NSString * bitmapExtension = [self.textSelectedBitmap.text pathExtension];
    UIImage * bitmap = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:bitmapName ofType:bitmapExtension]];
    NSLog(@"%s Bitmap Info: [Name: %@, Width: %f, Height: %f]", __FUNCTION__, self.textSelectedBitmap.text, bitmap.size.width, bitmap.size.height);
    
    [self beginTimeMeasure];  
    //iBPResult retValue = [self.configurationChannel iBPPrintBitmapWithData:bitmapData];
    iBPResult retValue = [self.configurationChannel iBPPrintBitmap:bitmap];
    float totalTime = [self endTimeMeasure];
    
    NSString * resultString = [NSString stringWithFormat:@"Print Bitmap: %@", [self printerResultToString:retValue]];
    
    [self performSelectorOnMainThread:@selector(logMessage:) 
                           withObject:[NSString stringWithFormat:@"%@ [Time: %f]", resultString, totalTime] waitUntilDone:NO];
    
    [self performSelectorOnMainThread:@selector(enableUserInteraction:) withObject:[NSNumber numberWithBool:YES] waitUntilDone:NO];
    
    [pool release];
}

-(void)printBitmap {
    NSLog(@"%s", __FUNCTION__);
    [self.view setUserInteractionEnabled:NO];
    [self performSelectorInBackground:@selector(backgroundPrintBitmap) withObject:nil];
}


#pragma mark Get Printer Status

-(void)backgroundGetPrinterStatus {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    
    [self beginTimeMeasure];
    iBPResult retValue = [self.configurationChannel iBPGetPrinterStatus];
    float totalTime = [self endTimeMeasure];
    
    self.lastPrinterStatus = retValue;
    if (self.lastPrinterStatus == iBPResult_OK) {
        self.switchPrinter.on = YES;
    }
    
    NSString * resultString = [NSString stringWithFormat:@"Get Printer Status: %@", [self printerResultToString:retValue]];
    
    [self performSelectorOnMainThread:@selector(logMessage:) 
                           withObject:[NSString stringWithFormat:@"%@ [Time: %f]", resultString, totalTime] waitUntilDone:NO];
    
    [self performSelectorOnMainThread:@selector(enableUserInteraction:) withObject:[NSNumber numberWithBool:YES] waitUntilDone:NO];
    
    [pool release];
}

-(void)getPrinterStatus {
    [self.view setUserInteractionEnabled:NO];
    [self performSelectorInBackground:@selector(backgroundGetPrinterStatus) withObject:nil];
}

#pragma mark -


#pragma mark BundleImagePickerDelegate

-(void)bundleImagePickerDidSelectBitmapWithName:(NSString *)bitmapName {
    NSLog(@"%s Bitmap Name: %@", __FUNCTION__, bitmapName);
    self.textSelectedBitmap.text = bitmapName;
}

#pragma mark -


@end
