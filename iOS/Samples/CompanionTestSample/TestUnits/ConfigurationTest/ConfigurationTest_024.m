//
//  ConfigurationTest_024.m
//  iSMPTestSuite
//
//  Created by Hichem Boussetta on 23/01/12.
//  Copyright (c) 2012 Ingenico. All rights reserved.
//

#import "ConfigurationTest_024.h"

extern unsigned char tiger[];


@implementation ConfigurationTest_024

@synthesize switchPrinter;
@synthesize textLogoName;
@synthesize textLogoFileName;
@synthesize buttonSelectLogo;
@synthesize buttonPrintLogo;
@synthesize buttonStoreLogo;
@synthesize buttonGetPrinterStatus;
@synthesize bitmapArray;
@synthesize lastPrinterStatus;


-(void)viewDidLoad {
	[super viewDidLoad];
	
    self.switchPrinter      = [self addSwitchWithTitle:@"BT Printer"];
    self.buttonSelectLogo   = [self addButtonWithTitle:@"Select Logo" andAction:@selector(selectLogo)];
    self.textLogoFileName   = [self addTextFieldWithTitle:@"Logo File Name"];
    [self.textLogoFileName setEnabled:NO];
    self.textLogoName       = [self addTextFieldWithTitle:@"Logo Name"];
    [self addButtonsWithTitle:@"Store" andTitle2:@"Print" toAction:@selector(storeOrPrintLogo:)];
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
    
    self.textLogoFileName.text = [self.bitmapArray objectAtIndex:0];
}


+(NSString *)title {
	return @"Store & Print Logo";
}


+(NSString *)subtitle {
	return @"Store & Print Logo";
}

+(NSString *)instructions {
	return @"Open the printer. Type the name of the logo you wish to store or print, then choose the action.";
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

-(void)selectLogo {
    BundleImagePicker * imagePicker = [[[BundleImagePicker alloc] init] autorelease];
    imagePicker.delegate = self;
    imagePicker.bitmapNames = self.bitmapArray;
    [self presentModalViewController:imagePicker animated:YES];
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


#pragma mark Store & Print Logo


-(void)enableUserInteraction:(NSNumber *)booleanNumber {
    [self.view setUserInteractionEnabled:[booleanNumber boolValue]]; 
}


-(void)backgroundPrintLogo {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    
    [self beginTimeMeasure];
    iBPResult retValue = [self.configurationChannel iBPPrintLogoWithName:self.textLogoName.text];
    float totalTime = [self endTimeMeasure];
    
    NSString * resultString = [NSString stringWithFormat:@"Print Logo: %@", [self printerResultToString:retValue]];
    
    [self performSelectorOnMainThread:@selector(logMessage:) 
                           withObject:[NSString stringWithFormat:@"%@ [Time: %f]", resultString, totalTime] waitUntilDone:NO];
    
    [self performSelectorOnMainThread:@selector(enableUserInteraction:) withObject:[NSNumber numberWithBool:YES] waitUntilDone:NO];
    
    [pool release];
}

-(void)backgroundStoreLogo {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    
    //NSData * logoData = [NSData dataWithBytes:tiger length:10622];
    NSString * bitmapName = [self.textLogoFileName.text stringByDeletingPathExtension];
    NSString * bitmapExtension = [self.textLogoFileName.text pathExtension];
    UIImage * bitmap = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:bitmapName ofType:bitmapExtension]];
    NSLog(@"%s Bitmap Info: [Name: %@, Width: %f, Height: %f]", __FUNCTION__, self.textLogoFileName.text, bitmap.size.width, bitmap.size.height);
    
    [self beginTimeMeasure];
    //iBPResult retValue = [self.configurationChannel iBPStoreLogoWithName:self.textLogoName.text andData:logoData];
    iBPResult retValue = [self.configurationChannel iBPStoreLogoWithName:self.textLogoName.text andImage:bitmap];
    float totalTime = [self endTimeMeasure];
    
    NSString * resultString = [NSString stringWithFormat:@"Store Logo: %@", [self printerResultToString:retValue]];
    
    [self performSelectorOnMainThread:@selector(logMessage:) 
                           withObject:[NSString stringWithFormat:@"%@ [Time: %f]", resultString, totalTime] waitUntilDone:NO];
    
    [self performSelectorOnMainThread:@selector(enableUserInteraction:) withObject:[NSNumber numberWithBool:YES] waitUntilDone:NO];
    
    [pool release];
}

-(void)storeOrPrintLogo:(id)sender {
    UIButton * button = (UIButton *)sender;
    
    [self.view setUserInteractionEnabled:NO];
    if (button.tag == 0) {      //Store Logo
        [self performSelectorInBackground:@selector(backgroundStoreLogo) withObject:nil];
    } else {                    //Print Logo
        [self performSelectorInBackground:@selector(backgroundPrintLogo) withObject:nil];
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

#pragma mark BundleImagePickerDelegate

-(void)bundleImagePickerDidSelectBitmapWithName:(NSString *)bitmapName {
    NSLog(@"%s Bitmap Name: %@", __FUNCTION__, bitmapName);
    self.textLogoFileName.text = bitmapName;
}

#pragma mark -


@end
