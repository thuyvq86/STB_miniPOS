//
//  ConfigurationTest_026.m
//  iSMPTestSuite
//
//  Created by Hichem Boussetta on 07/02/12.
//  Copyright (c) 2012 Ingenico. All rights reserved.
//

#import "ConfigurationTest_026.h"

@implementation ConfigurationTest_026

@synthesize switchPrinter;
@synthesize buttonPrint;
@synthesize buttonGetPrinterStatus;
@synthesize lastPrinterStatus;

+(NSString *)title {
	return @"Fonts";
}


+(NSString *)subtitle {
	return @"Text Fonts Testing";
}

+(NSString *)instructions {
	return @"Open the printer and press the Print Fonts button to print all supported iOS fonts";
}

+(NSString *)category {
	return @"iBP";
}


-(void)viewDidLoad {
	[super viewDidLoad];
	
    self.switchPrinter          = [self addSwitchWithTitle:@"BT Printer"];
    self.buttonPrint            = [self addButtonWithTitle:@"Print Fonts" andAction:@selector(printFonts)];
    self.buttonGetPrinterStatus = [self addButtonWithTitle:@"Get Printer Status" andAction:@selector(getPrinterStatus)];
    
    
    [self.switchPrinter addTarget:self action:@selector(printerValueChanged) forControlEvents:UIControlEventValueChanged];
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

-(void)enableUserInteraction:(NSNumber *)booleanNumber {
    [self.view setUserInteractionEnabled:[booleanNumber boolValue]]; 
}


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


#pragma mark Print iOS Fonts

-(NSArray *)iOSSupportedFonts {
    NSMutableArray * result = [NSMutableArray array];
    NSArray *familyNames = [UIFont familyNames];
    
    for (NSString *familyName in familyNames) {
        NSArray *fontNames = [UIFont fontNamesForFamilyName:familyName];
        for (NSString *fontName in fontNames) {
            [result addObject:fontName];
        }
    }
    return result;
}

-(void)backgroundPrintFonts {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    
    //NSUInteger width = [self.configurationChannel iBPMaxBitmapWidth];
    NSUInteger height = [self.configurationChannel iBPMaxBitmapHeight];
    //NSUInteger height = 512;
    
    //Render the ticket locally
    #define MAX_RECEIPT_HEIGHT  10000           //We will allocate memory for a bitmap that is large enough to contain the data of the receipt.
    iBPBitmapContext * bitmapContext = [[iBPBitmapContext alloc] initWithWidth:[self.configurationChannel iBPMaxBitmapWidth] andHeight:MAX_RECEIPT_HEIGHT];
    
    bitmapContext.textSize = 28;
    NSInteger alignIterator = 0;
    
    NSArray * iOSFonts = [self iOSSupportedFonts];
    
    for (NSString * fontName in iOSFonts) {
        bitmapContext.textFont = fontName;
        bitmapContext.alignment = alignIterator;
        alignIterator = (alignIterator + 1) % 3;
        [bitmapContext drawText:fontName];
        
        if ([bitmapContext drawingPosition] >= height) {
            [self beginTimeMeasure];
            iBPResult retValue = [self.configurationChannel iBPPrintBitmap:[bitmapContext getImage]];
            float totalTime = [self endTimeMeasure];
            
            NSString * resultString = [NSString stringWithFormat:@"Print Bitmap: %@", [self printerResultToString:retValue]];
            
            [self performSelectorOnMainThread:@selector(logMessage:) 
                                   withObject:[NSString stringWithFormat:@"%@ [Time: %f]", resultString, totalTime] waitUntilDone:NO];
            [bitmapContext clearContext];
        }
    }
    #undef MAX_RECEIPT_HEIGHT
    
    //Print the ticket
    NSUInteger bitmapOffset = 0;
        
    //Split the bitmap context to smaller bitmaps that do not exceed the maximum bitmap dimensions supported by the iSMP
    while (bitmapOffset < bitmapContext.drawingPosition) {
        UIImage * image = [bitmapContext getImageAt:bitmapOffset maxHeight:height];
        
        bitmapOffset += image.size.height;
        
        [self.configurationChannel iBPPrintBitmap:image];
    }
    
    //Release the bitmap context
    [bitmapContext release];
    
    [self performSelectorOnMainThread:@selector(enableUserInteraction:) withObject:[NSNumber numberWithBool:YES] waitUntilDone:NO];
    
    [pool release];
}

-(void)printFonts {
    [self.view setUserInteractionEnabled:NO];
    [self performSelectorInBackground:@selector(backgroundPrintFonts) withObject:nil];
}

#pragma mark -

@end
